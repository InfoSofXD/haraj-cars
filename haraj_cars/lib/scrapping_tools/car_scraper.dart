import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'car_scraper_service.dart';
import '../../supabase/supabase_service.dart';
import '../models/car.dart';
import 'dart:convert';

class CarScraper extends StatefulWidget {
  const CarScraper({Key? key}) : super(key: key);

  @override
  State<CarScraper> createState() => _CarScraperState();
}

class _CarScraperState extends State<CarScraper> {
  final TextEditingController _urlController = TextEditingController();
  Map<String, dynamic>? _scrapedData;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, String> _supportedSites = {};
  String? _selectedSite;

  // Image selection state
  List<String> _availableImageUrls = [];
  List<String> _selectedImageUrls = [];
  bool _isAddingCar = false;

  // Editable form fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _transmissionController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _engineController = TextEditingController();
  final TextEditingController _exteriorColorController =
      TextEditingController();
  final TextEditingController _interiorColorController =
      TextEditingController();
  final TextEditingController _driveTypeController = TextEditingController();
  final TextEditingController _dealerController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Dropdown values
  String _selectedTransmission = 'Automatic';
  String _selectedFuelType = 'Petrol';
  String _selectedDriveType = 'FWD';
  int _selectedStatus = 1;
  int _selectedDoors = 4;
  int _selectedSeats = 5;

  @override
  void initState() {
    super.initState();
    // Set a default URL for testing
    _urlController.text = 'https://www.cars.com/vehicledetail/test/';
    _loadSupportedSites();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _transmissionController.dispose();
    _fuelTypeController.dispose();
    _engineController.dispose();
    _exteriorColorController.dispose();
    _interiorColorController.dispose();
    _driveTypeController.dispose();
    _dealerController.dispose();
    _vinController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Load supported car websites
  Future<void> _loadSupportedSites() async {
    try {
      final sites = await CarScraperService.getSupportedSites();
      setState(() {
        _supportedSites = sites;
        if (sites.isNotEmpty) {
          _selectedSite = sites.keys.first;
        }
      });
    } catch (e) {
      print('Error loading supported sites: $e');
    }
  }

  /// Scrapes car data from the entered URL
  Future<void> _scrapeCar() async {
    if (_urlController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a URL';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _scrapedData = null;
    });

    try {
      final data =
          await CarScraperService.scrapeCar(_urlController.text.trim());

      // Debug: Print all fields to see what we're getting
      print('🔍 Scraped data fields:');
      data.forEach((key, value) {
        print('  $key: $value');
      });

      // Extract available image URLs
      _extractImageUrls(data);

      setState(() {
        _scrapedData = data;
        _isLoading = false;
      });

      // Populate form fields with scraped data
      _populateFormFields(data);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Tests the API connection
  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isConnected = await CarScraperService.testConnection();
      setState(() {
        _isLoading = false;
        _errorMessage = isConnected
            ? 'API connection successful!'
            : 'API connection failed';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection test failed: $e';
      });
    }
  }

