import 'package:dent_app_mobile/presentation/pages/calendar/views/services_content.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// FastPaymentService provides functionality to show a service selection modal
/// and process fast payments for appointments.
///
/// Usage:
/// ```dart
/// // Show the service selection modal for a specific appointment
/// await FastPaymentService().showServices(context, appointmentId);
/// ```
///
/// The service will:
/// 1. Load available services from the API
/// 2. Display them in a modal bottom sheet
/// 3. Allow users to select multiple services
/// 4. Process the payment using FastPayCubit
/// 5. Show success/error messages
/// 6. Close the modal on successful payment
class FastPaymentService {
  /// Shows a modal bottom sheet with available services for fast payment.
  ///
  /// [context] - The build context
  /// [appointmentId] - The ID of the appointment to process payment for
  Future<bool?> showServices(
    BuildContext context,
    int appointmentId, {
    bool onlyCloseSheet = false,
  }) async {
    return await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => Material(
        child: ServicesContent(
          onlyCloseSheet: onlyCloseSheet,
          appointmentId: appointmentId,
        ),
      ),
    );
  }
}
