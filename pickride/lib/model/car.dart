class Car {
  final String name;
  final String carType;
  final String plateNumber;
  final String id;

  Car({
    required this.name,
    required this.carType,
    required this.plateNumber,
    required this.id,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id']?.toString() ?? '',
      name: json['car_name'] ?? '',
      carType: json['car_type'] ?? '',
      plateNumber: json['plate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'car_name': name,
    'car_type': carType,
    'plate': plateNumber,
  };
}