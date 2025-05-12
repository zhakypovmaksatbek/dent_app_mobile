import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/warehouse/document_model.dart';
import 'package:dent_app_mobile/models/warehouse/product_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/warehouse/core/bloc/document/document_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/warehouse/core/bloc/product/product_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/warehouse/widgets/document_form_dialog.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/warehouse/widgets/document_item_card.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/warehouse/widgets/product_form_dialog.dart';
import 'package:dent_app_mobile/presentation/widgets/app_loader.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'WarehouseRoute')
class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key});

  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage>
    with SingleTickerProviderStateMixin {
  late final ProductCubit _productCubit;
  late final DocumentCubit _documentCubit;
  late final TabController _tabController;

  // Arama için değişkenler
  final TextEditingController _productSearchController =
      TextEditingController();
  final TextEditingController _documentSearchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _productCubit = ProductCubit();
    _documentCubit = DocumentCubit();
    _tabController = TabController(length: 2, vsync: this);

    _loadData();

    _tabController.addListener(() {
      // Clear any snackbars when switching tabs
      ScaffoldMessenger.of(context).clearSnackBars();
    });

    // Arama kontrolcüleri için listener'lar
    _productSearchController.addListener(_handleProductSearch);
    _documentSearchController.addListener(_handleDocumentSearch);
  }

  // Ürün aramak için debounce işlemi
  Timer? _productSearchDebounce;
  void _handleProductSearch() {
    // Debounce arama - çok hızlı yazılınca her tuşta API isteği göndermemek için
    if (_productSearchDebounce?.isActive ?? false)
      _productSearchDebounce!.cancel();
    _productSearchDebounce = Timer(const Duration(milliseconds: 500), () {
      _productCubit.getProducts(search: _productSearchController.text);
    });
  }

  // Belge aramak için debounce işlemi
  Timer? _documentSearchDebounce;
  void _handleDocumentSearch() {
    // Debounce arama - çok hızlı yazılınca her tuşta API isteği göndermemek için
    if (_documentSearchDebounce?.isActive ?? false)
      _documentSearchDebounce!.cancel();
    _documentSearchDebounce = Timer(const Duration(milliseconds: 500), () {
      _documentCubit.getDocuments(search: _documentSearchController.text);
    });
  }

  @override
  void dispose() {
    _productCubit.close();
    _documentCubit.close();
    _tabController.dispose();
    _productSearchController.dispose();
    _documentSearchController.dispose();
    _productSearchDebounce?.cancel();
    _documentSearchDebounce?.cancel();
    super.dispose();
  }

  void _loadData() {
    _productCubit.getProducts();
    _documentCubit.getDocuments();
  }

  void _showAddEditProductDialog({ProductModel? product}) {
    ProductFormDialog.show(
      context: context,
      initialProduct: product,
      onSave: (updatedProduct) {
        if (product != null) {
          _productCubit.updateProduct(updatedProduct);
        } else {
          _productCubit.createProduct(updatedProduct);
        }
      },
    );
  }

  void _confirmDeleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.buttons_delete.tr()),
            content: Text(
              LocaleKeys.alerts_delete_product_confirmation.tr(
                namedArgs: {'name': product.name ?? '-'},
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.buttons_cancel.tr()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (product.id != null) {
                    _productCubit.deleteProduct(product.id!);
                  }
                  Navigator.pop(context);
                },
                child: Text(LocaleKeys.buttons_delete.tr()),
              ),
            ],
          ),
    );
  }

  void _showCreateDocumentDialog() {
    // Use DocumentFormDialog with products from ProductCubit
    DocumentFormDialog.show(
      context: context,
      onSave: (document) {
        _documentCubit.createDocument(document);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _productCubit),
        BlocProvider.value(value: _documentCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.routes_warehouse.tr()),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: LocaleKeys.buttons_refresh.tr(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: LocaleKeys.general_products.tr(),
                icon: Icon(Icons.inventory),
              ),
              Tab(
                text: LocaleKeys.general_documents.tr(),
                icon: Icon(Icons.description),
              ),
            ],
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            // Product state listener
            BlocListener<ProductCubit, ProductState>(
              listener: (context, state) {
                if (state is ProductError) {
                  AppSnackBar.showErrorSnackBar(context, state.message);
                }

                if (state is ProductCreated) {
                  AppSnackBar.showSuccessSnackBar(
                    context,
                    LocaleKeys.notifications_product_created_successfully.tr(),
                  );
                }

                if (state is ProductUpdated) {
                  AppSnackBar.showSuccessSnackBar(
                    context,
                    LocaleKeys.notifications_product_updated_successfully.tr(),
                  );
                }

                if (state is ProductDeleted) {
                  AppSnackBar.showSuccessSnackBar(
                    context,
                    LocaleKeys.notifications_product_deleted_successfully.tr(),
                  );
                }
              },
            ),

            // Document state listener
            BlocListener<DocumentCubit, DocumentState>(
              listener: (context, state) {
                if (state is DocumentError) {
                  AppSnackBar.showErrorSnackBar(context, state.message);
                }

                if (state is DocumentCreated) {
                  AppSnackBar.showSuccessSnackBar(
                    context,
                    LocaleKeys.notifications_document_created_successfully.tr(),
                  );
                }

                if (state is DocumentUpdated) {
                  AppSnackBar.showSuccessSnackBar(
                    context,
                    LocaleKeys.notifications_document_updated_successfully.tr(),
                  );
                }

                if (state is DocumentDeleted) {
                  AppSnackBar.showSuccessSnackBar(
                    context,
                    LocaleKeys.notifications_document_deleted_successfully.tr(),
                  );
                }
              },
            ),
          ],
          child: TabBarView(
            controller: _tabController,
            children: [
              // Products Tab
              _buildProductsTab(),

              // Documents Tab
              _buildDocumentsTab(),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    // Show different FAB based on selected tab
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        return FloatingActionButton(
          onPressed:
              _tabController.index == 0
                  ? () => _showAddEditProductDialog()
                  : () => _showCreateDocumentDialog(),
          tooltip:
              _tabController.index == 0
                  ? LocaleKeys.buttons_add_product.tr()
                  : LocaleKeys.buttons_add_document.tr(),
          child: const Icon(Icons.add),
        );
      },
    );
  }

  Widget _buildProductsTab() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        // Arama kutusu widget'ı
        final searchBox = Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _productSearchController,
            decoration: InputDecoration(
              hintText: LocaleKeys.buttons_product_search.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _productSearchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _productSearchController.clear();
                          // Temizlediğimizde tüm ürünleri göster
                          _productCubit.getProducts();
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        );

        if (state is ProductLoading) {
          return Column(
            children: [
              searchBox,
              const Expanded(child: Center(child: AppLoader())),
            ],
          );
        }

        if (state is ProductLoaded) {
          final products = state.products;

          if (products.isEmpty) {
            return Column(
              children: [
                searchBox,
                Expanded(
                  child: Center(
                    child:
                        _productSearchController.text.isNotEmpty
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  LocaleKeys.notifications_not_found_products
                                      .tr(),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _productSearchController.clear();
                                    _productCubit.getProducts();
                                  },
                                  icon: const Icon(Icons.clear),
                                  label: Text(
                                    LocaleKeys.buttons_clear_search.tr(),
                                  ),
                                ),
                              ],
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  LocaleKeys.notifications_product_no_available
                                      .tr(),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _showAddEditProductDialog(),
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    LocaleKeys.buttons_add_product.tr(),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              // Arama kutusu
              searchBox,

              // Summary card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              LocaleKeys.general_total_products.tr(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              products.length.toString(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              LocaleKeys.general_total_items.tr(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              products
                                  .fold(
                                    0,
                                    (sum, product) =>
                                        sum + (product.quantity ?? 0),
                                  )
                                  .toString(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              LocaleKeys.general_total_value.tr(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              products
                                  .fold(
                                    0.0,
                                    (sum, product) =>
                                        sum + (product.totalPrice ?? 0),
                                  )
                                  .toString(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Products list
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.separated(
                    itemCount: products.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return CustomCardDecoration(
                        child: ListTile(
                          title: Text(product.name ?? 'Unnamed Product'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${LocaleKeys.general_price.tr()}: ${product.price ?? 0}',
                              ),
                              Text(
                                '${LocaleKeys.general_quantity.tr()}: ${product.quantity ?? 0}',
                              ),
                              Text(
                                '${LocaleKeys.general_total_amount.tr()}: ${product.totalPrice ?? 0}',
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            padding: EdgeInsets.zero,
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showAddEditProductDialog(product: product);
                              } else if (value == 'delete') {
                                _confirmDeleteProduct(product);
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text(LocaleKeys.buttons_edit.tr()),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text(LocaleKeys.buttons_delete.tr()),
                                      ],
                                    ),
                                  ),
                                ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            searchBox,
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleKeys.notifications_product_no_available.tr()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _productCubit.getProducts(),
                      child: Text(LocaleKeys.buttons_load_products.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentsTab() {
    return BlocBuilder<DocumentCubit, DocumentState>(
      builder: (context, state) {
        // Arama kutusu widget'ı
        final searchBox = Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _documentSearchController,
            decoration: InputDecoration(
              hintText: LocaleKeys.buttons_document_search.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _documentSearchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _documentSearchController.clear();
                          // Temizlediğimizde tüm belgeleri göster
                          _documentCubit.getDocuments();
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        );

        if (state is DocumentLoading) {
          return Column(
            children: [
              searchBox,
              const Expanded(child: Center(child: AppLoader())),
            ],
          );
        }

        if (state is DocumentLoaded) {
          final documents = state.documents;

          if (documents.isEmpty) {
            return Column(
              children: [
                searchBox,
                Expanded(
                  child: Center(
                    child:
                        _documentSearchController.text.isNotEmpty
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  LocaleKeys.notifications_document_no_available
                                      .tr(),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _documentSearchController.clear();
                                    _documentCubit.getDocuments();
                                  },
                                  icon: const Icon(Icons.clear),
                                  label: Text(
                                    LocaleKeys.buttons_clear_search.tr(),
                                  ),
                                ),
                              ],
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  LocaleKeys.notifications_document_no_available
                                      .tr(),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _showCreateDocumentDialog,
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    LocaleKeys.buttons_add_document.tr(),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              // Arama kutusu
              searchBox,

              // Summary card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              LocaleKeys.general_total_documents.tr(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              documents.length.toString(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              LocaleKeys.general_total_value.tr(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              documents
                                  .fold(
                                    0.0,
                                    (sum, doc) => sum + (doc.totalPrice ?? 0),
                                  )
                                  .toString(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Documents list
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.separated(
                    itemCount: documents.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      return DocumentItemCard(
                        document: document,
                        onDelete: () => _confirmDeleteDocument(document),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            searchBox,
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleKeys.notifications_document_no_available.tr()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _documentCubit.getDocuments(),
                      child: Text(LocaleKeys.buttons_load_documents.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteDocument(DocumentModel document) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.alerts_delete_document.tr()),
            content: Text(
              LocaleKeys.notifications_delete_document_confirmation.tr(
                namedArgs: {'name': document.supplier ?? '-'},
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.buttons_cancel.tr()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (document.id != null) {
                    _documentCubit.deleteDocument(document.id!);
                  }
                  Navigator.pop(context);
                },
                child: Text(LocaleKeys.buttons_delete.tr()),
              ),
            ],
          ),
    );
  }
}
