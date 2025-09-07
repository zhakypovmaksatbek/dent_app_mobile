// lib/presentation/pages/calendar/widgets/selection_room_widget.dart

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/room_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/room/room_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectionRoomWidget extends StatelessWidget {
  final bool enabled;
  final Function(RoomModel?) onRoomSelected;
  final RoomModel? initialValue;
  const SelectionRoomWidget({
    super.key,
    required this.enabled,
    required this.onRoomSelected,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomState>(
      builder: (context, state) {
        if (state is RoomFailure) {
          return _buildDropdownWrapper(
            context: context,
            hintText: state.message,
            prefixIcon: Icons.error_outline,
            prefixIconColor: Theme.of(context).colorScheme.error,
          );
        }

        if (state is RoomLoaded) {
          return DropdownButtonFormField<RoomModel>(
            initialValue: initialValue,
            items:
                state.rooms.map((room) {
                  return DropdownMenuItem<RoomModel>(
                    value: room,
                    child: Text(room.name ?? 'Unknown Room'),
                  );
                }).toList(),
            onChanged: enabled ? (room) => onRoomSelected(room) : null,
            decoration: InputDecoration(
              labelText: LocaleKeys.appointment_room.tr(),
              prefixIcon: const Icon(Icons.meeting_room),
              hint: Text(
                state.rooms.isEmpty
                    ? LocaleKeys.appointment_no_rooms_available.tr()
                    : LocaleKeys.appointment_select_room.tr(),
              ),
              border: const OutlineInputBorder(),
              enabled: enabled,
            ),
          );
        }

        return _buildDropdownWrapper(context: context, hintText: "Select Room");
      },
    );
  }

  Widget _buildDropdownWrapper({
    required BuildContext context,
    String? hintText,
    Widget? child,
    IconData prefixIcon = Icons.meeting_room,
    Color? prefixIconColor,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: LocaleKeys.appointment_room.tr(),
        prefixIcon: Icon(prefixIcon, color: prefixIconColor),
        border: const OutlineInputBorder(),
        enabled: false,
      ),
      child:
          child ??
          Text(
            hintText ?? '',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
    );
  }
}
