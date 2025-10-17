class SpinEntry {
  final String id;
  final String type; // 'text' or 'image'
  final String value;
  final String gradientStart;
  final String gradientEnd;

  SpinEntry({
    required this.id,
    required this.type,
    required this.value,
    required this.gradientStart,
    required this.gradientEnd,
  });

  static List<List<String>> gradients = [
    ['#FF6B9D', '#C44569'],
    ['#00D2FF', '#3A7BD5'],
    ['#FDC830', '#F37335'],
    ['#A8E063', '#56AB2F'],
    ['#FA709A', '#FEE140'],
    ['#667EEA', '#764BA2'],
    ['#F093FB', '#F5576C'],
    ['#4FACFE', '#00F2FE'],
  ];

  static SpinEntry createText(String text, int index) {
    final gradient = gradients[index % gradients.length];
    return SpinEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'text',
      value: text,
      gradientStart: gradient[0],
      gradientEnd: gradient[1],
    );
  }

  static SpinEntry createImage(String imagePath, int index) {
    final gradient = gradients[index % gradients.length];
    return SpinEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'image',
      value: imagePath,
      gradientStart: gradient[0],
      gradientEnd: gradient[1],
    );
  }
}