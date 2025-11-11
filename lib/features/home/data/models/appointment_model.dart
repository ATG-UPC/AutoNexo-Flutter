/// Modelo para una cita de mantenimiento
class AppointmentModel {
  final String id;
  final String date;
  final String time;
  final String maintenance;
  final String workshop;
  final String mechanic;

  AppointmentModel({
    required this.id,
    required this.date,
    required this.time,
    required this.maintenance,
    required this.workshop,
    required this.mechanic,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      maintenance: json['maintenance'] as String,
      workshop: json['workshop'] as String,
      mechanic: json['mechanic'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'maintenance': maintenance,
      'workshop': workshop,
      'mechanic': mechanic,
    };
  }
}
