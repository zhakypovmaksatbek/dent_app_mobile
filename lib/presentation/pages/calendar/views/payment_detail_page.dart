import 'package:auto_route/annotations.dart';
import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/payment_types.dart';
import 'package:dent_app_mobile/core/utils/salary_type.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/payment/payment_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/detail_receipt/detail_receipt_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/pay_appointment/pay_appointment_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/payment_form_widgets.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/payment_info_widgets.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/payment_summary_widgets.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/roles.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'PaymentDetailRoute')
class PaymentDetailPage extends StatefulWidget {
  const PaymentDetailPage({super.key, required this.appointmentId});
  final int appointmentId;

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  late final DetailReceiptCubit _detailReceiptCubit;
  late final PayAppointmentCubit _payAppointmentCubit;
  late final ValueNotifier<PaymentType> _selectedPaymentType;
  late final TextEditingController _amountController;
  late final TextEditingController _discountController;
  late final ValueNotifier<SalaryType> _discountType;
  late final ValueNotifier<double> _calculatedDiscount;
  late final ValueNotifier<double> _finalAmount;
  bool _hasAutoFilled = false;

  @override
  void initState() {
    super.initState();
    AppointmentRepo().getDetailReceipt(widget.appointmentId);
    _detailReceiptCubit = DetailReceiptCubit();
    _payAppointmentCubit = PayAppointmentCubit();
    _selectedPaymentType = ValueNotifier(PaymentType.cash);
    _amountController = TextEditingController();
    _discountController = TextEditingController(text: '0');
    _discountType = ValueNotifier(SalaryType.fixed);
    _calculatedDiscount = ValueNotifier(0.0);
    _finalAmount = ValueNotifier(0.0);

    // Add listeners for real-time calculation
    _amountController.addListener(_calculateAmounts);
    _discountController.addListener(_calculateAmounts);
    _discountType.addListener(_calculateAmounts);

    _detailReceiptCubit.getDetailReceipt(widget.appointmentId);
  }

  @override
  void dispose() {
    _detailReceiptCubit.close();
    _payAppointmentCubit.close();
    _selectedPaymentType.dispose();
    _amountController.dispose();
    _discountController.dispose();
    _discountType.dispose();
    _calculatedDiscount.dispose();
    _finalAmount.dispose();
    super.dispose();
  }

  Future<void> _loadAppointmentsForDateRange(BuildContext context) async {
    final Role role = await AppDataService.instance.getRole();
    final int? userId = await AppDataService.instance.getUserId();
    // Determine start and end date based on month view
    final DateTime today = DateTime.now();
    final DateTime monthStart = DateTime(today.year, today.month, 1);
    final DateTime monthEnd = DateTime(today.year, today.month + 1, 0);
    if (kDebugMode) {
      print('Loading appointments from $monthStart to $monthEnd');
    }
    if (context.mounted) {
      // Fetch appointments using the cubit
      context.read<CalendarAppointmentsCubit>().getCalendarAppointments(
        monthStart,
        monthEnd,
        userIds: role == Role.admin ? null : [userId!],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _detailReceiptCubit),
        BlocProvider.value(value: _payAppointmentCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: () async {
            _detailReceiptCubit.getDetailReceipt(widget.appointmentId);
          },
          child: BlocConsumer<DetailReceiptCubit, DetailReceiptState>(
            listener: (context, state) {
              if (state is DetailReceiptError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  // Header Sliver
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: AppColors.white,
                    elevation: 2,
                    title: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const AppText(
                          title: 'Детали оплаты',
                          textType: TextType.title20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                    leading: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Content based on state
                  if (state is DetailReceiptLoading) ...[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: const Center(child: LoadingWidget()),
                    ),
                  ] else if (state is DetailReceiptError) ...[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildErrorState(state.message),
                    ),
                  ] else if (state is DetailReceiptSuccess) ...[
                    // Auto-fill amount on first load
                    if (!_hasAutoFilled &&
                        (state.detailReceipt.debt ?? 0) > 0) ...[
                      Builder(
                        builder: (context) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!_hasAutoFilled) {
                              _amountController.text =
                                  (state.detailReceipt.debt ?? 0).toString();
                              _hasAutoFilled = true;
                            }
                          });
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        },
                      ),
                    ],

                    // // Appointment ID Section
                    // SliverPadding(
                    //   padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    //   sliver: SliverToBoxAdapter(
                    //     child: PaymentInfoCard(
                    //       appointmentId: state.receipt.appointmentId ?? 0,
                    //     ),
                    //   ),
                    // ),

                    // Services Section
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: PaymentServicesListCard(
                          services:
                              state.detailReceipt.workServicesResponses ?? [],
                          formatAmount: _formatAmount,
                        ),
                      ),
                    ),

                    // // Payment Summary Section
                    // SliverPadding(
                    //   padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    //   sliver: SliverToBoxAdapter(
                    //     child: ReceiptPaymentSummary(
                    //       receipt: state.receipt,
                    //       formatAmount: _formatAmount,
                    //     ),
                    //   ),
                    // ),

