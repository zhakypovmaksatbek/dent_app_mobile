import 'dart:async';

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/record_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/pattern/pattern_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/input/def_text_field.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TreatmentInfoTab extends StatefulWidget {
  const TreatmentInfoTab({super.key, this.calendarAppointment});
  final CalendarAppointmentModel? calendarAppointment;

  @override
  State<TreatmentInfoTab> createState() => _TreatmentInfoTabState();
}

class _TreatmentInfoTabState extends State<TreatmentInfoTab> {
  // Constants
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const double _defaultCardSpacing = 12.0;
  static const int _defaultMaxLines = 4;

  // State variables
  RecordType? _recordType;
  late final PatternCubit _patternCubit;
  PatternType? _activePatternType;
  bool _isSearching = false;
  Timer? _debounceTimer;

  // Controllers and focus nodes
  final Map<PatternType, TextEditingController> _controllers = {};
  final Map<PatternType, FocusNode> _focusNodes = {};
  final TextEditingController _searchController = TextEditingController();

  TextEditingController get _complaintsController =>
      _controllers[PatternType.complaints]!;
  TextEditingController get _descriptionController =>
      _controllers[PatternType.descriptionAndComments]!;
  TextEditingController get _historyController =>
      _controllers[PatternType.previousAndConcomitantDiseases]!;
  TextEditingController get _labDataController =>
      _controllers[PatternType.xRayAndLaboratoryData]!;

  FocusNode get _complaintsFocusNode => _focusNodes[PatternType.complaints]!;
  FocusNode get _descriptionFocusNode =>
      _focusNodes[PatternType.descriptionAndComments]!;
  FocusNode get _historyFocusNode =>
      _focusNodes[PatternType.previousAndConcomitantDiseases]!;
  FocusNode get _labDataFocusNode =>
      _focusNodes[PatternType.xRayAndLaboratoryData]!;

  @override
  void initState() {
    super.initState();
    _recordType = RecordType.fromString(
      widget.calendarAppointment?.recordType ?? '',
    );
    _patternCubit = PatternCubit();

    _initializeControllers();
    _setupTextControllerListeners();
    _setupFocusNodeListeners();
  }

  void _initializeControllers() {
    // Initialize controllers for each pattern type
    _controllers[PatternType.complaints] = TextEditingController();
    _controllers[PatternType.descriptionAndComments] = TextEditingController();
    _controllers[PatternType.previousAndConcomitantDiseases] =
        TextEditingController();
    _controllers[PatternType.xRayAndLaboratoryData] = TextEditingController();

    // Initialize focus nodes for each pattern type
    _focusNodes[PatternType.complaints] = FocusNode();
    _focusNodes[PatternType.descriptionAndComments] = FocusNode();
    _focusNodes[PatternType.previousAndConcomitantDiseases] = FocusNode();
    _focusNodes[PatternType.xRayAndLaboratoryData] = FocusNode();
  }

  void _setupTextControllerListeners() {
    // Add listeners to all text controllers
    for (final entry in _controllers.entries) {
      final patternType = entry.key;
      final controller = entry.value;

      controller.addListener(() {
        final focusNode = _focusNodes[patternType];
        if (focusNode != null &&
            focusNode.hasFocus &&
            _activePatternType == patternType) {
          _debouncedSearch(controller.text);
        }
      });
    }
  }

