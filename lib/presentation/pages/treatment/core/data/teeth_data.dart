import 'package:dent_app_mobile/models/tooth/tooth_state_model.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';

class TeethData {
  static final List<ToothStateModel> teeth = [
    ToothStateModel(
      id: '1',
      color: ColorConstants.c1,
      title: 'C1',
      description: 'Кариес поверхностный',
    ),
    ToothStateModel(
      id: '2',
      color: ColorConstants.c2,
      title: 'C2',
      description: 'Кариес средний',
    ),
    ToothStateModel(
      id: '3',
      color: ColorConstants.c3,
      title: 'C3',
      description: 'Кариес глубокий',
    ),
    ToothStateModel(
      id: '4',
      color: ColorConstants.x,
      title: 'X',
      description: 'Удалён',
    ),
    ToothStateModel(
      id: '5',
      color: ColorConstants.p,
      title: 'P',
      description: 'Пульпит',
    ),
    ToothStateModel(
      id: '6',
      color: ColorConstants.n,
      title: 'N',
      description: 'Здоровый',
    ),
    ToothStateModel(
      id: '7',
      color: ColorConstants.f,
      title: 'F',
      description: 'Пломба',
    ),
    ToothStateModel(
      id: '8',
      color: ColorConstants.im,
      title: 'IM',
      description: 'Имплантат',
    ),
    ToothStateModel(
      id: '9',
      color: ColorConstants.cr,
      title: 'CR',
      description: 'Коронка',
    ),
    ToothStateModel(
      id: '10',
      color: ColorConstants.per,
      title: 'PER',
      description: 'Периодонтит',
    ),
  ];
}
