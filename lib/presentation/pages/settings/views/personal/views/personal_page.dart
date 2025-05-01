import 'package:auto_route/auto_route.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/users/user_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal/personal_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_action/personal_action_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/personal_card.dart';
import 'package:dent_app_mobile/presentation/theme/extension/card_style_extension.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'PersonalRoute')
class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final ScrollController _controller = ScrollController();
  late final PersonalActionCubit cubit;
  int page = 1;
  bool isLast = true;
  bool isLoading = false;
  List<UserModel> users = [];
  @override
  void initState() {
    cubit = PersonalActionCubit();
    _fetchPersonals();
    initListener();
    super.initState();
  }

  void initListener() {
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !isLast &&
          !isLoading) {
        page++;
        _fetchPersonals(); // Fetch the next page
      }
    });
  }

  void _fetchPersonals({bool isRefresh = false}) {
    if (isRefresh) {
      page = 1;
      users.clear();
    }
    context.read<PersonalCubit>().getPersonalList(page, isRefresh: isRefresh);
  }

  void _handleDelete(UserModel user) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content: Text(
              "Are you sure you want to delete ${user.fullName ?? 'this user'}?",
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  router.maybePop();
                },
              ),
              TextButton(
                child: const Text("Delete"),
                onPressed: () {
                  cubit.deletePerson(user.id!);
                  router.maybePop();
                },
              ),
            ],
          ),
    );
  }

  void _handleEdit(UserModel user) {
    router.push(CreatePersonalRoute(user: user));
  }

  final router = getIt<AppRouter>();
  void _navigateToCreatePersonal() {
    router.push(CreatePersonalRoute());
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use the theme extension for consistent styling
    final cardStyle = theme.extension<CardStyleExtension>();
    final decoration =
        cardStyle?.customCardDecoration ??
        CardStyleExtension.defaultCardDecoration;

    // Provide PersonalActionCubit
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: theme.colorScheme.primary,
          onPressed: _navigateToCreatePersonal,
          tooltip: "Add Personal",
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: BlocListener<PersonalActionCubit, PersonalActionState>(
          listener: personalActionListener,
          child: RefreshIndicator(
            onRefresh: () async {
              _fetchPersonals(isRefresh: true);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              controller: _controller,
              slivers: [
                SliverAppBar(title: Text(LocaleKeys.routes_personal.tr())),
                BlocConsumer<PersonalCubit, PersonalState>(
                  listener: personalListListener, // Renamed listener
                  builder: (context, state) {
                    // Handle loading state for the list itself
                    if (state is PersonalLoading &&
                        users.isEmpty &&
                        !isLoading) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state is PersonalError && users.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(child: Text(state.message)),
                      );
                    }
                    // Display list or empty message
                    if (users.isEmpty &&
                        !isLoading &&
                        state is! PersonalLoading) {
                      return SliverFillRemaining(
                        child: Center(child: Text("No personal found")),
                      );
                    }
                    return SliverPadding(
                      // Add padding around the list
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      sliver: SliverList.separated(
                        itemCount: users.length, // Add space for loader
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return PersonalCard(
                            decoration: decoration,
                            user: user,
                            theme: theme,
                            // Pass handlers to PersonalCard
                            onEditPressed: () => _handleEdit(user),
                            onDeletePressed: () => _handleDelete(user),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Listener for Personal list fetching
  void personalListListener(BuildContext context, PersonalState state) {
    // Use setState to trigger rebuilds based on list/loading changes
    if (state is PersonalLoaded) {
      isLast = state.personalData.last ?? true;
      isLoading = false; // Finished loading page
      if (state.isRefresh) {
        page = 1;
        users.clear();
      }
      users.addAll(state.personalData.content ?? []);
    } else if (state is PersonalLoading) {
      // Only set loading if not already loading to avoid multiple indicators
      if (!isLoading) isLoading = true;
    } else if (state is PersonalError) {
      isLoading = false; // Stop loading on error
      // Optionally show error SnackBar if list is not empty
      if (users.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
    } else {
      isLoading = false; // Ensure loading is false for other states
    }
  }

  // Listener for Personal actions (create, update, delete)
  void personalActionListener(BuildContext context, PersonalActionState state) {
    if (state is PersonalActionSuccess) {
      CherryToast.success(
        title: Text("Operation successful"),
        animationType: AnimationType.fromTop,
      ).show(context);
      _fetchPersonals(isRefresh: true); // Refresh list on success
    } else if (state is PersonalActionError) {
      CherryToast.error(
        title: Text(state.message),
        animationType: AnimationType.fromTop,
      ).show(context);
    }
  }
}