  void _setupFocusNodeListeners() {
    // Add listeners to all focus nodes
    for (final entry in _focusNodes.entries) {
      final patternType = entry.key;
      final focusNode = entry.value;

      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          _setActivePatternType(patternType);
        }
      });
    }
  }

  void _setActivePatternType(PatternType type) {
    if (_activePatternType != type) {
      setState(() {
        _activePatternType = type;
      });

      // Load initial patterns with empty search
      _debouncedSearch('');
    }
  }

  Future<void> _debouncedSearch(String searchText) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer
    _debounceTimer = Timer(_debounceDuration, () {
      _searchPatterns(searchText);
    });
  }

  Future<void> _searchPatterns(String searchText) async {
    if (_activePatternType != null) {
      // Only search if the text has at least 2 characters or is empty (show all)
      if (searchText.isEmpty || searchText.length >= 2) {
        // Set loading state
        if (!_isSearching) {
          setState(() => _isSearching = true);
        }

        try {
          await _patternCubit.getPatternList(
            _activePatternType!,
            search: searchText.isEmpty ? null : searchText,
          );
        } finally {
          // Reset loading state
          if (mounted) {
            setState(() => _isSearching = false);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    // Cancel any pending search
    _debounceTimer?.cancel();

    // Dispose all controllers and focus nodes
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }

    _searchController.dispose();
    _patternCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _patternCubit,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            _buildTreatmentHeader(context),
            _buildDoctorInfo(context),
            _buildStatusSection(context),
            _buildExpandableTextField(
              context: context,
              title: LocaleKeys.appointment_complaints.tr(),
              hintText: 'Additional complaints...',
              controller: _complaintsController,
              focusNode: _complaintsFocusNode,
              patternType: PatternType.complaints,
            ),
            _buildExpandableTextField(
              context: context,
              title: LocaleKeys.report_description_comment.tr(),
              hintText: 'Enter treatment description and comments...',
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              patternType: PatternType.descriptionAndComments,
            ),
            _buildExpandableTextField(
              context: context,
              title: LocaleKeys.report_transferred_and_related_complaints.tr(),
              hintText: '',
              controller: _historyController,
              focusNode: _historyFocusNode,
              patternType: PatternType.previousAndConcomitantDiseases,
            ),
            _buildExpandableTextField(
              context: context,
              title: LocaleKeys.report_laboratory_and_radiological_data.tr(),
              hintText: '',
              controller: _labDataController,
              focusNode: _labDataFocusNode,
              patternType: PatternType.xRayAndLaboratoryData,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Shows a sheet for selecting predefined patterns/templates
  void _showPatternSelectionDialog(
    BuildContext context, {
    required PatternType patternType,
  }) {
    final TextEditingController controller = _controllers[patternType]!;
    final String title = _getTitleForPatternType(patternType);

    // Reset search controller
    _searchController.clear();

    setState(() {
      _activePatternType = patternType;
    });

    // Initial load of patterns without search
    _patternCubit.getPatternList(patternType);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (dialogContext) => _buildPatternSelectionSheet(
            context,
            patternType,
            controller,
            title,
          ),
    );
  }

  Widget _buildPatternSelectionSheet(
    BuildContext context,
    PatternType patternType,
    TextEditingController controller,
    String title,
  ) {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        // Local loading state for dialog
        bool isSheetSearching = false;

        return BlocProvider.value(
          value: _patternCubit,
          child: BlocBuilder<PatternCubit, PatternState>(
            builder: (context, state) {
              // Update local loading state based on cubit state
              isSheetSearching = state is PatternLoading;

              return DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSheetDragHandle(),
                        _buildSheetHeader(context, title),
                        const SizedBox(height: 16),
                        _buildSheetSearchBar(
                          context,
                          patternType,
                          isSheetSearching,
                          setSheetState,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildPatternListContent(
                            state,
                            controller,
                            scrollController: scrollController,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSheetDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSheetSearchBar(
    BuildContext context,
    PatternType patternType,
    bool isSearching,
    StateSetter setSheetState,
  ) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search patterns...',
        prefixIcon:
            isSearching
                ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(8),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.search),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setSheetState(() {
                      _searchController.clear();
                    });
                    _patternCubit.getPatternList(patternType);
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: (value) {
        // Use a local debounce for dialog search
        _debounceTimer?.cancel();
        _debounceTimer = Timer(_debounceDuration, () {
          if (value.isEmpty || value.length >= 2) {
            _patternCubit.getPatternList(
              patternType,
              search: value.isEmpty ? null : value,
            );
          }
        });
      },
    );
  }

  Widget _buildPatternListContent(
    PatternState state,
    TextEditingController controller, {
    ScrollController? scrollController,
  }) {
    if (state is PatternInitial) {
      return const Center(child: Text('Select pattern type'));
    } else if (state is PatternLoading) {
      return const Center(child: LoadingWidget());
    } else if (state is PatternError) {
      return Center(child: Text(state.message));
    } else if (state is PatternLoaded) {
      final List<String> patterns = state.pattern.values ?? [];

      if (patterns.isEmpty) {
        return const Center(child: Text('No data available'));
      }

      return ListView.separated(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: patterns.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final pattern = patterns[index];
          return InkWell(
            onTap: () {
              // Insert the pattern text
              _insertPattern(controller, pattern);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Text(pattern, style: const TextStyle(fontSize: 16)),
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('Unknown state'));
    }
  }

  void _insertPattern(TextEditingController controller, String pattern) {
    if (controller.text.isEmpty) {
      controller.text = pattern;
    } else {
      // Insert at cursor position if possible
      if (controller.selection.isValid) {
        final int start = controller.selection.start;
        final int end = controller.selection.end;
        final String newText =
            controller.text.substring(0, start) +
            pattern +
            controller.text.substring(end);
        controller.text = newText;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: start + pattern.length),
        );
      } else {
        // Append to end if no selection
        controller.text = '${controller.text}\n$pattern';
      }
    }
  }

  String _getTitleForPatternType(PatternType patternType) {
    switch (patternType) {
      case PatternType.complaints:
        return LocaleKeys.appointment_complaints.tr();
      case PatternType.descriptionAndComments:
        return LocaleKeys.report_description_comment.tr();
      case PatternType.previousAndConcomitantDiseases:
        return LocaleKeys.report_transferred_and_related_complaints.tr();
      case PatternType.xRayAndLaboratoryData:
        return LocaleKeys.report_laboratory_and_radiological_data.tr();
      default:
        return '';
    }
  }

  Widget _buildTreatmentHeader(BuildContext context) {
    final today = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Treatment Plan',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(today),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  timeFormat.format(today),
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo(BuildContext context) {
    final doctorName =
        '${widget.calendarAppointment?.doctorFirsName ?? ''} '
        '${widget.calendarAppointment?.doctorLastName ?? ''}';

    return _buildInfoCard(
      title: LocaleKeys.report_treatment_doctor.tr(),
      icon: Icons.person,
      content: AppText(
        title: doctorName.trim().isEmpty ? 'Not assigned' : doctorName,
        textType: TextType.body,
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return _buildInfoCard(
      title: LocaleKeys.appointment_status_label.tr(),
      icon: null,
      content: DropdownButtonFormField<RecordType>(
        decoration: InputDecoration(
          labelText: LocaleKeys.appointment_appointment_type_label.tr(),
          prefixIcon: const Icon(Icons.category),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        value: _recordType,

        items:
            RecordType.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,

                    child: Text(e.displayName.tr()),
                  ),
                )
                .toList(),
        onChanged: (value) => setState(() => _recordType = value),
      ),
    );
  }

  /// Creates a consistent card with a title and content
  Widget _buildInfoCard({
    required String title,
    required Widget content,
    IconData? icon,
    double spacing = _defaultCardSpacing,
  }) {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 24, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content,
          ],
        ),
      ),
    );
  }

  /// Creates an expandable text field with a title and dropdown button
  Widget _buildExpandableTextField({
    required BuildContext context,
    required String title,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required PatternType patternType,
    int maxLines = _defaultMaxLines,
  }) {
    return _buildInfoCard(
      title: title,
      icon: null,
      content: Focus(
        focusNode: focusNode,
        child: DefTextField(
          controller: controller,
          maxLines: maxLines,
          minLines: 1,
          onChanged: (_) {
            // This will trigger the controller listener
            // which will in turn call _searchPatterns if the field has focus
          },
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: GestureDetector(
              onTap:
                  () => _showPatternSelectionDialog(
                    context,
                    patternType: patternType,
                  ),
              child: const Icon(Icons.keyboard_arrow_down_sharp),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
