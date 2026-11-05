import 'package:flutter_test/flutter_test.dart';
import 'package:icejz_app/config/brand.dart';

void main() {
  test('Brand constants', () {
    expect(Brand.name, 'ICEJZ');
    expect(Brand.version, 'v1.0.3');
  });
}
