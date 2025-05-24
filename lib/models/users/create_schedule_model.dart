class CreateScheduleModel {
  String? startDate;
  String? endDate;
  List<DayScheduleRequests>? dayScheduleRequests;

  CreateScheduleModel({this.startDate, this.endDate, this.dayScheduleRequests});

  CreateScheduleModel.fromJson(Map<String, dynamic> json) {
    startDate = json['startDate'];
    endDate = json['endDate'];
    if (json['dayScheduleRequests'] != null) {
      dayScheduleRequests = <DayScheduleRequests>[];
      json['dayScheduleRequests'].forEach((v) {
        dayScheduleRequests!.add(DayScheduleRequests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    if (dayScheduleRequests != null) {
      data['dayScheduleRequests'] =
          dayScheduleRequests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DayScheduleRequests {
  String? startTime;
  String? endTime;
  String? dayOfWeek;
  bool? workingDay;
  List<int>? breakPatternIds;

  DayScheduleRequests({
    this.startTime,
    this.endTime,
    this.dayOfWeek,
    this.workingDay,
    this.breakPatternIds,
  });

  DayScheduleRequests.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'];
    endTime = json['endTime'];
    dayOfWeek = json['dayOfWeek'];
    workingDay = json['workingDay'];
    breakPatternIds = json['breakPatternIds'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['dayOfWeek'] = dayOfWeek;
    data['workingDay'] = workingDay;
    data['breakPatternIds'] = breakPatternIds;
    return data;
  }
}
