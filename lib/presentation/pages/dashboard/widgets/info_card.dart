// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/heartbeats/heart_beats_model.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';

class InfoCard extends StatefulWidget {
  const InfoCard({
    super.key,
    required this.serviceMade,
    required this.title,
    required this.subtitle,
    this.icon = Icons.star,
    this.frontColor = ColorConstants.primary,
    this.backColor = ColorConstants.grey,
    this.iconColor = Colors.white,
    this.textColor = Colors.black,
    this.isInfographic = false,
    this.isWorkingHours = false,
  });

  final ServiceMade serviceMade;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color frontColor;
  final Color backColor;
  final Color iconColor;
  final Color textColor;
  final bool isInfographic;
  final bool isWorkingHours;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  late final FlipCardController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = FlipCardController();
  }

  Color get _differenceColor =>
      widget.serviceMade.exceeds == true ? Colors.green : Colors.red;

  IconData get _differenceIcon =>
      widget.serviceMade.exceeds == true
          ? Icons.arrow_upward
          : Icons.arrow_downward;

  Widget _buildAnimatedTitle(String text) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: widget.textColor,
            letterSpacing: 0.5,
            height: 1.2,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: .1),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          speed: const Duration(milliseconds: 50),
        ),
      ],
      totalRepeatCount: 1,
      pause: const Duration(milliseconds: 50),
      displayFullTextOnTap: true,
      stopPauseOnTap: true,
    );
  }

  Widget _buildAnimatedSubtitle(String text) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: widget.textColor.withValues(alpha: .8),
            letterSpacing: 0.3,
            height: 1.4,
          ),
          speed: const Duration(milliseconds: 50),
        ),
      ],
      totalRepeatCount: 1,
      pause: const Duration(milliseconds: 50),
      displayFullTextOnTap: true,
      stopPauseOnTap: true,
    );
  }

  Widget _buildValueRow() {
    return Row(
      children: [
        AnimatedTextKit(
          key: Key(widget.serviceMade.current.toString()),
          animatedTexts: [
            WavyAnimatedText(
              widget.serviceMade.current.toString(),
              textStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'sans-serif',
                color: widget.textColor,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: .2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
          isRepeatingAnimation: false,
        ),
        const SizedBox(width: 8),
        if (widget.isInfographic)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _differenceColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(_differenceIcon, color: _differenceColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  !widget.isInfographic
                      ? ""
                      : convertToNumber(
                        widget.serviceMade.current!,
                        widget.serviceMade.difference!,
                      ),
                  style: TextStyle(
                    fontSize: 14,
                    color: _differenceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String convertToNumber(String newCurrent, String newDifference) {
    final int current = int.parse(newCurrent);
    final int difference = int.parse(newDifference);
    return (current - difference).toString();
  }

  Widget _buildIconContainer() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: widget.iconColor.withValues(alpha: .2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(widget.icon, color: widget.iconColor, size: 24),
    );
  }

  Widget _buildCardContent(Color backgroundColor) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: .2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, backgroundColor.withValues(alpha: .8)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedTitle(widget.title),
                        const SizedBox(height: 12),
                        _buildValueRow(),
                      ],
                    ),
                  ),
                  _buildIconContainer(),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                alignment: Alignment.centerLeft,
                child: _buildAnimatedSubtitle(widget.subtitle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      controller: _flipController,
      rotateSide: RotateSide.right,
      onTapFlipping: true,

      frontWidget: _buildCardContent(widget.frontColor),
      backWidget: _buildCardContent(widget.backColor),
    );
  }
}

class DurationFormatter {
  static String formatIsoDuration(String isoDuration) {
    final RegExp regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?');
    final Match? match = regex.firstMatch(isoDuration);

    if (match == null) return '0 ${LocaleKeys.general_hours.tr()}';

    final hours = match.group(1);
    final minutes = match.group(2);

    final StringBuffer buffer = StringBuffer();

    if (hours != null && hours != '0') {
      buffer.write('$hours ${LocaleKeys.general_hours.tr()}');
    }

    if (minutes != null && minutes != '0') {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write('$minutes ${LocaleKeys.general_minutes.tr()}');
    }

    return buffer.toString();
  }

  static String formatDifference(String current, String difference) {
    final currentFormatted = formatIsoDuration(current);
    final differenceFormatted = formatIsoDuration(difference);

    return '$currentFormatted (${_getChangeSymbol(difference)}$differenceFormatted)';
  }

  static String _getChangeSymbol(String difference) {
    // Eğer negatif değer kontrolü yapmak isterseniz burada yapabilirsiniz
    return '+';
  }
}
