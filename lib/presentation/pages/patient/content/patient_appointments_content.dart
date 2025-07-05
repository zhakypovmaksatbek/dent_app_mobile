import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_appointments/patient_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientAppointments extends StatefulWidget {
  const PatientAppointments({super.key, required this.patientId});

  final int patientId;

  @override
  State<PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments> {
  late final PatientAppointmentsCubit _patientAppointmentsCubit;
  int _page = 1;
  bool _isLoading = false;
  bool _isLast = true;
  final List<VisitModel> _visits = [];
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _patientAppointmentsCubit = PatientAppointmentsCubit();
    _patientAppointmentsCubit.getPatientAppointments(widget.patientId, _page);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLast && !_isLoading) {
        _page++;
        _patientAppointmentsCubit.getPatientAppointments(
          widget.patientId,
          _page,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _patientAppointmentsCubit.close();
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider.value(
      value: _patientAppointmentsCubit,
      child: BlocConsumer<PatientAppointmentsCubit, PatientAppointmentsState>(
        bloc: _patientAppointmentsCubit,
        listener: (context, state) {
          if (state is PatientAppointmentsLoaded) {
            _isLast = state.response.last ?? true;
            _isLoading = false;
            _visits.addAll(state.response.content ?? []);
          } else if (state is PatientAppointmentsLoading) {
            _isLoading = true;
          } else {
            _isLoading = false;
          }
        },
        builder: (context, state) {
          if (state is PatientAppointmentsLoading && _visits.isEmpty) {
            return const LoadingWidget();
          } else if (_visits.isNotEmpty) {
            return SizedBox(
              height: size.height * 0.5,
              child: ListView.separated(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                itemCount: _visits.length,
                controller: _scrollController,
                separatorBuilder:
                    (BuildContext context, int index) =>
                        const SizedBox(height: 16),

                itemBuilder: (BuildContext context, int index) {
                  return PatientAppointmentCard(visit: _visits[index]);
                },
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class PatientAppointmentCard extends StatelessWidget {
  const PatientAppointmentCard({super.key, required this.visit});
  final VisitModel visit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with appointment info and status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  radius: 24,
                  child: Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppText(
                              title: 'Визит #${visit.appointmentId}',
                              textType: TextType.body,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                visit.recordType ?? '',
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AppText(
                              title: _formatRecordType(visit.recordType ?? ''),
                              textType: TextType.description,
                              color: _getStatusColor(visit.recordType ?? ''),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        title: visit.appointment ?? '',
                        textType: TextType.subtitle,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Services Section
            if (visit.appointmentServiceToPatientResponses?.isNotEmpty ??
                false) ...[
              AppText(
                title: 'Услуги',
                textType: TextType.subtitle,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      visit.appointmentServiceToPatientResponses!
                          .map(
                            (service) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.medical_services,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppText(
                                      title: service.name ?? '',
                                      textType: TextType.description,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Financial Information
            AppText(
              title: 'Финансовая информация',
              textType: TextType.subtitle,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),

            // Financial Cards Row 1
            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    context,
                    'Общая сумма',
                    visit.totalPrice ?? 0,
                    Icons.receipt_long,
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinancialCard(
                    context,
                    'К оплате',
                    visit.pricePayable ?? 0,
                    Icons.payment,
                    _getPayableColor(visit.pricePayable ?? 0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Financial Cards Row 2
            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    context,
                    'Оплачено',
                    visit.paid ?? 0,
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinancialCard(
                    context,
                    'Долг',
                    visit.debt ?? 0,
                    Icons.error,
                    _getDebtColor(visit.debt ?? 0),
                  ),
                ),
              ],
            ),

            // Additional financial info if present
            if ((visit.additionalDiscount ?? 0) > 0 ||
                (visit.deposit ?? 0) > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if ((visit.additionalDiscount ?? 0) > 0)
                    Expanded(
                      child: _buildFinancialCard(
                        context,
                        'Скидка',
                        visit.additionalDiscount ?? 0,
                        Icons.discount,
                        Colors.orange,
                      ),
                    ),
                  if ((visit.additionalDiscount ?? 0) > 0 &&
                      (visit.deposit ?? 0) > 0)
                    const SizedBox(width: 12),
                  if ((visit.deposit ?? 0) > 0)
                    Expanded(
                      child: _buildFinancialCard(
                        context,
                        'Депозит',
                        visit.deposit ?? 0,
                        Icons.account_balance_wallet,
                        Colors.blue,
                      ),
                    ),
                ],
              ),
            ],

            // Teeth information if present
            if (visit.tooth?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              AppText(
                title: 'Зубы',
                textType: TextType.subtitle,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    visit.tooth!
                        .map(
                          (toothNumber) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: AppText(
                              title: toothNumber.toString(),
                              textType: TextType.description,
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: AppText(
                  title: title,
                  textType: TextType.description,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppText(
            title: '${_formatAmount(amount)} сом',
            textType: TextType.subtitle,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
      );
    } else {
      return amount
          .toStringAsFixed(2)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]} ',
          );
    }
  }

  Color _getStatusColor(String recordType) {
    switch (recordType.toUpperCase()) {
      case 'TREATMENT':
        return Colors.blue;
      case 'CONSULTATION':
        return Colors.green;
      case 'PREVENTIVE':
        return Colors.orange;
      case 'EMERGENCY':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatRecordType(String recordType) {
    switch (recordType.toUpperCase()) {
      case 'TREATMENT':
        return 'Лечение';
      case 'CONSULTATION':
        return 'Консультация';
      case 'PREVENTIVE':
        return 'Профилактика';
      case 'EMERGENCY':
        return 'Экстренная помощь';
      default:
        return recordType;
    }
  }

  Color _getPayableColor(double amount) {
    if (amount > 0) return Colors.orange;
    if (amount < 0) return Colors.red;
    return Colors.green;
  }

  Color _getDebtColor(double debt) {
    return debt > 0 ? Colors.red : Colors.green;
  }
}
