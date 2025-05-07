import 'package:dent_app_mobile/models/warehouse/product_model.dart';
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
                    _isEditing ? 'Edit Product' : 'Add New Product',
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
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Enter product name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Price field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'Enter product price',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
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
                children: [
                  const Icon(
                    Icons.production_quantity_limits,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Quantity:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
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
                    const Text(
                      'Total: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$_total',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                    child: const Text('CANCEL'),
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
                    child: Text(_isEditing ? 'UPDATE' : 'SAVE'),
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
