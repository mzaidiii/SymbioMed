class UserModel {
  final String fullName;
  final int age;
  final String gender;
  final double height;
  final double weight;

  UserModel({
    required this.fullName,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
    };
  }
}
