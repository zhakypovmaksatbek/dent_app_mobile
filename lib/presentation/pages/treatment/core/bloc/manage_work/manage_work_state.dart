part of 'manage_work_cubit.dart';

@freezed
class ManageWorkState with _$ManageWorkState {
  const factory ManageWorkState.initial() = _Initial;
  const factory ManageWorkState.loading() = _Loading;
  const factory ManageWorkState.success(
    String message,
    bool isDelete,
    int workId,
  ) = _Success;
  const factory ManageWorkState.error({required ResponseModel message}) =
      _Error;
}
