// add_car_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/car.dart';
import '../../supabase/supabase_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({Key? key}) : super(key: key);

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();

  // New controllers for detailed car specs
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

  // New boolean fields
  bool _status = true; // Default to available
  bool _condition = false; // Default to used

  // Brands list
  List<String> _brands = [];

  File? _selectedImage;
  List<File> _otherImages = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _setupMileageListener();
  }

  void _setupMileageListener() {
    _mileageController.addListener(() {
      final mileageText = _mileageController.text.trim();
      if (mileageText.isNotEmpty) {
        final mileage = int.tryParse(mileageText);
        if (mileage != null) {
          setState(() {
            if (mileage == 0) {
              _condition = true; // New
            } else {
              _condition = false; // Used
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _contactController.dispose();

    // Dispose new controllers
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _engineController.dispose();
    _horsepowerController.dispose();
    _exteriorColorController.dispose();
    _interiorColorController.dispose();
    _doorsController.dispose();
    _seatsController.dispose();

    super.dispose();
  }

  Future<void> _loadBrands() async {
    try {
      // Use predefined brand list since we're not using a brands table
      final predefinedBrands = [
        'Toyota',
        'Honda',
        'Nissan',
        'Mazda',
        'Subaru',
        'Mitsubishi',
        'Lexus',
        'Infiniti',
        'Acura',
        'BMW',
        'Mercedes-Benz',
        'Audi',
        'Volkswagen',
        'Porsche',
        'Volvo',
        'Ford',
        'Chevrolet',
        'Dodge',
        'Jeep',
        'Hyundai',
        'Kia',
        'Genesis',
        'Land Rover',
        'Jaguar',
        'Mini',
        'Fiat',
        'Alfa Romeo',
        'Maserati',
        'Ferrari',
        'Lamborghini'
      ];
      setState(() {
        _brands = predefinedBrands;
        if (_brands.isNotEmpty && _selectedBrand.isEmpty) {
          _selectedBrand = _brands.first;
        }
      });
    } catch (e) {
      print('Error loading brands: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickOtherImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _otherImages.add(File(image.path));
      });
    }
  }

  void _removeOtherImage(int index) {
    setState(() {
      _otherImages.removeAt(index);
    });
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = SupabaseService();

      String? imageUrl;
      List<String> otherImageUrls = [];

      // Upload main image if selected
      if (_selectedImage != null) {
        final imageBytes = await _selectedImage!.readAsBytes();
        final fileName = '${_uuid.v4()}.jpg';
        imageUrl = await supabaseService.uploadImage(imageBytes, fileName);
      }

      // Upload other images if selected
      for (final imageFile in _otherImages) {
        final imageBytes = await imageFile.readAsBytes();
        final fileName = '${_uuid.v4()}.jpg';
        final otherImageUrl =
            await supabaseService.uploadImage(imageBytes, fileName);
        if (otherImageUrl != null) {
          otherImageUrls.add(otherImageUrl);
        }
      }

      final car = Car(
        carId: _uuid.v4(),
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
        mainImage: imageUrl,
        otherImages: otherImageUrls.isNotEmpty ? otherImageUrls : null,
        contact: _contactController.text.trim(),
        vin: _vinController.text.trim().isNotEmpty
            ? _vinController.text.trim()
            : null,
        status: _status,
        condition: _condition,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await supabaseService.addCar(car);

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Car added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save car. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1565C0),
                    Color(0xFF1976D2),
                    Color(0xFF1E88E5),
                  ],
                ),
              ),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Add New Car',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Image Section
                      const Text(
                        'Main Image',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey.withOpacity(0.1),
                                Colors.grey.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 60,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to add main image',
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.7),
                                        fontSize: 16,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Other Images Section
                      const Text(
                        'Additional Images',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF4CAF50).withOpacity(0.8),
                                  const Color(0xFF2E7D32).withOpacity(0.9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF4CAF50).withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _pickOtherImage,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text('Add Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (_otherImages.isNotEmpty)
                            Text(
                              '${_otherImages.length} image(s) selected',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontFamily: 'Tajawal',
                              ),
                            ),
                        ],
                      ),
                      if (_otherImages.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _otherImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _otherImages[index],
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeOtherImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Basic Information Section
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          hintText: 'Describe the car...',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Price
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                          hintText: 'e.g., 50000',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter price';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Contact
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Info *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.contact_phone),
                          hintText: 'Phone, WhatsApp, or Email',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter contact information';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Car Specifications Section
                      const Text(
                        'Car Specifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Brand and Model Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedBrand.isEmpty
                                  ? null
                                  : _selectedBrand,
                              decoration: const InputDecoration(
                                labelText: 'Brand *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.directions_car),
                              ),
                              items: _brands.map((String brand) {
                                return DropdownMenuItem<String>(
                                  value: brand,
                                  child: Text(brand),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedBrand = newValue ?? '';
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a brand';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              decoration: const InputDecoration(
                                labelText: 'Model *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.directions_car),
                                hintText: 'e.g., Corolla',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter model';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Year and Mileage Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _yearController,
                              decoration: const InputDecoration(
                                labelText: 'Year *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                                hintText: 'e.g., 2018',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter year';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return 'Please enter a valid year';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _mileageController,
                              decoration: const InputDecoration(
                                labelText: 'Mileage (km) *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.speed),
                                hintText: 'e.g., 50000',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter mileage';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return 'Please enter a valid mileage';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Transmission and Fuel Type Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedTransmission,
                              decoration: const InputDecoration(
                                labelText: 'Transmission *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.settings),
                              ),
                              items:
                                  ['Automatic', 'Manual'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedTransmission = newValue!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedFuelType,
                              decoration: const InputDecoration(
                                labelText: 'Fuel Type *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.local_gas_station),
                              ),
                              items: ['Petrol', 'Diesel', 'Electric', 'Hybrid']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedFuelType = newValue!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Engine Size and Horsepower Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _engineController,
                              decoration: const InputDecoration(
                                labelText: 'Engine *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.engineering),
                                hintText: 'e.g., 2.0L',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter engine size';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _horsepowerController,
                              decoration: const InputDecoration(
                                labelText: 'Horsepower *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.flash_on),
                                hintText: 'e.g., 150',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter horsepower';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return 'Please enter a valid horsepower';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Drive Type Row
                      DropdownButtonFormField<String>(
                        value: _selectedDriveType,
                        decoration: const InputDecoration(
                          labelText: 'Drive Type *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.all_inclusive),
                        ),
                        items: ['FWD', 'RWD', 'AWD'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDriveType = newValue!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Colors Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _exteriorColorController,
                              decoration: const InputDecoration(
                                labelText: 'Exterior Color *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.palette),
                                hintText: 'e.g., White',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter exterior color';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _interiorColorController,
                              decoration: const InputDecoration(
                                labelText: 'Interior Color *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.chair),
                                hintText: 'e.g., Black',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter interior color';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Doors and Seats Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _doorsController,
                              decoration: const InputDecoration(
                                labelText: 'Number of Doors *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.door_front_door),
                                hintText: 'e.g., 4',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter number of doors';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _seatsController,
                              decoration: const InputDecoration(
                                labelText: 'Number of Seats *',
                                border: OutlineInputBorder(),
                                prefixIcon:
                                    Icon(Icons.airline_seat_recline_normal),
                                hintText: 'e.g., 5',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter number of seats';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // VIN Field
                      TextFormField(
                        controller: _vinController,
                        decoration: const InputDecoration(
                          labelText: 'VIN (Vehicle Identification Number)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.confirmation_number),
                          hintText: 'e.g., 1HGBH41JXMN109186',
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (value.trim().length < 17) {
                              return 'VIN must be at least 17 characters';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Status and Condition Row
                      Row(
                        children: [
                          // Status Switch
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Availability Status',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Switch(
                                          value: _status,
                                          onChanged: (value) {
                                            setState(() {
                                              _status = value;
                                            });
                                          },
                                          activeColor: Colors.green,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _status
                                              ? 'Available'
                                              : 'Not Available',
                                          style: TextStyle(
                                            color: _status
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Condition Switch
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Car Condition',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Switch(
                                          value: _condition,
                                          onChanged: (value) {
                                            setState(() {
                                              _condition = value;
                                              if (value) {
                                                // If new, set mileage to 0
                                                _mileageController.text = '0';
                                              }
                                            });
                                          },
                                          activeColor: Colors.blue,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _condition ? 'New' : 'Used',
                                          style: TextStyle(
                                            color: _condition
                                                ? Colors.blue
                                                : Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF2196F3).withOpacity(0.8),
                              const Color(0xFF1976D2).withOpacity(0.9),
                              const Color(0xFF1565C0).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2196F3).withOpacity(0.4),
                              spreadRadius: 0,
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveCar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Add Car',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
