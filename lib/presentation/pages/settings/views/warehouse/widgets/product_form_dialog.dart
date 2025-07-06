import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/warehouse/product_model.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/presentation/widgets/text/price_convert_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProductFormDialog extends StatefulWidget {
  final ProductModel? initialProduct;
  final Function(ProductModel product) onSave;

  const ProductFormDialog({
    super.key,
    this.initialProduct,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    ProductModel? initialProduct,
    required Function(ProductModel product) onSave,
  }) {
    return showDialog(
      context: context,
      builder:
          (context) =>
              ProductFormDialog(initialProduct: initialProduct, onSave: onSave),
    );
  }

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late int _quantity;
  double _total = 0;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialProduct?.name ?? '',
    );
    _priceController = TextEditingController(
      text: widget.initialProduct?.price?.toString() ?? '',
    );
    _quantity = widget.initialProduct?.quantity ?? 1;

    // Initialize total
    _calculateTotal();

    // Add listeners to update total when fields change
    _priceController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    setState(() {
      final price = double.tryParse(_priceController.text) ?? 0;
      _total = price * _quantity;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      _calculateTotal();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _calculateTotal();
      });
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    final price = double.tryParse(priceText) ?? 0;

    // Ensure quantity is at least 1
    final quantity = _quantity < 1 ? 1 : _quantity;
    final totalPrice = price * quantity;

    final product = ProductModel(
      id: widget.initialProduct?.id,
      name: name,
      price: price,
      quantity: quantity,
      totalPrice: totalPrice,
    );

    widget.onSave(product);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing
                        ? LocaleKeys.forms_edit_product.tr()
                        : LocaleKeys.forms_add_new_product.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Product name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: LocaleKeys.forms_product_name.tr(),
                  hintText: LocaleKeys.forms_enter_product_name.tr(),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LocaleKeys.forms_enter_product_name.tr();
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Price field
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: LocaleKeys.general_price.tr(),
                  hintText: LocaleKeys.forms_enter_product_price.tr(),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LocaleKeys.forms_enter_product_price.tr();
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return LocaleKeys.forms_enter_product_price.tr();
                  }
                  return null;
                },
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Quantity with increment/decrement controls
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText(
                    title: '${LocaleKeys.general_quantity.tr()}: ',
                    textType: TextType.body,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _decrementQuantity,
                          visualDensity: VisualDensity.compact,
                        ),
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _incrementQuantity,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calculate total
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppText(
                      title: '${LocaleKeys.report_total.tr()}: ',
                      textType: TextType.body,
                    ),
                    PriceConvertWidget(
                      price: _total,
                      textType: TextType.body,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(LocaleKeys.buttons_cancel.tr()),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _isEditing
                          ? LocaleKeys.buttons_update.tr()
                          : LocaleKeys.buttons_save.tr(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
