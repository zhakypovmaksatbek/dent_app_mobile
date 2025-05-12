import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/warehouse/create_document_model.dart';
import 'package:dent_app_mobile/models/warehouse/product_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/warehouse/core/bloc/product/product_cubit.dart';
import 'package:dent_app_mobile/presentation/widgets/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentFormDialog extends StatefulWidget {
  final CreateDocumentModel? initialDocument;
  final Function(CreateDocumentModel document) onSave;

  const DocumentFormDialog({
    super.key,
    this.initialDocument,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    CreateDocumentModel? initialDocument,
    required Function(CreateDocumentModel document) onSave,
  }) {
    return showDialog(
      context: context,
      builder:
          (context) => DocumentFormDialog(
            initialDocument: initialDocument,
            onSave: onSave,
          ),
    );
  }

  @override
  State<DocumentFormDialog> createState() => _DocumentFormDialogState();
}

class _DocumentFormDialogState extends State<DocumentFormDialog> {
  late final TextEditingController _supplierController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  final List<ItemAddQuantityRequests> _items = [];
  int _totalPrice = 0;

  bool get _isEditing => widget.initialDocument != null;
  late final ProductCubit _productCubit;
  List<ProductModel> _availableProducts = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _supplierController = TextEditingController(
      text: widget.initialDocument?.supplier ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialDocument?.description ?? '',
    );

    // Initialize items if editing
    if (_isEditing && widget.initialDocument?.itemAddQuantityRequests != null) {
      _items.addAll(widget.initialDocument!.itemAddQuantityRequests!);
    }

    _productCubit = context.read<ProductCubit>();
    _loadProducts();
    _calculateTotal();
  }

  void _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    await _productCubit.getProducts();

    setState(() {
      _isLoadingProducts = false;
    });
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    setState(() {
      _totalPrice = _items.fold(
        0,
        (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 0)),
      );
    });
  }

  void _addItem(ProductModel product) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.itemId == product.id,
    );

    if (existingItemIndex != -1) {
      // Update existing item
      setState(() {
        _items[existingItemIndex].quantity =
            (_items[existingItemIndex].quantity ?? 0) + 1;
        _calculateTotal();
      });
    } else {
      // Add new item
      setState(() {
        _items.add(
          ItemAddQuantityRequests(
            itemId: product.id,
            price: product.price?.toInt() ?? 0,
            quantity: 1,
          ),
        );
        _calculateTotal();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _calculateTotal();
    });
  }

  void _updateItemQuantity(int index, int quantity) {
    if (quantity < 1) return; // Prevent negative quantities

    setState(() {
      _items[index].quantity = quantity;
      _calculateTotal();
    });
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.validation_please_add_product.tr())),
      );
      return;
    }

    final supplier = _supplierController.text.trim();
    final description = _descriptionController.text.trim();

    final document = CreateDocumentModel(
      supplier: supplier,
      description: description,
      totalPrice: _totalPrice,
      itemAddQuantityRequests: _items,
    );

    widget.onSave(document);
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
          child: SingleChildScrollView(
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
                          ? LocaleKeys.forms_edit_document.tr()
                          : LocaleKeys.forms_create_document.tr(),
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

                // Supplier field
                TextFormField(
                  controller: _supplierController,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.forms_supplier.tr(),
                    hintText: LocaleKeys.validation_enter_supplier_name.tr(),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return LocaleKeys.validation_enter_supplier_name.tr();
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.general_description.tr(),
                    hintText: LocaleKeys.general_document_description.tr(),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 24),

                // Items section
                Text(
                  LocaleKeys.general_products.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Add product dropdown
                BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading || _isLoadingProducts) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: AppLoader(),
                        ),
                      );
                    }

                    if (state is ProductLoaded) {
                      _availableProducts = state.products;

                      if (_availableProducts.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            LocaleKeys.notifications_not_found_products.tr(),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            hint: Text(LocaleKeys.buttons_add_product.tr()),
                            items:
                                _availableProducts.map((product) {
                                  return DropdownMenuItem<int>(
                                    value: product.id,
                                    child: Text(
                                      '${product.name} (${product.price})',
                                    ),
                                  );
                                }).toList(),
                            onChanged: (productId) {
                              if (productId != null) {
                                final selectedProduct = _availableProducts
                                    .firstWhere(
                                      (product) => product.id == productId,
                                    );
                                _addItem(selectedProduct);
                              }
                            },
                          ),
                        ),
                      );
                    }

                    if (state is ProductError) {
                      return Center(
                        child: Column(
                          children: [
                            Text(LocaleKeys.errors_something_went_wrong.tr()),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadProducts,
                              child: Text(LocaleKeys.buttons_retry.tr()),
                            ),
                          ],
                        ),
                      );
                    }

                    return ElevatedButton(
                      onPressed: _loadProducts,
                      child: Text(LocaleKeys.buttons_load_products.tr()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Selected items list
                if (_items.isNotEmpty) ...[
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final itemName = _getProductName(item.itemId);
                          final itemTotal =
                              (item.price ?? 0) * (item.quantity ?? 0);

                          return Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${LocaleKeys.general_price.tr()}: ${item.price}',
                                    ),
                                    Text(
                                      '${LocaleKeys.report_total_amount.tr()}: $itemTotal',
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed:
                                        item.quantity! > 1
                                            ? () => _updateItemQuantity(
                                              index,
                                              item.quantity! - 1,
                                            )
                                            : null,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Center(
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed:
                                        () => _updateItemQuantity(
                                          index,
                                          item.quantity! + 1,
                                        ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeItem(index),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        LocaleKeys.notifications_not_found_products.tr(),
                      ),
                    ),
                  ),
                ],

                // Total amount
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.report_total_amount.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$_totalPrice',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

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
      ),
    );
  }

  String _getProductName(int? productId) {
    if (productId == null) return LocaleKeys.validation_unknown_product.tr();

    final product = _availableProducts.firstWhere(
      (p) => p.id == productId,
      orElse:
          () => ProductModel(name: LocaleKeys.validation_unknown_product.tr()),
    );

    return product.name ?? LocaleKeys.validation_unknown_product.tr();
  }
}
