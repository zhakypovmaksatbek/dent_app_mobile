import 'package:dent_app_mobile/presentation/widgets/teeth_selector/svg.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

// Veri Modeli
typedef Data = ({Size size, Map<String, Tooth> teeth});

class CustomTeethSelector extends StatefulWidget {
  final bool multiSelect;
  final Color selectedColor;
  final Color unselectedColor;
  final Color tooltipColor;
  final List<String> initiallySelected;
  final Map<String, Color> colorized;
  final Map<String, Color> StrokedColorized;
  final Color defaultStrokeColor;
  final Map<String, double> strokeWidth;
  final double defaultStrokeWidth;
  final String leftString;
  final String rightString;
  final bool showPrimary;
  final bool showPermanent;
  final void Function(List<String> selected) onChange;
  final String Function(String isoString)? notation;
  final TextStyle? textStyle;
  final TextStyle? tooltipTextStyle;

  const CustomTeethSelector({
    super.key,
    this.multiSelect = false,
    this.selectedColor = Colors.blue,
    this.unselectedColor = const Color(0xFFE0E0E0), // Biraz daha açık gri
    this.tooltipColor = Colors.black,
    this.initiallySelected = const [],
    this.colorized = const {},
    this.StrokedColorized = const {},
    this.defaultStrokeColor = Colors.black54,
    this.strokeWidth = const {},
    this.defaultStrokeWidth = 1.0,
    this.notation,
    this.showPrimary = false,
    this.showPermanent = true,
    this.leftString = "Left",
    this.rightString = "Right",
    this.textStyle,
    this.tooltipTextStyle,
    required this.onChange,
  });

  @override
  State<CustomTeethSelector> createState() => _CustomTeethSelectorState();
}

class _CustomTeethSelectorState extends State<CustomTeethSelector> {
  late Data data;

  @override
  void initState() {
    super.initState();
    data = loadTeeth(); // SVG'yi işle

    // Başlangıç seçimlerini ayarla
    for (var element in widget.initiallySelected) {
      if (data.teeth[element] != null) {
        data.teeth[element]!.selected = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.size == Size.zero) return const SizedBox();

    return FittedBox(
      child: SizedBox.fromSize(
        size: data.size,
        child: Stack(
          children: [
            // Sol - Sağ Etiketleri
            Positioned(
              left: 0,
              top: data.size.height * 0.475,
              child: Text(
                widget.rightString,
                style: widget.textStyle ?? const TextStyle(fontSize: 16),
              ),
            ),
            Positioned(
              right: 0,
              top: data.size.height * 0.475,
              child: Text(
                widget.leftString,
                style: widget.textStyle ?? const TextStyle(fontSize: 16),
              ),
            ),

            // --- DİŞLER VE NUMARALAR DÖNGÜSÜ ---
            for (final MapEntry(key: key, value: tooth) in data.teeth.entries)
              // Filtreleme (Süt dişi mi Kalıcı diş mi?)
              if ((widget.showPrimary || int.parse(key) < 50) &&
                  (widget.showPermanent || int.parse(key) > 50)) ...[
                // 1. KATMAN: Dişin Kendisi (Çizim)
                Positioned.fromRect(
                  rect: tooth.rect,
                  child: GestureDetector(
                    key: Key("tooth-$key"),
                    onTap: () {
                      setState(() {
                        if (!widget.multiSelect) {
                          // Çoklu seçim kapalıysa diğerlerini temizle
                          for (final t in data.teeth.values) {
                            if (t != tooth) t.selected = false;
                          }
                        }
                        tooth.selected = !tooth.selected;

                        // Callback tetikle
                        widget.onChange(
                          data.teeth.entries
                              .where((t) => t.value.selected)
                              .map((t) => t.key)
                              .toList(),
                        );
                      });
                    },
                    child: Tooltip(
                      message: widget.notation?.call(key) ?? key,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: ShapeDecoration(
                          // Seçiliyse renkli, değilse varsayılan
                          color: tooth.selected
                              ? widget.selectedColor
                              : widget.colorized[key] ?? widget.unselectedColor,
                          shape: ToothBorder(
                            tooth.path,
                            strokeColor:
                                widget.StrokedColorized[key] ??
                                widget.defaultStrokeColor,
                            strokeWidth:
                                widget.strokeWidth[key] ??
                                widget.defaultStrokeWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. KATMAN: Diş Numarası (Figma'dan gelen koordinata göre)
                Builder(
                  builder: (context) {
                    // Figma'dan gelen nokta (varsa) yoksa dişin merkezi
                    final Offset labelPos =
                        tooth.labelPosition ?? tooth.rect.center;

                    return Positioned(
                      // Nokta merkez olduğu için genişliğin yarısını çıkarıyoruz
                      left: labelPos.dx - 15,
                      top: labelPos.dy - 10,
                      width: 30,
                      height: 20,
                      child: IgnorePointer(
                        ignoring:
                            true, // Tıklamayı engelleme, arkadaki dişe geçsin
                        child: Center(
                          child: Text(
                            widget.notation?.call(key) ?? key,
                            style: TextStyle(
                              fontSize: 10, // Font boyutu
                              fontWeight: FontWeight.bold,
                              // Diş seçiliyse yazı beyaz olsun
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
          ],
        ),
      ),
    );
  }
}

// --- DATA PARSING & MODELS ---

class Tooth {
  Tooth(Path originalPath) {
    rect = originalPath.getBounds();
    // Path'i (0,0) noktasına taşı ki Positioned içinde düzgün dursun
    path = originalPath.shift(-rect.topLeft);
    labelPosition = rect.center; // Varsayılan değer
  }

  late final Path path;
  late final Rect rect;
  bool selected = false;
  Offset? labelPosition; // Figma'dan okunan pos-XX koordinatı
}

Data loadTeeth() {
  final doc = XmlDocument.parse(svgString);
  final viewBox = doc.rootElement.getAttribute('viewBox')!.split(' ');
  final w = double.parse(viewBox[2]);
  final h = double.parse(viewBox[3]);

  final Map<String, Tooth> teethMap = {};

  // 1. Önce DİŞLERİ (Path) bul ve oluştur
  final paths = doc.findAllElements('path');
  for (final element in paths) {
    final String? id = element.getAttribute('id');
    final String? d = element.getAttribute('d');

    if (id != null && d != null && int.tryParse(id) != null) {
      teethMap[id] = Tooth(parseSvgPathData(d));
    }
  }

  // 2. Sonra NOKTALARI (Circle) bul ve dişlere ata
  final circles = doc.findAllElements('circle');
  for (final element in circles) {
    final String? id = element.getAttribute('id');
    final String? cx = element.getAttribute('cx');
    final String? cy = element.getAttribute('cy');

    if (id != null && id.startsWith('pos-') && cx != null && cy != null) {
      // ID temizle: "pos-11" -> "11"
      String toothId = id.replaceAll('pos-', '');

      if (teethMap.containsKey(toothId)) {
        teethMap[toothId]!.labelPosition = Offset(
          double.parse(cx),
          double.parse(cy),
        );
      }
    }
  }

  return (size: Size(w, h), teeth: teethMap);
}

class ToothBorder extends ShapeBorder {
  final Path path;
  final double strokeWidth;
  final Color strokeColor;

  const ToothBorder(
    this.path, {
    required this.strokeWidth,
    required this.strokeColor,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return rect.topLeft == Offset.zero ? path : path.shift(rect.topLeft);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = strokeColor;
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
