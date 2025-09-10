class Car {
  final int? id;
  final String carId;
  final String description;
  final double price;
  final String brand;
  final String model;
  final int year;
  final int mileage;
  final String transmission;
  final String fuelType;
  final String engineSize;
  final int horsepower;
  final String driveType;
  final String exteriorColor;
  final String interiorColor;
  final int doors;
  final int seats;
  final String? mainImage;
  final List<String>? otherImages;
  final String contact;
  final String? vin;
  final bool status; // true = available, false = not available
  final bool condition; // true = new (0 miles), false = used (x miles)
  final DateTime createdAt;
  final DateTime updatedAt;

  Car({
    this.id,
    required this.carId,
    required this.description,
    required this.price,
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    required this.transmission,
    required this.fuelType,
    required this.engineSize,
    required this.horsepower,
    required this.driveType,
    required this.exteriorColor,
    required this.interiorColor,
    required this.doors,
    required this.seats,
    this.mainImage,
    this.otherImages,
    required this.contact,
    this.vin,
    required this.status,
    required this.condition,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      carId: json['car_id'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] as num).toDouble(),
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      mileage: json['mileage'] ?? 0,
      transmission: json['transmission'] ?? '',
      fuelType: json['fuel_type'] ?? '',
      engineSize: json['engine'] ?? '',
      horsepower: json['horsepower'] ?? 0,
      driveType: json['drive_type'] ?? '',
      exteriorColor: json['exterior_color'] ?? '',
      interiorColor: json['interior_color'] ?? '',
      doors: json['doors'] ?? 0,
      seats: json['seats'] ?? 0,
      mainImage: json['main_image'],
      otherImages: json['other_images'] != null
          ? List<String>.from(json['other_images'])
          : null,
      contact: json['contact'] ?? '',
      vin: json['vin'],
      status: json['status'] ?? true, // Default to available
      condition: json['condition'] ?? false, // Default to used
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'description': description,
      'price': price,
      'brand': brand,
      'model': model,
      'year': year,
      'mileage': mileage,
      'transmission': transmission,
      'fuel_type': fuelType,
      'engine': engineSize,
      'horsepower': horsepower,
      'drive_type': driveType,
      'exterior_color': exteriorColor,
      'interior_color': interiorColor,
      'doors': doors,
      'seats': seats,
      'contact': contact,
      'vin': vin,
      'status': status,
      'condition': condition,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    // Only include id if it's not null (for updates)
    if (id != null) {
      data['id'] = id;
    }

    // Only include car_id if it's not null (for updates)
    if (carId.isNotEmpty) {
      data['car_id'] = carId;
    }

    // Only include image fields if they're not null
    if (mainImage != null && mainImage!.isNotEmpty) {
      data['main_image'] = mainImage;
    }

    if (otherImages != null && otherImages!.isNotEmpty) {
      data['other_images'] = otherImages;
    }

    return data;
  }

  Car copyWith({
    int? id,
    String? carId,
    String? description,
    double? price,
    String? brand,
    String? model,
    int? year,
    int? mileage,
    String? transmission,
    String? fuelType,
    String? engineSize,
    int? horsepower,
    String? driveType,
    String? exteriorColor,
    String? interiorColor,
    int? doors,
    int? seats,
    String? mainImage,
    List<String>? otherImages,
    String? contact,
    String? vin,
    bool? status,
    bool? condition,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Car(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      description: description ?? this.description,
      price: price ?? this.price,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      mileage: mileage ?? this.mileage,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      engineSize: engineSize ?? this.engineSize,
      horsepower: horsepower ?? this.horsepower,
      driveType: driveType ?? this.driveType,
      exteriorColor: exteriorColor ?? this.exteriorColor,
      interiorColor: interiorColor ?? this.interiorColor,
      doors: doors ?? this.doors,
      seats: seats ?? this.seats,
      mainImage: mainImage ?? this.mainImage,
      otherImages: otherImages ?? this.otherImages,
      contact: contact ?? this.contact,
      vin: vin ?? this.vin,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Computed title from brand, model, and year
  String get computedTitle => '$brand $model $year';

  // Status display text
  String get statusText => status ? 'Available' : 'Not Available';

  // Condition display text
  String get conditionText => condition ? 'New' : 'Used';

  // Condition with mileage
  String get conditionWithMileage => condition
      ? 'New (0 miles)'
      : 'Used (${mileage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} miles)';
}
