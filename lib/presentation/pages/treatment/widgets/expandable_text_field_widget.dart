import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/speech_to_text_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/input/def_text_field.dart';
import 'package:flutter/material.dart';

class ExpandableTextFieldWidget extends StatelessWidget {
  const ExpandableTextFieldWidget({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.patternType,
    required this.onPatternTap,
    this.maxLines = 4,
    this.enableSpeechToText = true,
  });

  final String title;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final PatternType patternType;
  final VoidCallback onPatternTap;
  final int maxLines;
  final bool enableSpeechToText;

  void _onSpeechResult(String text) {
    if (text.isNotEmpty) {
      // Insert speech result at cursor position or append
      final currentText = controller.text;
      final selection = controller.selection;

      if (selection.isValid) {
        final newText = currentText.replaceRange(
          selection.start,
          selection.end,
          text,
        );
        controller.value = controller.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(
            offset: selection.start + text.length,
          ),
        );
      } else {
        // Append to current text
        final newText = currentText.isEmpty ? text : '$currentText $text';
        controller.text = newText;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12.0,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Focus(
          focusNode: focusNode,
          child: DefTextField(
            controller: controller,
            maxLines: maxLines,
            minLines: 1,
            onTapOutside: (event) {
              focusNode.unfocus();
            },
            onChanged: (_) {
              // This will trigger the controller listener
              // which will in turn call _searchPatterns if the field has focus
            },
            decoration: InputDecoration(
              hintText: hintText,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speech to Text button
                  if (enableSpeechToText) ...[
                    SpeechToTextWidget(onResult: _onSpeechResult, size: 20),
                    const SizedBox(width: 8),
                  ],
                  // Pattern selection button
                  GestureDetector(
                    onTap: onPatternTap,
                    child: const Icon(Icons.keyboard_arrow_down_sharp),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
