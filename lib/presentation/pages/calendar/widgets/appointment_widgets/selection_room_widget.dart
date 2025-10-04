// lib/presentation/pages/calendar/widgets/selection_room_widget.dart

// collection paketini kullanmıyorsanız, 'package:collection/collection.dart'; importunu ekleyebilirsiniz.
// Alternatif olarak, try-catch bloğu da kalabilir.
import 'package:collection/collection.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/room_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/room/room_cubit.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectionRoomWidget extends StatefulWidget {
  final bool enabled;
  final Function(RoomModel?) onRoomSelected;
  final RoomModel? initialValue;
  final RoomModel? value; // Mevcut seçili değer
  const SelectionRoomWidget({
    super.key,
    required this.enabled,
    required this.onRoomSelected,
    this.initialValue,
    this.value,
  });

  @override
  State<SelectionRoomWidget> createState() => _SelectionRoomWidgetState();
}

class _SelectionRoomWidgetState extends State<SelectionRoomWidget> {
  RoomModel? _selectedRoom;

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.initialValue;
  }

  @override
  void didUpdateWidget(SelectionRoomWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parent'tan gelen value değiştiğinde local state'i güncelle
    if (widget.value != oldWidget.value) {
      _selectedRoom = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    // buildWhen, widget'ın ne zaman yeniden çizileceğini kontrol eder.
    // Sadece RoomState gerçekten değiştiğinde (örneğin, Yükleniyordan Yüklendi'ye geçtiğinde
    // veya odaların listesi güncellendiğinde) build metodu tekrar çalışır.
    // Parent widget'taki alakasız setState çağrıları bu widget'ı etkilemez.
    return BlocBuilder<RoomCubit, RoomState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        // 1. Yüklenme Durumu (Loading State)
        // Kullanıcıya odaların yüklendiğini göstermek için.
        if (state is RoomLoading) {
          return _buildDropdownWrapper(
            context: context,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        // 2. Hata Durumu (Failure State)
        if (state is RoomFailure) {
          return _buildDropdownWrapper(
            context: context,
            hintText: state.message,
            prefixIcon: Icons.error_outline,
            prefixIconColor: Theme.of(context).colorScheme.error,
          );
        }

        // 3. Başarılı Durum (Loaded State)
        if (state is RoomLoaded) {
          // Önce widget.value'yu kontrol et, sonra _selectedRoom'u
          final currentValue = widget.value ?? _selectedRoom;

          // Gelen listede mevcut değere karşılık gelen RoomModel'i bulalım.
          final selectedRoom =
              currentValue == null
                  ? null
                  : state.rooms.firstWhereOrNull(
                    (room) => room.id == currentValue.id,
                  );

          return DropdownButtonFormField<RoomModel>(
            // key: Dropdown'ın iç state'ini doğru yönetmesi için önemlidir.
            // Oda listesi değiştiğinde, Flutter'a bunun yeni bir dropdown olduğunu söyler.
            key: ValueKey('${state.rooms.length}_${selectedRoom?.id}'),
            initialValue: selectedRoom,
            items:
                state.rooms.map((room) {
                  return DropdownMenuItem<RoomModel>(
                    value: room,
                    child: AppText(
                      title: room.name ?? 'Bilinmeyen Oda',
                      textType: TextType.body,
                    ),
                  );
                }).toList(),
            onChanged:
                widget.enabled
                    ? (room) {
                      setState(() {
                        _selectedRoom = room;
                      });
                      widget.onRoomSelected(room);
                    }
                    : null,
            decoration: InputDecoration(
              labelText: LocaleKeys.appointment_room.tr(),
              prefixIcon: const Icon(Icons.meeting_room),
              // Hint artık dinamik olarak boş olup olmamasına göre ayarlanıyor.
              hintText:
                  state.rooms.isEmpty
                      ? LocaleKeys.appointment_no_rooms_available.tr()
                      : LocaleKeys.appointment_select_room.tr(),

              // enabled: `onChanged: null` zaten dropdown'ı devre dışı bırakır.
              // Bu yüzden buradaki enabled estetik bir kontrol sağlar.
              enabled: widget.enabled && state.rooms.isNotEmpty,
            ),
          );
        }

        // 4. Başlangıç veya Tanımsız Durum (Initial State)
        return _buildDropdownWrapper(
          context: context,
          hintText: LocaleKeys.forms_select_time_first.tr(),
        );
      },
    );
  }

  // Bu yardımcı metodda değişiklik yapmaya gerek yok.
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

        enabled: false,
      ),
      child:
          child ??
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
            ), // Hizalama için padding
            child: AppText(
              title: hintText ?? '',
              textType: TextType.body,
              color: Theme.of(context).disabledColor,
            ),
          ),
    );
  }
}
