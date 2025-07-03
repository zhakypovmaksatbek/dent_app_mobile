enum ToothType {
  main(key: 'MAIN'),
  right(key: 'RIGHT'),
  left(key: 'LEFT'),
  top(key: 'TOP'),
  bottom(key: 'BOTTOM'),
  jaw(key: 'JAW'),
  centerRight(key: 'CENTER_RIGHT'),
  centerLeft(key: 'CENTER_LEFT'),
  all(key: 'ALL');

  final String key;

  const ToothType({required this.key});
}

extension ToothTypeExtension on ToothType {
  String get title {
    switch (this) {
      case ToothType.main:
        return 'Основной зуб';
      case ToothType.right:
        return 'Правая сторона';
      case ToothType.left:
        return 'Левая сторона';
      case ToothType.top:
        return 'Верхняя часть';
      case ToothType.bottom:
        return 'Нижняя часть';
      case ToothType.jaw:
        return 'Челюсть';
      case ToothType.centerRight:
        return 'Центр справа';
      case ToothType.centerLeft:
        return 'Центр слева';
      case ToothType.all:
        return 'Все';
    }
  }
}
