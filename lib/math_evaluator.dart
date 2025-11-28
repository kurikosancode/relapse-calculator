import 'package:expressions/expressions.dart';
import 'config.dart';

class MathEvaluator {
  static const int decimalShown = 5;
  final _evaluator = const ExpressionEvaluator();

  double evaluateValue(String currentOperation) {
    return _evaluator.eval(Expression.parse(currentOperation), {}).toDouble();
  }

  String evaluateAndFormat(String currentOperation) {
    double value = 0;
    try {
      value =
          _evaluator.eval(Expression.parse(currentOperation), {}).toDouble();
    } catch (error) {
      return errorMessage;
    }
    return value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(decimalShown);
  }
}
