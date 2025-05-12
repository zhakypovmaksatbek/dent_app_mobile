import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/warehouse/document_model.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DocumentItemCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onDelete;

  const DocumentItemCard({super.key, required this.document, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.supplier ?? "-",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${LocaleKeys.general_description.tr()}: ${document.description ?? 'N/A'}',
                  ),
                  Text(
                    '${LocaleKeys.general_total_amount.tr()}: ${document.totalPrice ?? 0}',
                  ),
                  Text(
                    '${LocaleKeys.report_date.tr()}: ${document.dateOfCreated ?? 'N/A'}',
                  ),
                  Text(
                    '${LocaleKeys.appointment_status_label.tr()}: ${document.paymentStatus ?? 'N/A'}',
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(LocaleKeys.buttons_delete.tr()),
                          ],
                        ),
                      ),
                    ],
              ),
          ],
        ),
      ),
    );
  }
}
