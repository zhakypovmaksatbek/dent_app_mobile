import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum DateRangeOption {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisQuarter,
  thisYear,
  lastYear,
  last30Days,
  last90Days,
  custom,
}

class DateRangePicker extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime startDate, DateTime endDate) onDateRangeChanged;

  const DateRangePicker({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeChanged,
  });

  @override
  State<DateRangePicker> createState() => DateRangePickerState();
}

class DateRangePickerState extends State<DateRangePicker> {
  // Public method to show the date range menu
  void showDateRangeMenu() {
    _showMenu(context);
  }

  void _showMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(const Offset(0, 0), ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<DateRangeOption>(
      context: context,
      position: position,
      items: [
        _buildPopupMenuItem(
          DateRangeOption.today,
          LocaleKeys.date_range_today.tr(),
        ),
        _buildPopupMenuItem(
          DateRangeOption.yesterday,
          LocaleKeys.date_range_yesterday.tr(),
        ),
        _buildPopupMenuItem(
          DateRangeOption.thisWeek,
          LocaleKeys.date_range_this_week.tr(),
        ),
        _buildPopupMenuItem(
          DateRangeOption.lastWeek,
          LocaleKeys.date_range_last_week.tr(),
        ),
        _buildPopupMenuItem(
          DateRangeOption.thisMonth,
          LocaleKeys.date_range_this_month.tr(),
        ),
        _buildPopupMenuItem(
          DateRangeOption.lastMonth,
          LocaleKeys.date_range_last_month.tr(),
        ),
        _buildPopupMenuItem(
          DateRangeOption.thisQuarter,
          LocaleKeys.date_range_this_quarter.tr(),
        ),
        _buildPopupMenuItem(
          DateRangeOption.thisYear,
          LocaleKeys.date_range_this_year.tr(),
        ),
        _buildPopupMenuItem(
          DateRangeOption.lastYear,
          LocaleKeys.date_range_last_year.tr(),
        ),
        _buildPopupMenuItem(
          DateRangeOption.last30Days,
          LocaleKeys.date_range_last_30_days.tr(),
        ),
        _buildPopupMenuItem(
          DateRangeOption.last90Days,
          LocaleKeys.date_range_last_90_days.tr(),
        ),
        _buildPopupMenuItem(
          DateRangeOption.custom,
          LocaleKeys.date_range_custom_range.tr(),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _selectPredefinedDateRange(context, value);
      }
    });
  }

  PopupMenuItem<DateRangeOption> _buildPopupMenuItem(
    DateRangeOption option,
    String text,
  ) {
    return PopupMenuItem<DateRangeOption>(value: option, child: Text(text));
  }

  void _selectPredefinedDateRange(
    BuildContext context,
    DateRangeOption option,
  ) {
    DateTime newStartDate = widget.startDate;
    DateTime newEndDate = widget.endDate;

    switch (option) {
      case DateRangeOption.today:
        newStartDate = DateTime.now();
        newEndDate = DateTime.now();
        break;
      case DateRangeOption.yesterday:
        newStartDate = DateTime.now().subtract(const Duration(days: 1));
        newEndDate = DateTime.now().subtract(const Duration(days: 1));
        break;
      case DateRangeOption.thisWeek:
        final now = DateTime.now();
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
        newStartDate = DateTime(
          firstDayOfWeek.year,
          firstDayOfWeek.month,
          firstDayOfWeek.day,
        );
        newEndDate = DateTime.now();
        break;
      case DateRangeOption.lastWeek:
        final now = DateTime.now();
        final firstDayOfLastWeek = now.subtract(
          Duration(days: now.weekday + 6),
        );
        final lastDayOfLastWeek = now.subtract(Duration(days: now.weekday));
        newStartDate = DateTime(
          firstDayOfLastWeek.year,
          firstDayOfLastWeek.month,
          firstDayOfLastWeek.day,
        );
        newEndDate = DateTime(
          lastDayOfLastWeek.year,
          lastDayOfLastWeek.month,
          lastDayOfLastWeek.day,
        );
        break;
      case DateRangeOption.thisMonth:
        final now = DateTime.now();
        newStartDate = DateTime(now.year, now.month, 1);
        newEndDate = DateTime.now();
        break;
      case DateRangeOption.lastMonth:
        final now = DateTime.now();
        newStartDate = DateTime(now.year, now.month - 1, 1);
        newEndDate = DateTime(now.year, now.month, 0);
        break;
      case DateRangeOption.thisQuarter:
        final now = DateTime.now();
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        newStartDate = DateTime(now.year, (currentQuarter - 1) * 3 + 1, 1);
        newEndDate = DateTime.now();
        break;
      case DateRangeOption.thisYear:
        final now = DateTime.now();
        newStartDate = DateTime(now.year, 1, 1);
        newEndDate = DateTime.now();
        break;
      case DateRangeOption.lastYear:
        final now = DateTime.now();
        newStartDate = DateTime(now.year - 1, 1, 1);
        newEndDate = DateTime(now.year - 1, 12, 31);
        break;
      case DateRangeOption.last30Days:
        newStartDate = DateTime.now().subtract(const Duration(days: 30));
        newEndDate = DateTime.now();
        break;
      case DateRangeOption.last90Days:
        newStartDate = DateTime.now().subtract(const Duration(days: 90));
        newEndDate = DateTime.now();
        break;
      case DateRangeOption.custom:
        _showCustomDateRangePicker(context);
        return; // Don't call onDateRangeChanged yet
    }

    widget.onDateRangeChanged(newStartDate, newEndDate);
  }

  Future<void> _showCustomDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: widget.startDate,
        end: widget.endDate,
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorConstants.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateRangeChanged(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => _showMenu(context),
          icon: const Icon(Icons.calendar_today, size: 18),
          label: Text(
            '${DateFormat('d MMM yyyy').format(widget.startDate)} - ${DateFormat('d MMM yyyy').format(widget.endDate)}',
            style: const TextStyle(fontSize: 14),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ],
    );
  }
}
