import 'dart:async';

import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:flutter/material.dart';

class TreatmentFormController {
  // Constants
  static const Duration debounceDuration = Duration(milliseconds: 500);

  // Controllers and focus nodes
  final Map<PatternType, TextEditingController> _controllers = {};
  final Map<PatternType, FocusNode> _focusNodes = {};

  // State
  PatternType? _activePatternType;
  bool _isSearching = false;
  Timer? _debounceTimer;

  // Getters for specific controllers
  TextEditingController get complaintsController =>
      _controllers[PatternType.complaints]!;
  TextEditingController get descriptionController =>
      _controllers[PatternType.descriptionAndComments]!;
  TextEditingController get historyController =>
      _controllers[PatternType.previousAndConcomitantDiseases]!;
  TextEditingController get labDataController =>
      _controllers[PatternType.xRayAndLaboratoryData]!;
  TextEditingController get treatmentController =>
      _controllers[PatternType.treatment]!;
  TextEditingController get surveyPlanController =>
      _controllers[PatternType.surveyPlan]!;
  TextEditingController get recommendationController =>
      _controllers[PatternType.recommendation]!;

  // Getters for specific focus nodes
  FocusNode get complaintsFocusNode => _focusNodes[PatternType.complaints]!;
  FocusNode get descriptionFocusNode =>
      _focusNodes[PatternType.descriptionAndComments]!;
  FocusNode get historyFocusNode =>
      _focusNodes[PatternType.previousAndConcomitantDiseases]!;
  FocusNode get labDataFocusNode =>
      _focusNodes[PatternType.xRayAndLaboratoryData]!;
  FocusNode get treatmentFocusNode => _focusNodes[PatternType.treatment]!;
  FocusNode get surveyPlanFocusNode => _focusNodes[PatternType.surveyPlan]!;
  FocusNode get recommendationFocusNode =>
      _focusNodes[PatternType.recommendation]!;

  // State getters
  PatternType? get activePatternType => _activePatternType;
  bool get isSearching => _isSearching;

  TreatmentFormController() {
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize controllers for each pattern type
    _controllers[PatternType.complaints] = TextEditingController();
    _controllers[PatternType.descriptionAndComments] = TextEditingController();
    _controllers[PatternType.previousAndConcomitantDiseases] =
        TextEditingController();
    _controllers[PatternType.xRayAndLaboratoryData] = TextEditingController();
    _controllers[PatternType.treatment] = TextEditingController();
    _controllers[PatternType.surveyPlan] = TextEditingController();
    _controllers[PatternType.recommendation] = TextEditingController();
    // Initialize focus nodes for each pattern type
    _focusNodes[PatternType.complaints] = FocusNode();
    _focusNodes[PatternType.descriptionAndComments] = FocusNode();
    _focusNodes[PatternType.previousAndConcomitantDiseases] = FocusNode();
    _focusNodes[PatternType.xRayAndLaboratoryData] = FocusNode();
    _focusNodes[PatternType.treatment] = FocusNode();
    _focusNodes[PatternType.surveyPlan] = FocusNode();
    _focusNodes[PatternType.recommendation] = FocusNode();
  }

  void setupTextControllerListeners(Function(String) onTextChanged) {
    // Add listeners to all text controllers
    for (final entry in _controllers.entries) {
      final patternType = entry.key;
      final controller = entry.value;

      controller.addListener(() {
        final focusNode = _focusNodes[patternType];
        if (focusNode != null &&
            focusNode.hasFocus &&
            _activePatternType == patternType) {
          _debouncedSearch(controller.text, onTextChanged);
        }
      });
    }
  }

  void setupFocusNodeListeners(Function(PatternType) onFocusChanged) {
    // Add listeners to all focus nodes
    for (final entry in _focusNodes.entries) {
      final patternType = entry.key;
      final focusNode = entry.value;

      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          setActivePatternType(patternType, onFocusChanged);
        }
      });
    }
  }

  void setActivePatternType(PatternType type, Function(PatternType) onChanged) {
    if (_activePatternType != type) {
      _activePatternType = type;
      onChanged(type);
    }
  }

  void _debouncedSearch(String searchText, Function(String) onSearch) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer
    _debounceTimer = Timer(debounceDuration, () {
      onSearch(searchText);
    });
  }

  void setSearching(bool searching) {
    _isSearching = searching;
  }

  void insertPattern(TextEditingController controller, String pattern) {
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
  }
}
