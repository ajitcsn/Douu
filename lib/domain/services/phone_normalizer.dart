import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// E.164 normalization (§5.1). Indian numbers arrive in many shapes:
/// `98765 43210`, `+91 98765 43210`, `098765…`, `+919876543210`.
class PhoneNormalizer {
  PhoneNormalizer({this.defaultIsoCode = IsoCode.IN});

  final IsoCode defaultIsoCode;

  /// Returns E.164 (`+919876543210`) or null if it can't be made valid.
  String? toE164(String? raw) {
    if (raw == null) return null;
    var cleaned = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleaned.isEmpty) return null;

    try {
      // Strip a single leading domestic trunk zero for 10-digit IN mobiles.
      if (defaultIsoCode == IsoCode.IN &&
          cleaned.startsWith('0') &&
          cleaned.length == 11) {
        cleaned = cleaned.substring(1);
      }

      final PhoneNumber parsed;
      if (cleaned.startsWith('+')) {
        parsed = PhoneNumber.parse(cleaned);
      } else if (RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
        // bare 10-digit IN mobile → assume +91
        parsed = PhoneNumber.parse(cleaned, callerCountry: defaultIsoCode);
      } else {
        parsed = PhoneNumber.parse(cleaned, callerCountry: defaultIsoCode);
      }

      if (!parsed.isValid()) return null;
      return parsed.international.replaceAll(' ', '');
    } catch (_) {
      return null;
    }
  }
}
