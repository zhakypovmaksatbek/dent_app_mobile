import 'package:flutter/material.dart';

class CustomSearchField<T> extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final List<CustomSearchItem<T>> suggestions;
  final Function(String)? onSearchTextChanged;
  final Function(CustomSearchItem<T>)? onSuggestionTap;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool enabled;

  const CustomSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.suggestions,
    this.onSearchTextChanged,
    this.onSuggestionTap,
    this.decoration,
    this.validator,
    this.readOnly = false,
    this.enabled = true,
  });

  @override
  State<CustomSearchField<T>> createState() => _CustomSearchFieldState<T>();
}

class _CustomSearchFieldState<T> extends State<CustomSearchField<T>> {
  final LayerLink _layerLink = LayerLink();
  bool _showSuggestions = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: widget.suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = widget.suggestions[index];
                      return InkWell(
                        onTap: () {
                          widget.controller.text = suggestion.text;
                          if (widget.onSuggestionTap != null) {
                            widget.onSuggestionTap!(suggestion);
                          }
                          _removeOverlay();
                          widget.focusNode.unfocus();
                        },
                        child:
                            suggestion.child ??
                            ListTile(dense: true, title: Text(suggestion.text)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _showSuggestions = true;
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _showSuggestions = false;
    }
  }

  void _updateOverlay() {
    if (_showSuggestions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _removeOverlay();
          _showOverlay();
        }
      });
    }
  }

  @override
  void didUpdateWidget(CustomSearchField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.suggestions != oldWidget.suggestions) {
      _updateOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        decoration:
            widget.decoration ??
            InputDecoration(
              hintText: widget.hint,
              border: const OutlineInputBorder(),
            ),
        onChanged: (value) {
          if (widget.onSearchTextChanged != null) {
            widget.onSearchTextChanged!(value);
          }
          _updateOverlay();
        },
        validator: widget.validator,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
      ),
    );
  }
}

class CustomSearchItem<T> {
  final String text;
  final T? item;
  final Widget? child;

  CustomSearchItem({required this.text, this.item, this.child});
}
