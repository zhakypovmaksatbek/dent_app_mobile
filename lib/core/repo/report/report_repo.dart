import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/models/report/debtor_model.dart';
import 'package:dent_app_mobile/models/report/payment_report_model.dart';
import 'package:dent_app_mobile/models/report/report_model.dart';

abstract class IReportRepository {
  Future<ReportModel> getReport(String startDate, String endDate);
  Future<PaymentReportDataModel> getPaymentReport(
    String startDate,
    String endDate, {
    int? page,
  });
  Future<PaymentReportDataModel> getDiscountReport(
    String startDate,
    String endDate, {
    int? page,
  });
  Future<PaymentReportDataModel> getDeposit(
    String startDate,
    String endDate, {
    int? page,
    DepositType? depositType,
  });
  Future<DebtorDataModel> getDebtor({String? search, int? page});
}

class ReportRepository extends IReportRepository {
  final dio = DioService();
  @override
  Future<ReportModel> getReport(String startDate, String endDate) async {
    final response = await dio.get(
      'api/reports',
      queryParameters: {'start': startDate, 'end': endDate},
    );
    return ReportModel.fromJson(response.data);
  }

  @override
  Future<PaymentReportDataModel> getPaymentReport(
    String startDate,
    String endDate, {
    int? page,
  }) async {
    final response = await dio.get(
      'api/reports/payment-report',
      queryParameters: {'start': startDate, 'end': endDate, 'page': page},
    );
    return PaymentReportDataModel.fromJson(response.data);
  }

  @override
  Future<DebtorDataModel> getDebtor({String? search, int? page}) async {
    final response = await dio.get(
      'api/reports/debtors',
      queryParameters: {'search': search, 'page': page},
    );
    return DebtorDataModel.fromJson(response.data);
  }

  @override
  Future<PaymentReportDataModel> getDeposit(
    String startDate,
    String endDate, {
    int? page,
    DepositType? depositType,
  }) async {
    final response = await dio.get(
      'api/reports/deposit',
      queryParameters: {
        'start': startDate,
        'end': endDate,
        'page': page,
        'depositType': depositType?.key,
      },
    );
    return PaymentReportDataModel.fromJson(response.data);
  }

  @override
  Future<PaymentReportDataModel> getDiscountReport(
    String startDate,
    String endDate, {
    int? page,
  }) async {
    final response = await dio.get(
      'api/reports/discount',
      queryParameters: {'start': startDate, 'end': endDate, 'page': page},
    );
    return PaymentReportDataModel.fromJson(response.data);
  }
}

enum DepositType {
  makeDeposit("MAKE_DEPOSIT"),
  paymentByDeposit("PAYMENT_BY_DEPOSIT");

  const DepositType(this.key);
  final String key;
}
