import 'package:dent_app_mobile/models/tooth/tooth_state_model.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';

class TeethDiagnosisData {
  static final List<ToothDiagnosisCategory> categories = [
    // ✅ 1. Белый — Здоровье
    ToothDiagnosisCategory(
      id: 'healthy',
      title: 'Здоровье',
      color: ColorConstants.white,
      diagnoses: [
        ToothStateModel(
          id: 'n',
          color: ColorConstants.white,
          title: 'N',
          description: 'Здоровый',
          icdCode: 'Z01.20',
        ),
        ToothStateModel(
          id: 'f',
          color: ColorConstants.white,
          title: 'F',
          description: 'Пломба',
          icdCode: 'Z98.811',
        ),
        ToothStateModel(
          id: 'cr',
          color: ColorConstants.white,
          title: 'Cr',
          description: 'Коронка',
          icdCode: 'Z97.2',
        ),
      ],
    ),

    // 🟡 2. Желтый — Лёгкий кариес
    ToothDiagnosisCategory(
      id: 'caries',
      title: 'Кариес',
      color: ColorConstants.caries,
      diagnoses: [
        ToothStateModel(
          id: 'c1',
          color: ColorConstants.c1,
          title: 'C1',
          description: 'Кариес поверхностный',
          icdCode: 'K02.51',
        ),
        ToothStateModel(
          id: 'c2',
          color: ColorConstants.c2,
          title: 'C2',
          description: 'Кариес средний',
          icdCode: 'K02.52',
        ),
        ToothStateModel(
          id: 'c3',
          color: ColorConstants.c3,
          title: 'C3',
          description: 'Кариес глубокий',
          icdCode: 'K02.53',
        ),
      ],
    ),

    // 🟣 3. Фиолетовый — Эндодонтия
    ToothDiagnosisCategory(
      id: 'endodontics',
      title: 'Эндодонтия',
      color: ColorConstants.endo,
      diagnoses: [
        ToothStateModel(
          id: 'pi',
          color: ColorConstants.p,
          title: 'Pi',
          description: 'Пульпит',
          icdCode: 'K04.02',
        ),
        ToothStateModel(
          id: 'per',
          color: ColorConstants.per,
          title: 'Per',
          description: 'Периодонтит',
          icdCode: 'K04.4',
        ),
        ToothStateModel(
          id: 'pn',
          color: ColorConstants.p,
          title: 'Pn',
          description: 'Некроз пульпы',
          icdCode: 'K04.1',
        ),
        ToothStateModel(
          id: 'rct',
          color: ColorConstants.endo,
          title: 'RCT',
          description: 'Канал лечен',
          icdCode: 'Z98.811',
        ),
      ],
    ),

    // 🔵 4. Синий — Импланты
    ToothDiagnosisCategory(
      id: 'implants',
      title: 'Импланты',
      color: ColorConstants.blue,
      diagnoses: [
        ToothStateModel(
          id: 'im',
          color: ColorConstants.im,
          title: 'Im',
          description: 'Имплантат',
          icdCode: 'Z96.5',
        ),
        ToothStateModel(
          id: 'im-cr',
          color: ColorConstants.im,
          title: 'Im-Cr',
          description: 'Имплант с коронкой',
          icdCode: 'Z96.5',
        ),
      ],
    ),

    // 🟤 5. Коричневый — Протезы
    ToothDiagnosisCategory(
      id: 'prosthetics',
      title: 'Протезы',
      color: ColorConstants.prosthetics,
      diagnoses: [
        ToothStateModel(
          id: 'cr-mc',
          color: ColorConstants.cr,
          title: 'Cr-MC',
          description: 'Металлокерамика',
          icdCode: 'Z97.2',
        ),
        ToothStateModel(
          id: 'cr-zr',
          color: ColorConstants.cr,
          title: 'Cr-Zr',
          description: 'Цирконий',
          icdCode: 'Z97.2',
        ),
        ToothStateModel(
          id: 've',
          color: ColorConstants.cr,
          title: 'Ve',
          description: 'Винир',
          icdCode: 'Z97.2',
        ),
      ],
    ),

    // ⚫ 6. Серый — Отсутствие
    ToothDiagnosisCategory(
      id: 'absence',
      title: 'Отсутствие зуба',
      color: ColorConstants.f,
      diagnoses: [
        ToothStateModel(
          id: 'x',
          color: ColorConstants.x,
          title: 'X',
          description: 'Отсутствует',
          icdCode: 'K08.109',
        ),
        ToothStateModel(
          id: 'xt',
          color: ColorConstants.x,
          title: 'Xt',
          description: 'Удален',
          icdCode: 'Z98.890',
        ),
      ],
    ),

    // 🟠 7. Оранжевый — Травмы
    ToothDiagnosisCategory(
      id: 'trauma',
      title: 'Травмы',
      color: ColorConstants.f,
      diagnoses: [
        ToothStateModel(
          id: 'fr',
          color: ColorConstants.f,
          title: 'Fr',
          description: 'Скол зуба',
          icdCode: 'S02.50',
        ),
      ],
    ),
  ];
}
