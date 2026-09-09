import 'package:douu/domain/services/phone_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

// §5.1 — normalization is critical; a wrong format silently breaks wa.me.
void main() {
  final n = PhoneNormalizer();

  test('bare 10-digit IN mobile gets +91', () {
    expect(n.toE164('9876543210'), '+919876543210');
  });

  test('spaced IN mobile', () {
    expect(n.toE164('98765 43210'), '+919876543210');
  });

  test('already E.164 with spaces', () {
    expect(n.toE164('+91 98765 43210'), '+919876543210');
  });

  test('leading domestic trunk zero stripped', () {
    expect(n.toE164('098765 43210'), '+919876543210');
  });

  test('dashes and parens removed', () {
    expect(n.toE164('+91-98765-43210'), '+919876543210');
  });

  test('garbage returns null', () {
    expect(n.toE164('not a number'), isNull);
    expect(n.toE164(''), isNull);
    expect(n.toE164(null), isNull);
  });
}
