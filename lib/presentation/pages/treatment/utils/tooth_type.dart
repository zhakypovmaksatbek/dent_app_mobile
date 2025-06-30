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
