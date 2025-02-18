import 'dart:math';

import 'package:folly_fields/util/hashable.dart';

///
///
///
class Decimal with Hashable {
  final int precision;
  double value;

  ///
  ///
  ///
  Decimal({
    required this.precision,
    int? initialValue,
    double? doubleValue,
  })  : assert(precision >= 0, 'precision must be positive or zero'),
        value = initialValue != null
            ? initialValue.toDouble() / pow(10, precision)
            : doubleValue ?? 0.0;

  ///
  ///
  ///
  int get integer => int.parse((value * pow(10, precision)).toStringAsFixed(0));

  ///
  ///
  ///
  // TODO(edufolly): Formatar corretamente.
  @override
  String toString() => value.toStringAsFixed(precision);

  ///
  ///
  ///
  @override
  int get hashCode => finish(combine(precision, integer));

  ///
  ///
  ///
  @override
  bool operator ==(Object other) {
    if (other is Decimal) {
      return precision == other.precision && value == other.value;
    }

    return false;
  }
}
