
class Appointment {
  int? id;
  int? clientId;
  int? createdBy;
  int? doctorId;
  DateTime? appointmentDate;
  String? treatmentType;
  String? paymentMethod;
  String? status;
  String? clientName;
  bool? notificationRead;

  Appointment({
    this.id,
    this.clientId,
    this.createdBy,
    this.doctorId,
    this.appointmentDate,
    this.treatmentType,
    this.paymentMethod,
    this.status,
    this.clientName,
    this.notificationRead,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int?,
      clientId: json['client_id'] as int?,
      createdBy: json['created_by'] as int?,
      doctorId: json['doctor_id'] as int?,
      appointmentDate: json['appointment_date'] != null ? DateTime.parse(json['appointment_date']) : null,
      treatmentType: json['treatment_type'] as String?,
      paymentMethod: json['payment_method'] as String?,
      status: json['status'] as String?,
      clientName: json['client_name'] as String?,
      notificationRead: json['notification_read'] == 1,
    );
  }
}
