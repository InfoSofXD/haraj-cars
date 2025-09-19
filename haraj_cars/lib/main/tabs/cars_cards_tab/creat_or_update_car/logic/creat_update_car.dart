// creat_update_car.dart - Unified logic for creating and updating cars

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:haraj/models/car.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../data/di/data_source_factory.dart';

class CreateUpdateCarLogic {
  // Controllers
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _engineController = TextEditingController();
  final _horsepowerController = TextEditingController();
  final _exteriorColorController = TextEditingController();
  final _interiorColorController = TextEditingController();
  final _doorsController = TextEditingController();
  final _seatsController = TextEditingController();
  final _vinController = TextEditingController();

  // Dropdown values
  String _selectedTransmission = 'Automatic';
  String _selectedFuelType = 'Petrol';
  String _selectedDriveType = 'FWD';
  String _selectedBrand = '';

  // Status and timing fields
  int _status = 1; // Default to available
  DateTime? _showAt;
  DateTime? _unShowAt;
  DateTime? _auctionStartAt;
  DateTime? _auctionEndAt;
  DateTime? _deleteAt;

  // Images
  File? _selectedImage;
  List<File> _otherImages = [];

  // State
  bool _isLoading = false;
  final _uuid = const Uuid();

  // Getters for UI
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get priceController => _priceController;
  TextEditingController get contactController => _contactController;
  TextEditingController get modelController => _modelController;
  TextEditingController get yearController => _yearController;
  TextEditingController get mileageController => _mileageController;
  TextEditingController get engineController => _engineController;
  TextEditingController get horsepowerController => _horsepowerController;
  TextEditingController get exteriorColorController => _exteriorColorController;
  TextEditingController get interiorColorController => _interiorColorController;
  TextEditingController get doorsController => _doorsController;
  TextEditingController get seatsController => _seatsController;
  TextEditingController get vinController => _vinController;

  String get selectedTransmission => _selectedTransmission;
  String get selectedFuelType => _selectedFuelType;
  String get selectedDriveType => _selectedDriveType;
  String get selectedBrand => _selectedBrand;

  int get status => _status;
  DateTime? get showAt => _showAt;
  DateTime? get unShowAt => _unShowAt;
  DateTime? get auctionStartAt => _auctionStartAt;
  DateTime? get auctionEndAt => _auctionEndAt;
  DateTime? get deleteAt => _deleteAt;

  File? get selectedImage => _selectedImage;
  List<File> get otherImages => _otherImages;
  bool get isLoading => _isLoading;

  // Brands list
  List<String> _brands = [];
  List<String> get brands => _brands;

  // Initialize logic
  Future<void> initialize({Car? existingCar}) async {
    await _loadBrands();
    if (existingCar != null) {
      _populateFields(existingCar);
    }
  }

  // Load brands
  Future<void> _loadBrands() async {
    try {
      final predefinedBrands = [
        'Toyota', 'Honda', 'Nissan', 'Mazda', 'Subaru', 'Mitsubishi',
        'Lexus', 'Infiniti', 'Acura', 'BMW', 'Mercedes-Benz', 'Audi',
        'Volkswagen', 'Porsche', 'Volvo', 'Ford', 'Chevrolet', 'Dodge',
        'Jeep', 'Hyundai', 'Kia', 'Genesis', 'Land Rover', 'Jaguar',
        'Mini', 'Fiat', 'Alfa Romeo', 'Maserati', 'Ferrari', 'Lamborghini'
      ];
      _brands = predefinedBrands;
      if (_brands.isNotEmpty && _selectedBrand.isEmpty) {
        _selectedBrand = _brands.first;
      }
    } catch (e) {
      print('Error loading brands: $e');
    }
  }

  // Populate fields for edit mode
  void _populateFields(Car car) {
    _descriptionController.text = car.description;
    _priceController.text = car.price.toString();
    _contactController.text = car.contact;

    _selectedBrand = car.brand;
    _modelController.text = car.model;
    _yearController.text = car.year.toString();
    _mileageController.text = car.mileage.toString();
    _engineController.text = car.engineSize;
    _horsepowerController.text = car.horsepower.toString();
    _exteriorColorController.text = car.exteriorColor;
    _interiorColorController.text = car.interiorColor;
    _doorsController.text = car.doors.toString();
    _seatsController.text = car.seats.toString();
    _vinController.text = car.vin ?? '';

    _status = car.status;
    _showAt = car.showAt;
    _unShowAt = car.unShowAt;
    _auctionStartAt = car.auctionStartAt;
    _auctionEndAt = car.auctionEndAt;
    _deleteAt = car.deleteAt;

    _selectedTransmission = car.transmission;
    _selectedFuelType = car.fuelType;
    _selectedDriveType = car.driveType;
  }

  // Update methods for UI
  void updateTransmission(String value) {
    _selectedTransmission = value;
  }

  void updateFuelType(String value) {
    _selectedFuelType = value;
  }

  void updateDriveType(String value) {
    _selectedDriveType = value;
  }

  void updateBrand(String value) {
    _selectedBrand = value;
  }