  /// Populates form fields with scraped data
  void _populateFormFields(Map<String, dynamic> scrapedData) {
    // Basic information
    _titleController.text = scrapedData['Title']?.toString() ?? '';
    _descriptionController.text = scrapedData['Description']?.toString() ?? '';

    // Price (remove currency symbols and commas)
    final priceStr = scrapedData['Price']?.toString() ?? '';
    final cleanPrice = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
    _priceController.text = cleanPrice;

    // Car details
    _brandController.text = scrapedData['Brand']?.toString() ?? '';
    _modelController.text = scrapedData['Model']?.toString() ?? '';
    _yearController.text = scrapedData['Year']?.toString() ?? '';

    // Mileage (remove "miles" text and commas)
    final mileageStr = scrapedData['Mileage']?.toString() ?? '';
    final cleanMileage = mileageStr.replaceAll(RegExp(r'[^\d]'), '');
    _mileageController.text = cleanMileage;

    // Transmission
    final transmission = scrapedData['Transmission']?.toString() ?? 'Automatic';
    if (transmission.toLowerCase().contains('manual')) {
      _selectedTransmission = 'Manual';
    } else {
      _selectedTransmission = 'Automatic';
    }

    // Fuel type
    final fuelType = scrapedData['Fuel Type']?.toString() ?? 'Petrol';
    if (fuelType.toLowerCase().contains('diesel')) {
      _selectedFuelType = 'Diesel';
    } else if (fuelType.toLowerCase().contains('electric')) {
      _selectedFuelType = 'Electric';
    } else if (fuelType.toLowerCase().contains('hybrid')) {
      _selectedFuelType = 'Hybrid';
    } else {
      _selectedFuelType = 'Petrol';
    }

    // Engine
    _engineController.text = scrapedData['Engine']?.toString() ?? '';

    // Colors
    _exteriorColorController.text =
        scrapedData['Exterior Color']?.toString() ?? '';
    _interiorColorController.text =
        scrapedData['Interior Color']?.toString() ?? '';

    // Drive type
    final drivetrain = scrapedData['Drivetrain']?.toString() ?? 'FWD';
    if (drivetrain.toLowerCase().contains('all-wheel') ||
        drivetrain.toLowerCase().contains('awd')) {
      _selectedDriveType = 'AWD';
    } else if (drivetrain.toLowerCase().contains('rear-wheel') ||
        drivetrain.toLowerCase().contains('rwd')) {
      _selectedDriveType = 'RWD';
    } else {
      _selectedDriveType = 'FWD';
    }

    // Contact and VIN
    _dealerController.text = scrapedData['Dealer']?.toString() ?? '';
    _vinController.text = scrapedData['VIN']?.toString() ?? '';

    setState(() {});
  }

  /// Extracts image URLs from scraped data using the same logic as display
  void _extractImageUrls(Map<String, dynamic> scrapedData) {
    List<String> imageUrls = [];

    for (var entry in scrapedData.entries) {
      String value = entry.value?.toString() ?? '';
      bool isImageField = entry.key.toLowerCase().contains('image') ||
          entry.key.toLowerCase().contains('photo') ||
          entry.key.toLowerCase().contains('picture') ||
          entry.key.toLowerCase().contains('img');

      // Also check if the value looks like an image URL
      bool looksLikeImageUrl = value.startsWith('http') &&
          (value.contains('.jpg') ||
              value.contains('.jpeg') ||
              value.contains('.png') ||
              value.contains('.gif') ||
              value.contains('.webp') ||
              value.contains('image') ||
              value.contains('photo') ||
              value.contains('img'));

      // Check if this is a list of image URLs
      bool isImageList =
          isImageField && value.startsWith('[') && value.contains('http');

      if (isImageList) {
        // Try to parse as JSON array first
        try {
          List<dynamic> urlList = json.decode(value);
          imageUrls.addAll(urlList.map((url) => url.toString()));
        } catch (e) {
          // Handle Python list format: ['url1', 'url2', 'url3']
          // Remove brackets and split by ', ' then clean quotes
          String cleaned = value.replaceFirst('[', '').replaceFirst(']', '');

          // Split by ', ' and clean each URL
          List<String> allUrls = cleaned
              .split(', ')
              .map((url) => url.trim().replaceAll("'", '').replaceAll('"', ''))
              .where((url) => url.startsWith('http'))
              .toList();

          // Filter to prioritize actual car images
          List<String> carImages = allUrls
              .where((url) =>
                  // Prioritize platform.cstatic-images.com (actual car photos)
                  url.contains('platform.cstatic-images.com') &&
                  (url.contains('/xlarge/') || url.contains('/small/')))
              .toList();

          // If we have car images, use them. Otherwise fall back to other images
          if (carImages.isNotEmpty) {
            imageUrls.addAll(carImages);
          } else {
            // Fallback to any image that's not obviously wrong
            imageUrls.addAll(allUrls
                .where((url) =>
                    (url.contains('.jpg') ||
                        url.contains('.jpeg') ||
                        url.contains('.png') ||
                        url.contains('.webp')) &&
                    !url.contains('cars_logo') &&
                    !url.contains('dealerrater.com/employees') &&
                    !url.contains('awards/') &&
                    !url.contains('mobile-apps/') &&
                    !url.contains('akam/') &&
                    !url.contains('pixel_'))
                .toList());
          }
        }
      } else if (looksLikeImageUrl) {
        imageUrls.add(value);
      }
    }

    setState(() {
      _availableImageUrls = imageUrls;
      _selectedImageUrls =
          imageUrls.take(5).toList(); // Select first 5 by default
    });
  }

