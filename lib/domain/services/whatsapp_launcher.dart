import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/defaults.dart';
import '../../data/db/database.dart';

/// wa.me handoff (§5.7). Builds the deep link and opens WhatsApp. Douu never
/// sends a message — the user does that manually inside WhatsApp.
class WhatsappLauncher {
  WhatsappLauncher(this.db);

  final AppDatabase db;

  // Package names for explicit-target launches (Settings → "Open links in").
  static const _packages = {
    'whatsapp': 'com.whatsapp',
    'business': 'com.whatsapp.w4b',
  };

  /// True if [phoneE164] can produce a valid wa.me link.
  bool canMessage(String? phoneE164) {
    if (phoneE164 == null) return false;
    final digits = phoneE164.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 8;
  }

  Uri? buildUri({
    required String? phoneE164,
    String? displayName,
    String? template,
  }) {
    if (!canMessage(phoneE164)) return null;
    final digits = phoneE164!.replaceAll(RegExp(r'[^0-9]'), '');
    final params = <String, String>{};
    if (template != null && template.isNotEmpty) {
      params['text'] = _applyTemplate(template, displayName);
    }
    return Uri.https('wa.me', '/$digits', params.isEmpty ? null : params);
  }

  /// Returns true if WhatsApp was launched. Caller should then track the
  /// pending contactId and present S13 on resume.
  Future<bool> launch({
    required String? phoneE164,
    String? displayName,
    String? template,
  }) async {
    final uri = buildUri(
      phoneE164: phoneE164,
      displayName: displayName,
      template: DouuDefaults.prefillStarterEnabled ? template : null,
    );
    if (uri == null) return false;

    final settings = await db.getSettings();
    final package = _packages[settings.whatsappTarget];
    if (Platform.isAndroid && package != null) {
      if (await _launchWithPackage(uri, package)) return true;
      // Preferred app isn't installed — fall through to the system default.
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> _launchWithPackage(Uri uri, String package) async {
    try {
      await AndroidIntent(
        action: 'action_view',
        data: uri.toString(),
        package: package,
      ).launch();
      return true;
    } catch (_) {
      return false;
    }
  }

  String _applyTemplate(String template, String? displayName) {
    final first = (displayName ?? '').trim().split(RegExp(r'\s+')).first;
    return template.replaceAll('{name}', first.isEmpty ? 'there' : first);
  }
}
