import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppointmentDateSelectionWidget extends StatefulWidget {
  const AppointmentDateSelectionWidget({
    super.key,
    this.initialDate,
    this.onDateChanged,
  });
  final DateTime? initialDate;
  final Function(DateTime)? onDateChanged;
  @override
  State<AppointmentDateSelectionWidget> createState() =>
      _AppointmentDateSelectionWidgetState();
}

class _AppointmentDateSelectionWidgetState
    extends State<AppointmentDateSelectionWidget> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDateTime;
  // To prevent the logic from running on every rebuild, we use a flag.
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // initState should ONLY do things that DON'T require context.
    // So, we just set the initial date here.
    _selectedDateTime = widget.initialDate;
  }

  // --- THE MAIN FIX IS HERE ---
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This method is the safe place to use BuildContext for initialization.
    // We use a flag to ensure this logic runs only once, like initState.
    if (!_isInitialized) {
      _updateController(widget.initialDate);
      _isInitialized = true;
    }
  }

  @override
  void didUpdateWidget(covariant AppointmentDateSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _selectedDateTime = widget.initialDate;
      _updateController(widget.initialDate);
    }
  }

  void _updateController(DateTime? date) {
    if (date != null) {
      _controller.text = DateFormat(
        'dd.MM.yyyy',
        context.locale.languageCode,
      ).format(date);
    } else {
      _controller.text = '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await showModalBottomSheet<DateTime>(
          context: context,
          builder: (BuildContext context) {
            return _CustomCupertinoDatePicker(initialDate: _selectedDateTime);
          },
        );

        if (result != null && mounted) {
          setState(() {
            _selectedDateTime = result; // Önce local state'i güncelle
            _updateController(result); // Sonra controller'ı güncelle
          });
          widget.onDateChanged?.call(result); // Parent'a bildir
        }
      },
      child: AbsorbPointer(
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: LocaleKeys.forms_select_date.tr(),
            prefixIcon: const Icon(Icons.date_range_outlined),
            // border: const OutlineInputBorder(),
          ),
          child: Text(
            _controller.text.isEmpty ? ' ' : _controller.text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _controller.text.isEmpty ? Colors.transparent : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomCupertinoDatePicker extends StatefulWidget {
  final DateTime? initialDate;

  const _CustomCupertinoDatePicker({this.initialDate});

  @override
  State<_CustomCupertinoDatePicker> createState() =>
      _CustomCupertinoDatePickerState();
}

class _CustomCupertinoDatePickerState
    extends State<_CustomCupertinoDatePicker> {
  late DateTime _selectedDate;
  DateTime _normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    final minimumDate = _normalizeDate(now);

    _selectedDate = _normalizeDate(widget.initialDate ?? now);

    if (_selectedDate.isBefore(minimumDate)) {
      _selectedDate = minimumDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final minimumDate = _normalizeDate(DateTime.now());
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: minimumDate,
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                onDateTimeChanged: (newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  router.pop(_selectedDate);
                },
                child: Text(LocaleKeys.buttons_apply.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
