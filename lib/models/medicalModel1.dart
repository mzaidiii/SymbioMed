class MedicalRecordModel {
  final String symptoms;
  final String namasteCode;
  final String tm2Code;
  final String date;
  final String time;
  final String notes;

  MedicalRecordModel({
    required this.symptoms,
    required this.namasteCode,
    required this.tm2Code,
    required this.date,
    required this.time,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'symptoms': symptoms,
      'namasteCode': namasteCode,
      'tm2Code': tm2Code,
      'date': date,
      'time': time,
      'notes': notes,
    };
  }
}
