part of 'patient_bloc.dart';

sealed class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object> get props => [];
}

final class GetPatients extends PatientEvent {
  final int page;
  final int size;
  final bool isRefresh;

  const GetPatients({
    required this.page,
    this.size = 10,
    this.isRefresh = false,
  });

  @override
  List<Object> get props => [page, size];
}

final class SearchPatients extends PatientEvent {
  final String query;

  const SearchPatients(this.query);

  @override
  List<Object> get props => [query];
}

final class UpdatePatient extends PatientEvent {
  final int id;
  final PatientCreateModel patient;

  const UpdatePatient({required this.id, required this.patient});

  @override
  List<Object> get props => [id, patient];
}

final class DeletePatient extends PatientEvent {
  final int id;

  const DeletePatient(this.id);

  @override
  List<Object> get props => [id];
}

final class GetPatient extends PatientEvent {
  final int id;

  const GetPatient(this.id);

  @override
  List<Object> get props => [id];
}
