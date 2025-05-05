import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DurationSelector extends StatelessWidget {
  final List<int> minuteOptions;
  final int selectedMinute;
  final bool enabled;
  final Function(int) onDurationSelected;

  const DurationSelector({
    super.key,
    required this.minuteOptions,
    required this.selectedMinute,
    required this.enabled,
    required this.onDurationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            color: Colors.grey[100],
            child: Icon(Icons.timer, color: Colors.grey[600]),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children:
                    minuteOptions.map((duration) {
                      final isSelected = selectedMinute == duration;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(
                            '$duration ${LocaleKeys.general_minutes.tr()}',
                          ),
                          selected: isSelected,
                          onSelected:
                              enabled
                                  ? (selected) {
                                    if (selected) {
                                      onDurationSelected(duration);
                                    }
                                  }
                                  : null,
                          backgroundColor: Colors.grey[100],
                          selectedColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : enabled
                                    ? Colors.black
                                    : Colors.grey,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