                    // Payment Status Section
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: PaymentStatusCards(
                          receipt: state.detailReceipt,
                          formatAmount: _formatAmount,
                        ),
                      ),
                    ),

                    // Payment Form Section (only show if there's debt)
                    if ((state.detailReceipt.debt ?? 0) > 0) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                title: LocaleKeys.forms_payment.tr(),
                                textType: TextType.title,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(height: 16),

                              // Payment Type Selection
                              PaymentTypeSelection(
                                selectedPaymentType: _selectedPaymentType,
                              ),
                              const SizedBox(height: 16),

                              // Amount Input
                              PaymentAmountInput(
                                controller: _amountController,
                                maxAmount:
                                    (state.detailReceipt.debt ?? 0).toDouble(),
                                formatAmount: _formatAmount,
                              ),
                              const SizedBox(height: 16),

                              // Discount Input
                              PaymentDiscountInput(
                                controller: _discountController,
                                discountType: _discountType,
                                amountController: _amountController,
                                onDiscountChanged: _calculateAmounts,
                              ),
                              const SizedBox(height: 16),

                              // Calculation Summary
                              PaymentCalculationSummary(
                                calculatedDiscount: _calculatedDiscount,
                                finalAmount: _finalAmount,
                                amountController: _amountController,
                                discountController: _discountController,
                                discountType: _discountType,
                                formatAmount: _formatAmount,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Payment listener and button
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        sliver: SliverToBoxAdapter(
                          child: BlocConsumer<
                            PayAppointmentCubit,
                            PayAppointmentState
                          >(
                            listener: (context, state) {
                              if (state is PayAppointmentSuccess) {
                                AppSnackBar.showSuccessSnackBar(
                                  context,
                                  'Оплата прошла успешно!',
                                );
                                // Refresh receipt data
                                _detailReceiptCubit.getDetailReceipt(
                                  widget.appointmentId,
                                );
                                _loadAppointmentsForDateRange(context);
                                // Clear form
                                _clearForm();
                              } else if (state is PayAppointmentError) {
                                AppSnackBar.showErrorSnackBar(
                                  context,
                                  state.error,
                                );
                              }
                            },
                            builder: (context, state) {
                              return PaymentButton(onPressed: _makePayment);
                            },
                          ),
                        ),
                      ),
                    ] else ...[
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 32),
                        sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                      ),
                    ],
                  ] else ...[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: const SizedBox.shrink(),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          AppText(
            title: 'Ошибка загрузки',
            textType: TextType.title,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          AppText(
            title: message,
            textType: TextType.body,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                () =>
                    _detailReceiptCubit.getDetailReceipt(widget.appointmentId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: AppText(
              title: LocaleKeys.buttons_retry.tr(),
              textType: TextType.body,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _makePayment() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      AppSnackBar.showErrorSnackBar(context, 'Введите сумму оплаты');
      return;
    }

    final originalAmount = double.tryParse(amountText);
    if (originalAmount == null || originalAmount <= 0) {
      AppSnackBar.showErrorSnackBar(context, 'Введите корректную сумму');
      return;
    }

    // Use the calculated final amount for payment
    final finalPaymentAmount =
        _finalAmount.value > 0 ? _finalAmount.value : originalAmount;

    final payment = PaymentModel(
      sum: finalPaymentAmount.toInt(),
      discount: _calculatedDiscount.value.toInt(),
      discountType: _discountType.value.name.toUpperCase(),
      typeOfPayment: _selectedPaymentType.value.name.toUpperCase(),
      check: true,
    );

    _payAppointmentCubit.payAppointment(payment, widget.appointmentId);
  }

  void _clearForm() {
    _amountController.clear();
    _discountController.text = '0';
    _selectedPaymentType.value = PaymentType.cash;
    _discountType.value = SalaryType.fixed;
    _calculatedDiscount.value = 0.0;
    _finalAmount.value = 0.0;
    _hasAutoFilled = false;
  }

  void _calculateAmounts() {
    final amountText = _amountController.text.trim();
    final discountText = _discountController.text.trim();

    final amount = double.tryParse(amountText) ?? 0.0;
    final discount = double.tryParse(discountText) ?? 0.0;

    double calculatedDiscount = 0.0;
    double finalAmount = amount;

    if (amount > 0 && discount > 0) {
      if (_discountType.value == SalaryType.percent) {
        // Percentage discount
        calculatedDiscount = (amount * discount) / 100;
      } else {
        // Fixed amount discount
        calculatedDiscount = discount;
      }

      // Make sure discount doesn't exceed the amount
      calculatedDiscount =
          calculatedDiscount > amount ? amount : calculatedDiscount;
      finalAmount = amount - calculatedDiscount;
    }

    _calculatedDiscount.value = calculatedDiscount;
    _finalAmount.value = finalAmount;
  }

  String _formatAmount(double amount) {
    // Convert to int if it's a whole number, otherwise keep 2 decimal places
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
}
