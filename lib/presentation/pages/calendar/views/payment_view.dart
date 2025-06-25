import 'package:auto_route/annotations.dart';
import 'package:dent_app_mobile/core/utils/payment_types.dart';
import 'package:dent_app_mobile/core/utils/salary_type.dart';
import 'package:dent_app_mobile/models/payment/payment_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/get_receipt/get_receipt_appointment_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/pay_appointment/pay_appointment_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/payment_form_widgets.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/payment_info_widgets.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/payment_summary_widgets.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: "PaymentViewRoute")
class PaymentView extends StatefulWidget {
  const PaymentView({super.key, required this.appointmentId});
  final int appointmentId;

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  late final GetReceiptAppointmentCubit _getReceiptAppointmentCubit;
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
    _getReceiptAppointmentCubit = GetReceiptAppointmentCubit();
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

    _getReceiptAppointmentCubit.getReceipt(widget.appointmentId);
  }

  @override
  void dispose() {
    _getReceiptAppointmentCubit.close();
    _payAppointmentCubit.close();
    _selectedPaymentType.dispose();
    _amountController.dispose();
    _discountController.dispose();
    _discountType.dispose();
    _calculatedDiscount.dispose();
    _finalAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _getReceiptAppointmentCubit),
        BlocProvider.value(value: _payAppointmentCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: () async {
            _getReceiptAppointmentCubit.getReceipt(widget.appointmentId);
          },
          child: BlocConsumer<
            GetReceiptAppointmentCubit,
            GetReceiptAppointmentState
          >(
            listener: (context, state) {
              if (state is GetReceiptAppointmentError) {
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
                  if (state is GetReceiptAppointmentLoading) ...[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: const Center(child: LoadingWidget()),
                    ),
                  ] else if (state is GetReceiptAppointmentError) ...[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildErrorState(state.message),
                    ),
                  ] else if (state is GetReceiptAppointmentSuccess) ...[
                    // Auto-fill amount on first load
                    if (!_hasAutoFilled && (state.receipt.debt ?? 0) > 0) ...[
                      Builder(
                        builder: (context) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!_hasAutoFilled) {
                              _amountController.text =
                                  (state.receipt.debt ?? 0).toString();
                              _hasAutoFilled = true;
                            }
                          });
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        },
                      ),
                    ],

                    // Appointment ID Section
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      sliver: SliverToBoxAdapter(
                        child: PaymentInfoCard(
                          appointmentId: state.receipt.appointmentId ?? 0,
                        ),
                      ),
                    ),

                    // Services Section
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: PaymentServicesListCard(
                          services:
                              state.receipt.serviceQuantityResponses ?? [],
                          formatAmount: _formatAmount,
                        ),
                      ),
                    ),

                    // Payment Summary Section
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: ReceiptPaymentSummary(
                          receipt: state.receipt,
                          formatAmount: _formatAmount,
                        ),
                      ),
                    ),

                    // Payment Status Section
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: PaymentStatusCards(
                          receipt: state.receipt,
                          formatAmount: _formatAmount,
                        ),
                      ),
                    ),

                    // Payment Form Section (only show if there's debt)
                    if ((state.receipt.debt ?? 0) > 0) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                title: 'Оплата',
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
                                maxAmount: (state.receipt.debt ?? 0).toDouble(),
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
                                _getReceiptAppointmentCubit.getReceipt(
                                  widget.appointmentId,
                                );
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
                () => _getReceiptAppointmentCubit.getReceipt(
                  widget.appointmentId,
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const AppText(
              title: 'Повторить',
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

    final discountText = _discountController.text.trim();
    final discount = double.tryParse(discountText) ?? 0;

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
