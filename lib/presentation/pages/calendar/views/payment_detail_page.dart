import 'package:auto_route/annotations.dart';
import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/core/utils/payment_types.dart';
import 'package:dent_app_mobile/core/utils/salary_type.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/payment/payment_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/detail_receipt/detail_receipt_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/pay_appointment/pay_appointment_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/services/fast_payment_service.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/payment_form_widgets.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/payment_info_widgets.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/payment_summary_widgets.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/roles.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
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

  // Form Controllers & Notifiers
  final ValueNotifier<PaymentType> _selectedPaymentType = ValueNotifier(
    PaymentType.cash,
  );
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(
    text: '0',
  );
  final ValueNotifier<SalaryType> _discountType = ValueNotifier(
    SalaryType.fixed,
  );
  final ValueNotifier<double> _calculatedDiscount = ValueNotifier(0.0);
  final ValueNotifier<double> _finalAmount = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _detailReceiptCubit = DetailReceiptCubit();
    _payAppointmentCubit = PayAppointmentCubit();

    // Setup calculation listeners
    _amountController.addListener(_calculateAmounts);
    _discountController.addListener(_calculateAmounts);
    _discountType.addListener(_calculateAmounts);

    _loadReceiptData();
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

  void _loadReceiptData() {
    _detailReceiptCubit.getDetailReceipt(widget.appointmentId);
  }

  Future<void> _refreshData() async {
    _loadReceiptData();
  }

  Future<void> _loadAppointmentsForDateRange(BuildContext context) async {
    final Role role = await AppDataService.instance.getRole();
    final int? userId = await AppDataService.instance.getUserId();

    final DateTime today = DateTime.now();
    final DateTime monthStart = DateTime(today.year, today.month, 1);
    final DateTime monthEnd = DateTime(today.year, today.month + 1, 0);

    if (context.mounted) {
      context.read<CalendarAppointmentsCubit>().getCalendarAppointments(
        monthStart,
        monthEnd,
        userIds: role == Role.admin ? null : [userId!],
      );
    }
  }

  // --- Business Logic Methods ---

  void _updateFormWithReceiptData(DetailReceiptSuccess state) {
    final debt = state.detailReceipt.debt ?? 0;
    if (debt > 0) {
      // Sadece controller text'i farklıysa güncelle (imleç sorunu olmasın diye)
      if (_amountController.text != debt.toString()) {
        _amountController.text = debt.toString();
        _calculateAmounts(); // Recalculate immediately
      }
    } else {
      // Borç yoksa alanı temizle
      if (_amountController.text.isNotEmpty) {
        _amountController.clear();
        _calculateAmounts();
      }
    }
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
    final finalPaymentAmount = _finalAmount.value > 0
        ? _finalAmount.value
        : originalAmount;

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
        calculatedDiscount = (amount * discount) / 100;
      } else {
        calculatedDiscount = discount;
      }

      calculatedDiscount = calculatedDiscount > amount
          ? amount
          : calculatedDiscount;
      finalAmount = amount - calculatedDiscount;
    } else {
      // No discount or invalid amount, final is amount
      finalAmount = amount;
    }

    _calculatedDiscount.value = calculatedDiscount;
    _finalAmount.value = finalAmount;
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

  // --- Widget Builders ---

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
          onRefresh: _refreshData,
          child: BlocConsumer<DetailReceiptCubit, DetailReceiptState>(
            listener: (context, state) {
              if (state is DetailReceiptError) {
                AppSnackBar.showErrorSnackBar(context, state.message);
              } else if (state is DetailReceiptSuccess) {
                // State değiştiğinde formu güncelle (yeni servis eklendiyse fiyat artar)
                _updateFormWithReceiptData(state);
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  _buildAppBar(context),
                  if (state is DetailReceiptLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: LoadingWidget()),
                    )
                  else if (state is DetailReceiptError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildErrorState(state.message),
                    )
                  else if (state is DetailReceiptSuccess)
                    ..._buildSuccessContent(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.white,
      elevation: 2,
      title: Row(
        children: [
          const Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
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
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
    );
  }

  List<Widget> _buildSuccessContent(
    BuildContext context,
    DetailReceiptSuccess state,
  ) {
    return [
      // Services List
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        sliver: SliverToBoxAdapter(
          child: PaymentServicesListCard(
            services: state.detailReceipt.workServicesResponses ?? [],
            formatAmount: _formatAmount,
          ),
        ),
      ),

      // Add Services Button
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () async {
              final bool? result = await FastPaymentService().showServices(
                context,
                widget.appointmentId,
                onlyCloseSheet: true,
              );
              if (result == true) {
                _refreshData(); // Refresh data after adding service
              }
            },
            child: Text(LocaleKeys.buttons_add_services.tr()),
          ),
        ),
      ),

      // Payment Status
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        sliver: SliverToBoxAdapter(
          child: PaymentStatusCards(
            receipt: state.detailReceipt,
            formatAmount: _formatAmount,
          ),
        ),
      ),

      // Payment Form (Only if there is debt)
      if ((state.detailReceipt.debt ?? 0) > 0) ...[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          sliver: SliverToBoxAdapter(
            child: _buildPaymentForm(state.detailReceipt.debt?.toDouble() ?? 0),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).padding.bottom + 20,
          ),
          sliver: SliverToBoxAdapter(child: _buildPayButton()),
        ),
      ] else
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
    ];
  }

  Widget _buildPaymentForm(double maxDebt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title: LocaleKeys.forms_payment.tr(),
          textType: TextType.title,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 16),
        PaymentTypeSelection(selectedPaymentType: _selectedPaymentType),
        const SizedBox(height: 16),
        PaymentAmountInput(
          controller: _amountController,
          maxAmount: maxDebt,
          formatAmount: _formatAmount,
        ),
        const SizedBox(height: 16),
        PaymentDiscountInput(
          controller: _discountController,
          discountType: _discountType,
          amountController: _amountController,
          onDiscountChanged: _calculateAmounts,
        ),
        const SizedBox(height: 16),
        PaymentCalculationSummary(
          calculatedDiscount: _calculatedDiscount,
          finalAmount: _finalAmount,
          amountController: _amountController,
          discountController: _discountController,
          discountType: _discountType,
          formatAmount: _formatAmount,
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return BlocConsumer<PayAppointmentCubit, PayAppointmentState>(
      listener: (context, state) {
        if (state is PayAppointmentSuccess) {
          AppSnackBar.showSuccessSnackBar(context, 'Оплата прошла успешно!');
          _refreshData();
          _loadAppointmentsForDateRange(context);
          _clearForm();
        } else if (state is PayAppointmentError) {
          AppSnackBar.showErrorSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        // Show loading inside button or disable it
        if (state is PayAppointmentLoading) {
          return const Center(child: LoadingWidget());
        }
        return PaymentButton(onPressed: _makePayment);
      },
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
            onPressed: _refreshData,
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
}
