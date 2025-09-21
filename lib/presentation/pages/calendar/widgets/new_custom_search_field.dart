// lib/custom_search_input.dart

import 'dart:async';
import 'dart:math';

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/widgets/image/custom_asset_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NewCustomSearchInput<T> extends StatefulWidget {
  final Future<List<T>> Function(String query) onSearch;
  final Widget Function(T item) resultBuilder;
  final void Function(T item) onItemSelected;
  final String? hintText;
  final ScrollController? scrollController;
  final Widget Function(String query)? noResultsFoundBuilder;

  /// Svg icon path(write only name of the file)
  final String prefixIconPath;
  final String Function(T item) displayStringForItem;
  final Duration debounceDuration;
  final bool enabled;
  final VoidCallback? onSelectionCleared;

  final T? initialValue;

  const NewCustomSearchInput({
    super.key,
    required this.onSearch,
    required this.resultBuilder,
    required this.onItemSelected,
    this.hintText,
    this.scrollController,
    required this.prefixIconPath,
    required this.displayStringForItem,
    this.enabled = true,
    this.onSelectionCleared,
    this.initialValue,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.noResultsFoundBuilder,
  });

  @override
  State<NewCustomSearchInput<T>> createState() =>
      NewCustomSearchInputState<T>();
}

class NewCustomSearchInputState<T> extends State<NewCustomSearchInput<T>> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  List<T> _results = [];
  bool _isLoading = false;
  Timer? _debounce;
  T? _selectedItem;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selectItem(widget.initialValue as T, isInitial: true);
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (_selectedItem == null) {
          _ensureVisible();
          _debouncedPerformSearch();
        }
      } else {
        _removeOverlay();
      }
    });

    _controller.addListener(() {
      if (_selectedItem != null) return;
      _debouncedPerformSearch();
    });
  }

  void _ensureVisible() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _textFieldKey.currentContext != null) {
        Scrollable.ensureVisible(
          _textFieldKey.currentContext!,
          alignment: 0.1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void selectItemProgrammatically(T item) {
    _selectItem(item);
  }

  void _selectItem(T item, {bool isInitial = false}) {
    setState(() {
      _selectedItem = item;
      _controller.text = widget.displayStringForItem(item);
      _results = [];
      _isLoading = false;
    });
    _removeOverlay();
    _focusNode.unfocus();

    if (!isInitial) {
      widget.onItemSelected(item);
    }
  }

  void _clearSelection({bool notifyParent = false}) {
    setState(() {
      _selectedItem = null;
      _controller.clear();
      _results = [];
    });
    if (notifyParent) {
      widget.onSelectionCleared?.call();
    }
  }

  void _debouncedPerformSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(widget.debounceDuration, () {
      if (mounted) {
        _performSearch();
      }
    });
  }

  void _performSearch() async {
    if (!mounted || _selectedItem != null) return;

    setState(() => _isLoading = true);
    final newResults = await widget.onSearch(_controller.text);
    if (!mounted) return;
    setState(() {
      _results = newResults;
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    final overlay = Overlay.of(context);
    final renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final textFieldPosition = renderBox.localToGlobal(Offset.zero);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    final spaceBelow =
        screenHeight - keyboardHeight - textFieldPosition.dy - size.height - 16;
    const defaultMaxHeight = 220.0;
    final overlayMaxHeight = max(0.0, min(defaultMaxHeight, spaceBelow));

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 8.0),
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: overlayMaxHeight),
                  child: _buildResultsList(),
                ),
              ),
            ),
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_results.isEmpty && _controller.text.isNotEmpty) {
      if (widget.noResultsFoundBuilder != null) {
        return widget.noResultsFoundBuilder!(_controller.text);
      } else {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(LocaleKeys.notifications_no_search_results_found.tr()),
        );
      }
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _results.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = _results[index];
        return InkWell(
          onTap: () {
            _selectItem(item);
          },
          child: widget.resultBuilder(item),
        );
      },
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelectionLocked = _selectedItem != null;

    final suffixIcon =
        isSelectionLocked
            ? IconButton(
              icon: const Icon(Icons.close),
              onPressed:
                  widget.enabled
                      ? () => _clearSelection(notifyParent: true)
                      : null,
            )
            : _controller.text.isNotEmpty
            ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.enabled ? _controller.clear : null,
            )
            : null;
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        key: _textFieldKey,

        readOnly: isSelectionLocked,
        controller: _controller,
        focusNode: _focusNode,
        showCursor: !isSelectionLocked,
        enableInteractiveSelection: !isSelectionLocked,
        enabled: widget.enabled,
        decoration: InputDecoration(
          labelText: widget.hintText ?? LocaleKeys.buttons_search.tr(),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomAssetImage(
              path: "assets/svg/${widget.prefixIconPath}.svg",
              height: 20,
              width: 20,
            ),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
