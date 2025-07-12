import 'dart:async';

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final Function()? onAddPatient;

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
    this.onAddPatient,
  });

  @override
  State<CustomSearchField<T>> createState() => _CustomSearchFieldState<T>();
}

class _CustomSearchFieldState<T> extends State<CustomSearchField<T>> {
  final LayerLink _layerLink = LayerLink();
  bool _showSuggestions = false;
  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _removeOverlay();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;

    if (widget.focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onSearchTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (widget.onSearchTextChanged != null) {
        widget.onSearchTextChanged!(value);
      }
      if (value.isNotEmpty) {
        _showSuggestions = true;
        _updateOverlay();
      } else {
        _showSuggestions = false;
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    // Klavye yüksekliğini al
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;

    // İçeriğe göre dinamik overlay yüksekliği hesapla
    double dynamicOverlayHeight;
    if (widget.suggestions.isEmpty) {
      // Sonuç yok durumu: text + button + padding
      dynamicOverlayHeight = 120;
    } else {
      // Her item için yaklaşık 60px + padding
      const double itemHeight = 60;
      const double padding = 16;
      dynamicOverlayHeight = (widget.suggestions.length * itemHeight + padding)
          .clamp(80, 200);
    }

    // TextFormField'in alt kısmının ekran pozisyonu
    final double fieldBottom = position.dy + size.height;

    // Kullanılabilir alan (klavye üstü)
    final double availableSpace = screenHeight - keyboardHeight - fieldBottom;

    // Eğer kullanılabilir alan overlay için yeterli değilse, yukarı kaydır
    double offsetY = size.height;
    double maxHeight = dynamicOverlayHeight;

    if (availableSpace < dynamicOverlayHeight && keyboardHeight > 0) {
      // Yukarıdaki kullanılabilir alanı hesapla
      final double spaceAbove = position.dy;

      // Eğer dinamik yükseklik küçükse, TextField'e yakın konumlandır
      if (dynamicOverlayHeight <= 120) {
        offsetY = -dynamicOverlayHeight - 8; // Küçük gap
        maxHeight = dynamicOverlayHeight;
      } else {
        maxHeight = (spaceAbove - 20).clamp(100, dynamicOverlayHeight);
        offsetY = -maxHeight;
      }
    } else if (availableSpace < dynamicOverlayHeight) {
      // Aşağıdaki alan sınırlıysa, yüksekliği sınırla
      maxHeight = (availableSpace - 20).clamp(80, dynamicOverlayHeight);
    }

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, offsetY),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                    minHeight: 50,
                  ),
                  child:
                      widget.suggestions.isEmpty
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  LocaleKeys.notifications_no_data_found.tr(),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    _removeOverlay();
                                    widget.focusNode.unfocus();
                                    widget.onAddPatient?.call();
                                  },
                                  icon: const Icon(Icons.add),
                                  label: Text(LocaleKeys.buttons_add.tr()),
                                ),
                                const SizedBox.shrink(),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: widget.suggestions.length,
                            itemBuilder: (context, index) {
                              if (index >= widget.suggestions.length) {
                                return const SizedBox.shrink();
                              }
                              final suggestion = widget.suggestions[index];
                              return InkWell(
                                onTap: () {
                                  widget.controller.text = suggestion.text;
                                  if (widget.onSuggestionTap != null) {
                                    widget.onSuggestionTap!(suggestion);
                                  }
                                  _removeOverlay();
                                  // Use a post-frame callback to safely unfocus
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) {
                                      widget.focusNode.unfocus();
                                    }
                                  });
                                },
                                child:
                                    suggestion.child ??
                                    ListTile(
                                      dense: true,
                                      title: Text(suggestion.text),
                                    ),
                              );
                            },
                          ),
                ),
              ),
            ),
          ),
    );

    try {
      Overlay.of(context).insert(_overlayEntry!);
      _showSuggestions = true;
    } catch (e) {
      debugPrint('Error showing overlay: $e');
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (e) {
        debugPrint('Error removing overlay: $e');
      }
      _overlayEntry = null;
      _showSuggestions = false;
    }
  }

  void _updateOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_showSuggestions) {
          _removeOverlay();
          _showOverlay();
        }
      }
    });
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
    // Klavye yüksekliği değiştiğinde overlay'i güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _showSuggestions && _overlayEntry != null) {
        _updateOverlay();
      }
    });

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
        onChanged: _onSearchTextChanged,
        validator: widget.validator,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        contextMenuBuilder: (context, editableTextState) {
          // Disable context menu if text field is not focused or not mounted
          if (!mounted || !widget.focusNode.hasFocus) {
            return const SizedBox.shrink();
          }
          // Return default context menu for focused text field
          return AdaptiveTextSelectionToolbar.editableText(
            editableTextState: editableTextState,
          );
        },
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
