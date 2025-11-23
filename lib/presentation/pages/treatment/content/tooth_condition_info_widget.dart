import 'package:dent_app_mobile/models/work/appointment_work_model.dart';
// ToothType enum'unun bulunduğu dosya yolunu buraya ekleyin
import 'package:dent_app_mobile/presentation/pages/treatment/utils/tooth_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToothConditionInfoWidget extends StatelessWidget {
  final ToothResponse? toothResponse;

  const ToothConditionInfoWidget({super.key, required this.toothResponse});

  @override
  Widget build(BuildContext context) {
    if (toothResponse == null) return const SizedBox.shrink();

    // Dolu olan tüm verileri ToothType başlıklarıyla listeye alıyoruz
    final List<_ConditionItem> items = _getAllConditions();

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12, // Kartlar arası yatay boşluk
          runSpacing: 12, // Kartlar arası dikey boşluk
          children: items
              .map((item) => _buildConditionCard(context, item))
              .toList(),
        ),
      ],
    );
  }

  /// Tüm diş verilerini kontrol edip ToothType başlıklarıyla listeye ekler
  List<_ConditionItem> _getAllConditions() {
    final List<_ConditionItem> items = [];

    // Modelden gelen parçalar
    final main = toothResponse?.main;
    final jow = toothResponse?.jow; // JSON'da jow alanı da vardı
    final inner = toothResponse?.innerToothResponse;

    // 1. Ana Durum (MAIN)
    if (_isValid(main)) {
      items.add(
        _ConditionItem(
          title: ToothType.main.title, // LocaleKeys.tooth_main.tr()
          value: main!.name!,
          colorHex: main.color,
          icon: Icons.healing,
        ),
      );
    }

    // 2. Çene / Diş Eti (JAW)
    if (_isValid(jow)) {
      items.add(
        _ConditionItem(
          title: ToothType.jaw.title, // LocaleKeys.tooth_jaw.tr()
          value: jow!.name!,
          colorHex: jow.color,
          icon: Icons.grid_on, // Veya uygun baska bir ikon
        ),
      );
    }

    // 3. Diş Yüzeyleri (Inner)
    if (inner != null) {
      if (_isValid(inner.top)) {
        items.add(
          _ConditionItem(
            title: ToothType.top.title, // LocaleKeys.tooth_top.tr()
            value: inner.top!.name!,
            colorHex: inner.top!.color,
            icon: CupertinoIcons.arrow_up,
          ),
        );
      }
      if (_isValid(inner.bottom)) {
        items.add(
          _ConditionItem(
            title: ToothType.bottom.title, // LocaleKeys.tooth_bottom.tr()
            value: inner.bottom!.name!,
            colorHex: inner.bottom!.color,
            icon: CupertinoIcons.arrow_down,
          ),
        );
      }
      if (_isValid(inner.left)) {
        items.add(
          _ConditionItem(
            title: ToothType.left.title, // LocaleKeys.tooth_left.tr()
            value: inner.left!.name!,
            colorHex: inner.left!.color,
            icon: CupertinoIcons.arrow_left,
          ),
        );
      }
      if (_isValid(inner.right)) {
        items.add(
          _ConditionItem(
            title: ToothType.right.title, // LocaleKeys.tooth_right.tr()
            value: inner.right!.name!,
            colorHex: inner.right!.color,
            icon: CupertinoIcons.arrow_right,
          ),
        );
      }
      if (_isValid(inner.centerLeft)) {
        items.add(
          _ConditionItem(
            title:
                ToothType.centerLeft.title, // LocaleKeys.tooth_center_left.tr()
            value: inner.centerLeft!.name!,
            colorHex: inner.centerLeft!.color,
            icon: CupertinoIcons.add,
          ),
        );
      }
      if (_isValid(inner.centerRight)) {
        items.add(
          _ConditionItem(
            title: ToothType
                .centerRight
                .title, // LocaleKeys.tooth_center_right.tr()
            value: inner.centerRight!.name!,
            colorHex: inner.centerRight!.color,
            icon: CupertinoIcons.add,
          ),
        );
      }
    }

    return items;
  }

  /// Verinin geçerli olup olmadığını kontrol eder (null ve boş string kontrolü)
  bool _isValid(Jow? jow) {
    return jow?.name != null && jow!.name!.isNotEmpty;
  }

  Widget _buildConditionCard(BuildContext context, _ConditionItem item) {
    final color = _parseColor(item.colorHex);
    // Responsive genişlik: Mobilde yan yana 2 tane sığacak şekilde (Paddingleri çıkarıp 2'ye bölüyoruz)
    // Parent padding: 32 (16 sol + 16 sağ) + Wrap spacing: 12 = Yaklaşık 44-48 çıkarıyoruz.
    final double cardWidth = (MediaQuery.of(context).size.width - 48) / 2;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.grey;
    try {
      final buffer = StringBuffer();
      if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
      buffer.write(hexColor.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}

/// Helper sınıf: Verileri düzenli tutmak için
class _ConditionItem {
  final String title;
  final String value;
  final String? colorHex;
  final IconData icon;

  _ConditionItem({
    required this.title,
    required this.value,
    required this.colorHex,
    required this.icon,
  });
}
