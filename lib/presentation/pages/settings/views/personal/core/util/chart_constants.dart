import 'package:dent_app_mobile/presentation/pages/settings/views/personal/views/personal_detail_page.dart';
import 'package:flutter/material.dart';

class ChartConstants {
  // Mock data for stats
  final List<ChartData> weeklyData = [
    ChartData('Mon', 4),
    ChartData('Tue', 5),
    ChartData('Wed', 3),
    ChartData('Thu', 6),
    ChartData('Fri', 4),
    ChartData('Sat', 2),
    ChartData('Sun', 0),
  ];

  final List<ChartData> monthlyAppointments = [
    ChartData('Jan', 12),
    ChartData('Feb', 15),
    ChartData('Mar', 10),
    ChartData('Apr', 13),
    ChartData('May', 16),
    ChartData('Jun', 14),
  ];

  final List<ChartData> monthlyPatients = [
    ChartData('Jan', 8),
    ChartData('Feb', 12),
    ChartData('Mar', 7),
    ChartData('Apr', 9),
    ChartData('May', 11),
    ChartData('Jun', 10),
  ];

  final List<ChartData> quarterlyData = [
    ChartData('Q1', 15),
    ChartData('Q2', 25),
    ChartData('Q3', 18),
    ChartData('Q4', 30),
  ];

  // Mock working hours data
  final Map<String, List<TimeOfDay>> workingHours = {
    'Monday': [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
    ],
    'Tuesday': [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
    ],
    'Wednesday': [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
    ],
    'Thursday': [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
    ],
    'Friday': [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 17, minute: 0),
    ],
    'Saturday': [
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 15, minute: 0),
    ],
    'Sunday': [], // Off day
  };

  // Mock patients data
  final List<Map<String, dynamic>> recentPatients = [
    {
      'name': 'Anna Johnson',
      'date': '12.06.2023',
      'service': 'Dental Cleaning',
    },
    {'name': 'Mark Walters', 'date': '10.06.2023', 'service': 'Root Canal'},
    {'name': 'Sarah Smith', 'date': '08.06.2023', 'service': 'Teeth Whitening'},
    {'name': 'John Doe', 'date': '05.06.2023', 'service': 'Dental Implant'},
    {'name': 'Emily Wilson', 'date': '01.06.2023', 'service': 'Consultation'},
  ];
}
