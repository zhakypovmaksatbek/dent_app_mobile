import 'package:dent_app_mobile/models/diagnosis/tooth_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_appointments/patient_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_tooth/patient_tooth_cubit.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teeth_selector/teeth_selector.dart';

class TeethPage extends StatefulWidget {
  final int patientId;

  const TeethPage({super.key, required this.patientId});

  @override
  State<TeethPage> createState() => _TeethPageState();
}

class _TeethPageState extends State<TeethPage> {
  late PatientToothCubit _patientToothCubit;

  @override
  void initState() {
    super.initState();
    _patientToothCubit = PatientToothCubit();
    _patientToothCubit.getToothList(widget.patientId);
  }

  List<ToothModel> teeth = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientToothCubit, PatientToothState>(
      bloc: _patientToothCubit,
      listener: (context, state) {
        if (state is PatientToothLoaded) {
          teeth = state.teeth;
        }
      },
      builder: (context, state) {
        if (state is PatientAppointmentsLoading) {
          return const LoadingWidget();
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Стоматологическая карта',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Зубная карта с овальным расположением
                TeethSelector(
                  onChange: (selected) {
                    if (selected.isNotEmpty) {
                      _showToothDetails(selected.last);
                    }
                  },

                  // Показ постоянных зубов
                  showPermanent: true,
                  // Показ молочных зубов
                  showPrimary: true,
                  // Возможность выбора нескольких зубов
                  multiSelect: false,
                  // Цвет выбранного зуба
                  selectedColor: ColorConstants.primary,
                  // Цвет невыбранных зубов
                  unselectedColor: Colors.white,
                  // Цвет подсказки
                  tooltipColor: ColorConstants.primary,
                  // Изначально выбранные зубы
                  // initiallySelected: const [],

                  // Раскрасить зубы с лечением
                  StrokedColorized: _getTeethColorMap(),

                  // Цвет обводки по умолчанию
                  defaultStrokeColor: Colors.grey.withValues(alpha: .3),
                  // Ширина обводки для конкретных зубов
                  strokeWidth: const {},
                  // Ширина обводки по умолчанию
                  defaultStrokeWidth: 1.0,
                  // Текст для левой стороны
                  leftString: 'Левая',
                  // Текст для правой стороны
                  rightString: 'Правая',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Получение карты цветов для зубов на основе данных диагноза
  Map<String, Color> _getTeethColorMap() {
    final map = <String, Color>{};

    for (final tooth in teeth) {
      if (tooth.toothNumber != null &&
          tooth.main?.color != null &&
          tooth.main!.color!.isNotEmpty) {
        final String toothId = tooth.toothNumber.toString();
        map[toothId] = _hexToColor(tooth.main!.color!);
      }
    }

    return map;
  }

  // Показать детали зуба при нажатии
  void _showToothDetails(String toothId) {
    int? toothNumber;
    try {
      toothNumber = int.parse(toothId);
    } catch (e) {
      // Игнорируем ошибку преобразования
      return;
    }

    // Находим информацию о зубе
    final toothInfo = teeth.firstWhere(
      (tooth) => tooth.toothNumber == toothNumber,
      orElse: () => ToothModel(toothNumber: toothNumber),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Зуб $toothId'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Расположение: ${toothId.startsWith("1") || toothId.startsWith("2") ? 'Верхнее' : 'Нижнее'} ${int.parse(toothId[0]) % 2 == 0 ? 'Левое' : 'Правое'}',
                ),
                const SizedBox(height: 8),
                Text('Диагноз: ${toothInfo.main?.name ?? 'Нет диагноза'}'),
                if (toothInfo.main?.color != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Цвет: '),
                      Container(
                        width: 20,
                        height: 20,
                        color: _hexToColor(toothInfo.main!.color!),
                        margin: const EdgeInsets.only(left: 8),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          ),
    );
  }

  // Вспомогательный метод для преобразования HEX-строки в Color
  Color _hexToColor(String hexString) {
    try {
      final String colorStr = hexString.replaceFirst('#', 'FF');
      return Color(int.parse(colorStr, radix: 16));
    } catch (e) {
      // Возвращаем цвет по умолчанию при ошибке
      return ColorConstants.primary;
    }
  }
}
