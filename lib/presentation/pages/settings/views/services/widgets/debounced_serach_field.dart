import 'dart:async';

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// Callback türünü tanımla
typedef SearchCallback = void Function(String query);

class DebouncedSearchField extends StatefulWidget {
  final TextEditingController controller;
  final Duration debounceDuration;
  final SearchCallback onSearchChanged; // Debounce sonrası çağrılacak callback
  final String? hintText;

  const DebouncedSearchField({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.hintText,
  });

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Controller'daki değişiklikleri dinle
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    // Widget dispose edilirken timer'ı ve listener'ı temizle
    _debounce?.cancel();
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    // Önceki debounce'u iptal et
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Yeni debounce başlat
    _debounce = Timer(widget.debounceDuration, () {
      // Süre dolunca asıl callback'i çağır
      if (mounted) {
        // Widget hala ağaçta mı kontrol et
        widget.onSearchChanged(widget.controller.text);
      }
    });

    // Sadece ikonun durumunu güncellemek için setState çağır
    // Bu setState SADECE DebouncedSearchField widget'ını yeniden çizer.
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding'i widget'ın içine taşıdık
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText ?? LocaleKeys.buttons_search.tr(),
          prefixIcon: const Icon(Icons.search, size: 20),
          // İkonu doğrudan controller'ın metnine göre belirle
          suffixIcon:
              widget.controller.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      // Controller'ı temizle, listener tetiklenecek
                      widget.controller.clear();
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
        ),
        // onChanged burada kullanılmıyor, listener ile yönetiliyor
      ),
    );
  }
}
