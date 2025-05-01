import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_patient/personal_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/personal_patient_item.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'PersonalPatientsRoute')
class PersonalPatientsPage extends StatefulWidget {
  const PersonalPatientsPage({super.key, required this.userId});
  final int userId;
  @override
  State<PersonalPatientsPage> createState() => _PersonalPatientsPageState();
}

class _PersonalPatientsPageState extends State<PersonalPatientsPage> {
  late final PersonalPatientCubit _personalPatientCubit;
  int page = 1;
  bool isLast = true;
  bool isLoading = false;
  List<VisitModel> visits = [];
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _personalPatientCubit = PersonalPatientCubit();
    _fetchVisits(isRefresh: true);
    getMoreVisits();
  }

  void getMoreVisits() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLast &&
          !isLoading) {
        page++;
        _fetchVisits();
      }
    });
  }

  void _fetchVisits({bool isRefresh = false}) {
    if (isRefresh) {
      page = 1;
      visits.clear();
    }
    _personalPatientCubit.getVisits(
      userId: widget.userId,
      page: page,
      isRefresh: isRefresh,
    );
  }

  @override
  void dispose() {
    _personalPatientCubit.close();
    _scrollController.dispose();
    visits.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _personalPatientCubit,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            _fetchVisits(isRefresh: true);
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                title: Text('Personal Patients'),
                centerTitle: true,
                floating: true,
                pinned: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver:
                    BlocConsumer<PersonalPatientCubit, PersonalPatientState>(
                      listener: (context, state) {
                        if (state is PersonalPatientLoaded) {
                          if (state.isRefresh) {
                            page = 1;
                            visits.clear();
                          }
                          visits.addAll(state.visits.content ?? []);
                          isLast = state.visits.last ?? true;
                          isLoading = false;
                        }
                      },
                      builder: (context, state) {
                        return SliverList.builder(
                          itemCount: visits.length,
                          itemBuilder: (context, index) {
                            final patient = visits[index];
                            return PersonalPatientItem(patient: patient);
                          },
                        );
                      },
                    ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 50),
                sliver: BlocBuilder<PersonalPatientCubit, PersonalPatientState>(
                  builder: (context, state) {
                    if (state is PersonalPatientLoading) {
                      return const SliverToBoxAdapter(child: LoadingWidget());
                    }
                    return const SliverToBoxAdapter(child: SizedBox());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
