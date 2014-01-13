library filters;

import 'package:polymer_expressions/filter.dart';

class StringToInt extends Transformer<String, int> {
  final int radix;

  StringToInt({this.radix: 10});

  // convert int to String
  String forward(int i) => '$i';

  // convert String to int
  int reverse(String s) => s == null ? null : int.parse(s, radix: radix, onError: (s) => null);
}