  void updateStatus(int value) {
    _status = value;
    // Clear auction dates if status is not Auction
    if (value != 3) {
      _auctionStartAt = null;
      _auctionEndAt = null;
    }
  }

  void updateShowAt(DateTime? value) {
    _showAt = value;
  }

  void updateUnShowAt(DateTime? value) {
    _unShowAt = value;
  }

  void updateAuctionStartAt(DateTime? value) {
    _auctionStartAt = value;
  }

  void updateAuctionEndAt(DateTime? value) {
    _auctionEndAt = value;
  }

  void updateDeleteAt(DateTime? value) {
    _deleteAt = value;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  // Image handling
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      _selectedImage = File(image.path);
    }
  }

  Future<void> pickOtherImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      _otherImages.add(File(image.path));
    }
  }

  void removeOtherImage(int index) {
    _otherImages.removeAt(index);
  }

  // Date handling
  Future<void> selectDate(BuildContext context, String fieldName) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      switch (fieldName) {
        case 'showAt':
          _showAt = picked;
          break;
        case 'unShowAt':
          _unShowAt = picked;
          break;
        case 'auctionStartAt':
          _auctionStartAt = picked;
          break;
        case 'auctionEndAt':
          _auctionEndAt = picked;
          break;
        case 'deleteAt':
          _deleteAt = picked;
          break;
      }
    }
  }

  void clearDate(String fieldName) {
    switch (fieldName) {
      case 'showAt':
        _showAt = null;
        break;
      case 'unShowAt':
        _unShowAt = null;
        break;
      case 'auctionStartAt':
        _auctionStartAt = null;
        break;
      case 'auctionEndAt':
        _auctionEndAt = null;
        break;
      case 'deleteAt':
        _deleteAt = null;
        break;
    }
  }

  // Save car (create or update)
  Future<bool> saveCar({Car? existingCar}) async {
    _isLoading = true;

    try {
      final repository = DataSourceFactory.getRepository();

      String? imageUrl;
      List<String> otherImageUrls = [];

      // Upload main image if selected
      if (_selectedImage != null) {
        final imageBytes = await _selectedImage!.readAsBytes();
        final fileName = '${_uuid.v4()}.jpg';
        imageUrl = await repository.uploadImage(imageBytes, fileName);
      }

      // Upload other images if selected
      for (final imageFile in _otherImages) {
        final imageBytes = await imageFile.readAsBytes();
        final fileName = '${_uuid.v4()}.jpg';
        final otherImageUrl = await repository.uploadImage(imageBytes, fileName);
        if (otherImageUrl != null) {
          otherImageUrls.add(otherImageUrl);
        }
      }

      final car = Car(
        id: existingCar?.id,
        carId: existingCar?.carId ?? _uuid.v4(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        brand: _selectedBrand,
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        mileage: int.parse(_mileageController.text.trim()),
        transmission: _selectedTransmission,
        fuelType: _selectedFuelType,
        engineSize: _engineController.text.trim(),
        horsepower: int.parse(_horsepowerController.text.trim()),
        driveType: _selectedDriveType,
        exteriorColor: _exteriorColorController.text.trim(),
        interiorColor: _interiorColorController.text.trim(),
        doors: int.parse(_doorsController.text.trim()),
        seats: int.parse(_seatsController.text.trim()),
        mainImage: imageUrl ?? existingCar?.mainImage,
        otherImages: otherImageUrls.isNotEmpty ? otherImageUrls : existingCar?.otherImages,
        contact: _contactController.text.trim(),
        vin: _vinController.text.trim().isNotEmpty ? _vinController.text.trim() : null,
        status: _status,
        showAt: _showAt,
        unShowAt: _unShowAt,
        auctionStartAt: _auctionStartAt,
        auctionEndAt: _auctionEndAt,
        deleteAt: _deleteAt,
        createdAt: existingCar?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (existingCar != null) {
        success = await repository.updateCar(car);
      } else {
        success = await repository.addCar(car);
      }

      return success;
    } catch (e) {
      print('Error saving car: $e');
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Validation
  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter price';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid price';
    }
    return null;
  }

  String? validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter contact information';
    }
    return null;
  }

  String? validateBrand(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a brand';
    }
    return null;
  }

  String? validateModel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter model';
    }
    return null;
  }

  String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter year';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Please enter a valid year';
    }
    return null;
  }

  String? validateMileage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mileage';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Please enter a valid mileage';
    }
    return null;
  }

  String? validateEngine(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter engine size';
    }
    return null;
  }

  String? validateHorsepower(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter horsepower';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Please enter a valid horsepower';
    }
    return null;
  }

  String? validateExteriorColor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter exterior color';
    }
    return null;
  }

  String? validateInteriorColor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter interior color';
    }
    return null;
  }

  String? validateDoors(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter number of doors';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? validateSeats(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter number of seats';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? validateVin(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length < 17) {
        return 'VIN must be at least 17 characters';
      }
    }
    return null;
  }

  // Dispose resources
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _contactController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _engineController.dispose();
    _horsepowerController.dispose();
    _exteriorColorController.dispose();
    _interiorColorController.dispose();
    _doorsController.dispose();
    _seatsController.dispose();
    _vinController.dispose();
  }
}
