class ScheduleModel {
  int? scheduleId;
  String? startDate;
  String? endDate;
  List<DayScheduleResponses>? dayScheduleResponses;

  ScheduleModel({
    this.scheduleId,
    this.startDate,
    this.endDate,
    this.dayScheduleResponses,
  });

  ScheduleModel.fromJson(Map<String, dynamic> json) {
    scheduleId = json['scheduleId'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    if (json['dayScheduleResponses'] != null) {
      dayScheduleResponses = <DayScheduleResponses>[];
      json['dayScheduleResponses'].forEach((v) {
        dayScheduleResponses!.add(DayScheduleResponses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['scheduleId'] = scheduleId;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    if (dayScheduleResponses != null) {
      data['dayScheduleResponses'] =
          dayScheduleResponses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DayScheduleResponses {
  int? dayScheduleId;
  String? startTime;
  String? endTime;
  bool? workingDay;
  String? week;
  List<Breaks>? breaks;

  DayScheduleResponses({
    this.dayScheduleId,
    this.startTime,
    this.endTime,
    this.workingDay,
    this.week,
    this.breaks,
  });

  DayScheduleResponses.fromJson(Map<String, dynamic> json) {
    dayScheduleId = json['dayScheduleId'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    workingDay = json['workingDay'];
    week = json['week'];
    if (json['breaks'] != null) {
      breaks = <Breaks>[];
      json['breaks'].forEach((v) {
        breaks!.add(Breaks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dayScheduleId'] = dayScheduleId;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['workingDay'] = workingDay;
    data['week'] = week;
    if (breaks != null) {
      data['breaks'] = breaks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Breaks {
  int? id;
  String? title;
  String? startTime;
  String? endTime;

  Breaks({this.id, this.title, this.startTime, this.endTime});

  Breaks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    return data;
  }
}
