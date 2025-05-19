final class PatternModel {
  final List<String>? values;

  PatternModel(this.values);

  factory PatternModel.fromStringList(List<dynamic> stringList) {
    return PatternModel(stringList.cast<String>());
  }
}
