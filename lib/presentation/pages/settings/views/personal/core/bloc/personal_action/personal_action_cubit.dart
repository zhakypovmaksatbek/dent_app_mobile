import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'personal_action_state.dart';

class PersonalActionCubit extends Cubit<PersonalActionState> {
  PersonalActionCubit() : super(PersonalActionInitial());
}