  /// Adds scraped car to Supabase
  Future<void> _addScrapedCarToSupabase() async {
    setState(() {
      _isAddingCar = true;
    });

    try {
      // Extract data from form fields
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final brand = _brandController.text.trim();
      final model = _modelController.text.trim();
      final year = int.tryParse(_yearController.text) ?? DateTime.now().year;
      final mileage = int.tryParse(_mileageController.text) ?? 0;
      final engine = _engineController.text.trim();
      final exteriorColor = _exteriorColorController.text.trim();
      final interiorColor = _interiorColorController.text.trim();
      final dealer = _dealerController.text.trim();
      final vin = _vinController.text.trim();

      // Upload selected images
      final supabaseService = SupabaseService();
      String? mainImageUrl;
      List<String> otherImageUrls = [];

      if (_selectedImageUrls.isNotEmpty) {
        // Upload main image
        try {
          final response = await supabaseService
              .uploadImageFromUrl(_selectedImageUrls.first);
          if (response != null) {
            mainImageUrl = response;
          }
        } catch (e) {
          print('Error uploading main image: $e');
        }

        // Upload other images
        for (int i = 1; i < _selectedImageUrls.length; i++) {
          try {
            final response =
                await supabaseService.uploadImageFromUrl(_selectedImageUrls[i]);
            if (response != null) {
              otherImageUrls.add(response);
            }
          } catch (e) {
            print('Error uploading image $i: $e');
          }
        }
      }

      // Create car object
      final car = Car(
        carId: const Uuid().v4(),
        description: description.isNotEmpty
            ? description
            : (title.isNotEmpty ? title : 'Scraped car data'),
        price: price,
        brand: brand.isNotEmpty ? brand : 'Unknown',
        model: model.isNotEmpty ? model : 'Unknown',
        year: year,
        mileage: mileage,
        transmission: _selectedTransmission,
        fuelType: _selectedFuelType,
        engineSize: engine.isNotEmpty ? engine : 'Unknown',
        horsepower: 0, // Not available from scraping
        driveType: _selectedDriveType,
        exteriorColor: exteriorColor.isNotEmpty ? exteriorColor : 'Unknown',
        interiorColor: interiorColor.isNotEmpty ? interiorColor : 'Unknown',
        doors: _selectedDoors,
        seats: _selectedSeats,
        mainImage: mainImageUrl,
        otherImages: otherImageUrls.isNotEmpty ? otherImageUrls : null,
        contact: dealer.isNotEmpty ? dealer : 'Contact seller',
        vin: vin.isNotEmpty ? vin : null,
        status: _selectedStatus,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add car to database
      final success = await supabaseService.addCar(car);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Car added successfully to inventory!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add car. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding car: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingCar = false;
        });
      }
    }
  }

  /// Builds a form section with title
  Widget _buildFormSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.blue[300] : Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  /// Builds a text field with icon
  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      [TextInputType? keyboardType]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600]),
        prefixIcon: Icon(icon, color: isDark ? Colors.blue[300] : Colors.blue),
        border: OutlineInputBorder(
          borderSide:
              BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: isDark ? Colors.blue[300]! : Colors.blue),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.white,
      ),
    );
  }

  /// Builds a dropdown field
  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Ensure the value exists in items, otherwise use the first item
    String safeValue =
        items.contains(value) ? value : (items.isNotEmpty ? items.first : '');

    return DropdownButtonFormField<String>(
      value: safeValue,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600]),
        border: OutlineInputBorder(
          borderSide:
              BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: isDark ? Colors.blue[300]! : Colors.blue),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.white,
      ),
      dropdownColor: isDark ? Colors.grey[800] : Colors.white,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  /// Gets status text for display
  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Available';
      case 2:
        return 'Sold';
      case 3:
        return 'Auction';
      case 4:
        return 'Cancelled';
      default:
        return 'Available';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
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
                              color: Colors.white.withOpacity(0.1),
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
                          'Car Scraper',
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
              Container(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // URL Input Section
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    Colors.grey[800]!.withOpacity(0.8),
                                    Colors.grey[700]!.withOpacity(0.6),
                                  ]
                                : [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[600]!.withOpacity(0.3)
                                : Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Site Selection
                              Text(
                                'Select Website:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Tajawal',
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedSite,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.web),
                                ),
                                items: _supportedSites.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSite = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // URL Input
                              Text(
                                'Enter Car Listing URL:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Tajawal',
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _urlController,
                                decoration: InputDecoration(
                                  hintText: _selectedSite != null
                                      ? 'https://www.$_selectedSite/vehicledetail/...'
                                      : 'Enter car listing URL...',
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.url,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFF2196F3)
                                                .withOpacity(0.8),
                                            const Color(0xFF1976D2)
                                                .withOpacity(0.9),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF2196F3)
                                                .withOpacity(0.3),
                                            spreadRadius: 0,
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : _scrapeCar,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              )
                                            : const Text('Scrape Car Data'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFF4CAF50)
                                              .withOpacity(0.8),
                                          const Color(0xFF2E7D32)
                                              .withOpacity(0.9),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4CAF50)
                                              .withOpacity(0.3),
                                          spreadRadius: 0,
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _testConnection,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Test API'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _errorMessage!.contains('successful')
                                  ? [
                                      Colors.green
                                          .withOpacity(isDark ? 0.3 : 0.2),
                                      Colors.green
                                          .withOpacity(isDark ? 0.2 : 0.1),
                                    ]
                                  : [
                                      Colors.red
                                          .withOpacity(isDark ? 0.3 : 0.2),
                                      Colors.red
                                          .withOpacity(isDark ? 0.2 : 0.1),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _errorMessage!.contains('successful')
                                  ? Colors.green.withOpacity(isDark ? 0.4 : 0.3)
                                  : Colors.red.withOpacity(isDark ? 0.4 : 0.3),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: _errorMessage!.contains('successful')
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ),

                      // Image Selection Section
                      if (_scrapedData != null &&
                          _availableImageUrls.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      Colors.grey[800]!.withOpacity(0.8),
                                      Colors.grey[700]!.withOpacity(0.6),
                                    ]
                                  : [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[600]!.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Images:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_selectedImageUrls.length} of ${_availableImageUrls.length} images selected',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.black87.withOpacity(0.7),
                                    fontSize: 14,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _availableImageUrls.length,
                                    itemBuilder: (context, index) {
                                      final imageUrl =
                                          _availableImageUrls[index];
                                      final isSelected =
                                          _selectedImageUrls.contains(imageUrl);

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedImageUrls
                                                  .remove(imageUrl);
                                            } else {
                                              _selectedImageUrls.add(imageUrl);
                                            }
                                          });
                                        },
                                        child: Container(
                                          width: 120,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 120,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      width: 120,
                                                      height: 120,
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey,
                                                        size: 40,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              if (isSelected)
                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.blue,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Editable Car Data Form
                      if (_scrapedData != null)
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[600]!.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Car Data:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Column(
                                  children: [
                                    // Basic Information
                                    _buildFormSection('Basic Information', [
                                      _buildTextField('Title', _titleController,
                                          Icons.title),
                                      _buildTextField(
                                          'Description',
                                          _descriptionController,
                                          Icons.description),
                                      _buildTextField(
                                          'Price (SAR)',
                                          _priceController,
                                          Icons.attach_money,
                                          TextInputType.number),
                                    ]),

                                    const SizedBox(height: 20),

                                    // Car Details
                                    _buildFormSection('Car Details', [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _buildTextField(
                                                  'Brand',
                                                  _brandController,
                                                  Icons.directions_car)),
                                          const SizedBox(width: 16),
                                          Expanded(
                                              child: _buildTextField(
                                                  'Model',
                                                  _modelController,
                                                  Icons.directions_car)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _buildTextField(
                                                  'Year',
                                                  _yearController,
                                                  Icons.calendar_today,
                                                  TextInputType.number)),
                                          const SizedBox(width: 16),
                                          Expanded(
                                              child: _buildTextField(
                                                  'Mileage (km)',
                                                  _mileageController,
                                                  Icons.speed,
                                                  TextInputType.number)),
                                        ],
                                      ),
                                    ]),

                                    const SizedBox(height: 20),

                                    // Technical Specifications
                                    _buildFormSection(
                                        'Technical Specifications', [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _buildDropdown(
                                                  'Transmission',
                                                  _selectedTransmission,
                                                  ['Automatic', 'Manual'],
                                                  (value) => setState(() =>
                                                      _selectedTransmission =
                                                          value!))),
                                          const SizedBox(width: 16),
                                          Expanded(
                                              child: _buildDropdown(
                                                  'Fuel Type',
                                                  _selectedFuelType,
                                                  [
                                                    'Petrol',
                                                    'Diesel',
                                                    'Electric',
                                                    'Hybrid'
                                                  ],
                                                  (value) => setState(() =>
                                                      _selectedFuelType =
                                                          value!))),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _buildTextField(
                                                  'Engine',
                                                  _engineController,
                                                  Icons.engineering)),
                                          const SizedBox(width: 16),
                                          Expanded(
                                              child: _buildDropdown(
                                                  'Drive Type',
                                                  _selectedDriveType,
                                                  ['FWD', 'RWD', 'AWD'],
                                                  (value) => setState(() =>
                                                      _selectedDriveType =
                                                          value!))),
                                        ],
                                      ),
                                    ]),

                                    const SizedBox(height: 20),

                                    // Colors and Details
                                    _buildFormSection('Colors and Details', [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _buildTextField(
                                                  'Exterior Color',
                                                  _exteriorColorController,
                                                  Icons.palette)),
                                          const SizedBox(width: 16),
                                          Expanded(
                                              child: _buildTextField(
                                                  'Interior Color',
                                                  _interiorColorController,
                                                  Icons.chair)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _buildDropdown(
                                                  'Doors',
                                                  _selectedDoors.toString(),
                                                  ['2', '3', '4', '5'],
                                                  (value) => setState(() =>
                                                      _selectedDoors =
                                                          int.parse(value!)))),
                                          const SizedBox(width: 16),
                                          Expanded(
                                              child: _buildDropdown(
                                                  'Seats',
                                                  _selectedSeats.toString(),
                                                  [
                                                    '2',
                                                    '4',
                                                    '5',
                                                    '6',
                                                    '7',
                                                    '8'
                                                  ],
                                                  (value) => setState(() =>
                                                      _selectedSeats =
                                                          int.parse(value!)))),
                                        ],
                                      ),
                                    ]),

                                    const SizedBox(height: 20),

                                    // Contact and Status
                                    _buildFormSection('Contact and Status', [
                                      _buildTextField(
                                          'Dealer/Contact',
                                          _dealerController,
                                          Icons.contact_phone),
                                      _buildTextField('VIN', _vinController,
                                          Icons.confirmation_number),
                                      _buildDropdown(
                                          'Status',
                                          '$_selectedStatus - ${_getStatusText(_selectedStatus)}',
                                          [
                                            '0 - Pending',
                                            '1 - Available',
                                            '2 - Sold',
                                            '3 - Auction',
                                            '4 - Cancelled'
                                          ],
                                          (value) => setState(() =>
                                              _selectedStatus = int.parse(
                                                  value!.split(' - ')[0]))),
                                    ]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _scrapedData != null
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4CAF50).withOpacity(0.9),
                    const Color(0xFF2E7D32).withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _isAddingCar ? null : _addScrapedCarToSupabase,
                icon: _isAddingCar
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  _isAddingCar ? 'Adding...' : 'Add to Inventory',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            )
          : null,
    );
  }
}
