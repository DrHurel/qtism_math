class StringFormatter {
  /// Replaces placeholders {0}, {1}, etc. in the template with the provided values
  static String format(String template, List<dynamic> values) {
    String result = template;
    for (int i = 0; i < values.length; i++) {
      result = result.replaceAll('{$i}', values[i].toString());
    }
    return result;
  }
}