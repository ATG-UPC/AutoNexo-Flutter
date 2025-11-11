/// Modelo para un slot de horario en el calendario
class ScheduleSlotModel {
  final String time;
  final String day;
  final bool isAvailable;
  final String? appointmentId;

  ScheduleSlotModel({
    required this.time,
    required this.day,
    this.isAvailable = true,
    this.appointmentId,
  });

  factory ScheduleSlotModel.fromJson(Map<String, dynamic> json) {
    return ScheduleSlotModel(
      time: json['time'] as String,
      day: json['day'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      appointmentId: json['appointmentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'day': day,
      'isAvailable': isAvailable,
      'appointmentId': appointmentId,
    };
  }
}
