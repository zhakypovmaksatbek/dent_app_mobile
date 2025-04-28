import 'package:dent_app_mobile/core/repo/hear_beats/heart_beats_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DateTypeDropdown extends StatefulWidget {
  final void Function(DateType) onChanged;
  final DateType? initialValue;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final BoxDecoration? decoration;

  const DateTypeDropdown({
    super.key,
    required this.onChanged,
    this.initialValue,
    this.width,
    this.padding,
    this.textStyle,
    this.decoration,
  });

  @override
  State<DateTypeDropdown> createState() => _DateTypeDropdownState();
}

class _DateTypeDropdownState extends State<DateTypeDropdown> {
  late DateType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialValue ?? DateType.week;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      decoration:
          widget.decoration ??
          BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
          ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<DateType>(
            value: _selectedType,
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            elevation: 3,
            style:
                widget.textStyle ??
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
            items: _buildDropdownItems(theme),
            onChanged: _handleTypeChange,
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<DateType>> _buildDropdownItems(ThemeData theme) {
    return DateType.values.map((type) {
      return DropdownMenuItem<DateType>(
        value: type,
        child: Row(
          children: [
            _buildItemIcon(type, theme),
            const SizedBox(width: 8),
            Text(
              type.title.tr(),
              style:
                  widget.textStyle ??
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildItemIcon(DateType type, ThemeData theme) {
    IconData icon;
    switch (type) {
      case DateType.week:
        icon = Icons.calendar_view_week;
        break;
      case DateType.month:
        icon = Icons.calendar_view_month;
        break;
      case DateType.year:
        icon = Icons.calendar_today;
        break;
    }

    return Icon(icon, size: 18, color: theme.colorScheme.primary);
  }

  void _handleTypeChange(DateType? newType) {
    if (newType != null && newType != _selectedType) {
      setState(() => _selectedType = newType);
      widget.onChanged(newType);
    }
  }
}

// Extension for DateType
extension DateTypeExtension on DateType {
  String get title {
    switch (this) {
      case DateType.week:
        return LocaleKeys.general_week;
      case DateType.month:
        return LocaleKeys.general_month;
      case DateType.year:
        return LocaleKeys.general_year;
    }
  }

  String get apiValue {
    switch (this) {
      case DateType.week:
        return 'week';
      case DateType.month:
        return 'month';
      case DateType.year:
        return 'year';
    }
  }
}
