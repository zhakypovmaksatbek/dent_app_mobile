import 'dart:async';

import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/pattern/pattern_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatternSelectionBottomSheet extends StatefulWidget {
  const PatternSelectionBottomSheet({
    super.key,
    required this.patternType,
    required this.title,
    required this.onPatternSelected,
    required this.patternCubit,
  });

  final PatternType patternType;
  final String title;
  final Function(String pattern) onPatternSelected;
  final PatternCubit patternCubit;

  @override
  State<PatternSelectionBottomSheet> createState() =>
      _PatternSelectionBottomSheetState();
}

class _PatternSelectionBottomSheetState
    extends State<PatternSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    // Initial load of patterns without search
    widget.patternCubit.getPatternList(widget.patternType);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (value.isEmpty || value.length >= 2) {
        widget.patternCubit.getPatternList(
          widget.patternType,
          search: value.isEmpty ? null : value,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.patternCubit,
      child: BlocBuilder<PatternCubit, PatternState>(
        builder: (context, state) {
          final isSearching = state is PatternLoading;

          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDragHandle(),
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    _buildSearchBar(isSearching),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildPatternList(
                        state,
                        scrollController: scrollController,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isSearching) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search patterns...',
        prefixIcon:
            isSearching
                ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(8),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.search),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                    widget.patternCubit.getPatternList(widget.patternType);
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildPatternList(
    PatternState state, {
    ScrollController? scrollController,
  }) {
    if (state is PatternInitial) {
      return const Center(child: Text('Select pattern type'));
    } else if (state is PatternLoading) {
      return const Center(child: LoadingWidget());
    } else if (state is PatternError) {
      return Center(child: Text(state.message));
    } else if (state is PatternLoaded) {
      final List<String> patterns = state.pattern.values ?? [];

      if (patterns.isEmpty) {
        return const Center(child: Text('No data available'));
      }

      return ListView.separated(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: patterns.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final pattern = patterns[index];
          return InkWell(
            onTap: () {
              widget.onPatternSelected(pattern);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Text(pattern, style: const TextStyle(fontSize: 16)),
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('Unknown state'));
    }
  }
}
