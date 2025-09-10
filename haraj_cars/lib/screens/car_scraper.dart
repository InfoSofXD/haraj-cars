import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/car_scraper_service.dart';
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

      // Show dialog to add scraped car
      _showAddScrapedCarDialog(data);
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

  /// Shows dialog to add scraped car data
  void _showAddScrapedCarDialog(Map<String, dynamic> scrapedData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Scraped Car'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Do you want to add this scraped car to your inventory?'),
            const SizedBox(height: 16),
            Text(
              'Title: ${scrapedData['Title'] ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Brand: ${scrapedData['Brand'] ?? 'N/A'}'),
            Text('Model: ${scrapedData['Model'] ?? 'N/A'}'),
            Text('Year: ${scrapedData['Year'] ?? 'N/A'}'),
            Text('Price: ${scrapedData['Price'] ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(scrapedData);
            },
            child: const Text('Add Car'),
          ),
        ],
      ),
    );
  }

  /// Adds scraped car to Supabase
  Future<void> _addScrapedCarToSupabase() async {
    if (_scrapedData == null) return;

    setState(() {
      _isAddingCar = true;
    });

    try {
      // Extract data from scraped result
      final title = _scrapedData!['Title']?.toString() ?? '';
      final priceStr = _scrapedData!['Price']?.toString() ?? '';
      final brand = _scrapedData!['Brand']?.toString() ?? '';
      final model = _scrapedData!['Model']?.toString() ?? '';
      final yearStr = _scrapedData!['Year']?.toString() ?? '';
      final mileageStr = _scrapedData!['Mileage']?.toString() ?? '';
      final transmission =
          _scrapedData!['Transmission']?.toString() ?? 'Automatic';
      final fuelType = _scrapedData!['Fuel Type']?.toString() ?? 'Petrol';
      final engine = _scrapedData!['Engine']?.toString() ?? '';
      final exteriorColor = _scrapedData!['Exterior Color']?.toString() ?? '';
      final interiorColor = _scrapedData!['Interior Color']?.toString() ?? '';
      final drivetrain = _scrapedData!['Drivetrain']?.toString() ?? 'FWD';
      final dealer = _scrapedData!['Dealer']?.toString() ?? '';
      final vin = _scrapedData!['VIN']?.toString() ?? '';

      // Parse price (remove currency symbols and commas)
      final cleanPrice = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
      final price = double.tryParse(cleanPrice) ?? 0.0;

      // Parse year
      final year = int.tryParse(yearStr) ?? DateTime.now().year;

      // Parse mileage (remove "miles" text and commas)
      final cleanMileage = mileageStr.replaceAll(RegExp(r'[^\d]'), '');
      final mileage = int.tryParse(cleanMileage) ?? 0;

      // Convert drivetrain to our format
      String driveType = 'FWD';
      if (drivetrain.toLowerCase().contains('all-wheel') ||
          drivetrain.toLowerCase().contains('awd')) {
        driveType = 'AWD';
      } else if (drivetrain.toLowerCase().contains('rear-wheel') ||
          drivetrain.toLowerCase().contains('rwd')) {
        driveType = 'RWD';
      }

      // Convert transmission to our format
      String transmissionType = 'Automatic';
      if (transmission.toLowerCase().contains('manual')) {
        transmissionType = 'Manual';
      }

      // Convert fuel type to our format
      String fuelTypeConverted = 'Petrol';
      if (fuelType.toLowerCase().contains('diesel')) {
        fuelTypeConverted = 'Diesel';
      } else if (fuelType.toLowerCase().contains('electric')) {
        fuelTypeConverted = 'Electric';
      } else if (fuelType.toLowerCase().contains('hybrid')) {
        fuelTypeConverted = 'Hybrid';
      }

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
        description: title.isNotEmpty ? title : 'Scraped car data',
        price: price,
        brand: brand.isNotEmpty ? brand : 'Unknown',
        model: model.isNotEmpty ? model : 'Unknown',
        year: year,
        mileage: mileage,
        transmission: transmissionType,
        fuelType: fuelTypeConverted,
        engineSize: engine.isNotEmpty ? engine : 'Unknown',
        horsepower: 0, // Not available from scraping
        driveType: driveType,
        exteriorColor: exteriorColor.isNotEmpty ? exteriorColor : 'Unknown',
        interiorColor: interiorColor.isNotEmpty ? interiorColor : 'Unknown',
        doors: 4, // Default value
        seats: 5, // Default value
        mainImage: mainImageUrl,
        otherImages: otherImageUrls.isNotEmpty ? otherImageUrls : null,
        contact: dealer.isNotEmpty ? dealer : 'Contact seller',
        vin: vin.isNotEmpty ? vin : null,
        status: true, // Default to available
        condition: false, // Default to used
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
            Expanded(
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
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
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
                                      onPressed: _isLoading ? null : _scrapeCar,
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
                                              child: CircularProgressIndicator(
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
                                        borderRadius: BorderRadius.circular(12),
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
                                    Colors.green.withOpacity(0.2),
                                    Colors.green.withOpacity(0.1),
                                  ]
                                : [
                                    Colors.red.withOpacity(0.2),
                                    Colors.red.withOpacity(0.1),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _errorMessage!.contains('successful')
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
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
                    if (_scrapedData != null && _availableImageUrls.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
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
                                  color: Colors.white,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_selectedImageUrls.length} of ${_availableImageUrls.length} images selected',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
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
                                    final imageUrl = _availableImageUrls[index];
                                    final isSelected =
                                        _selectedImageUrls.contains(imageUrl);

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedImageUrls.remove(imageUrl);
                                          } else {
                                            _selectedImageUrls.add(imageUrl);
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 120,
                                        margin: const EdgeInsets.only(right: 8),
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

                    // Scraped Data Display
                    if (_scrapedData != null)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scraped Car Data:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          _scrapedData!.entries.map((entry) {
                                        // Check if this is an image field or URL
                                        String value =
                                            entry.value?.toString() ?? '';
                                        bool isImageField = entry.key
                                                .toLowerCase()
                                                .contains('image') ||
                                            entry.key
                                                .toLowerCase()
                                                .contains('photo') ||
                                            entry.key
                                                .toLowerCase()
                                                .contains('picture') ||
                                            entry.key
                                                .toLowerCase()
                                                .contains('img');

                                        // Also check if the value looks like an image URL
                                        bool looksLikeImageUrl =
                                            value.startsWith('http') &&
                                                (value.contains('.jpg') ||
                                                    value.contains('.jpeg') ||
                                                    value.contains('.png') ||
                                                    value.contains('.gif') ||
                                                    value.contains('.webp') ||
                                                    value.contains('image') ||
                                                    value.contains('photo') ||
                                                    value.contains('img'));

                                        // Check if this is a list of image URLs
                                        bool isImageList = isImageField &&
                                            value.startsWith('[') &&
                                            value.contains('http');

                                        // Extract image URLs for display
                                        List<String> imageUrls = [];
                                        if (isImageList) {
                                          // Try to parse as JSON array first
                                          try {
                                            List<dynamic> urlList =
                                                json.decode(value);
                                            imageUrls = urlList
                                                .map((url) => url.toString())
                                                .toList();
                                            print(
                                                '🖼️  Parsed JSON array: ${imageUrls.length} URLs');
                                          } catch (e) {
                                            // Handle Python list format: ['url1', 'url2', 'url3']
                                            // Remove brackets and split by ', ' then clean quotes
                                            String cleaned = value
                                                .replaceFirst('[', '')
                                                .replaceFirst(']', '');

                                            // Split by ', ' and clean each URL
                                            List<String> allUrls = cleaned
                                                .split(', ')
                                                .map((url) => url
                                                    .trim()
                                                    .replaceAll("'", '')
                                                    .replaceAll('"', ''))
                                                .where((url) =>
                                                    url.startsWith('http'))
                                                .toList();

                                            print(
                                                '🖼️  All URLs found: ${allUrls.length}');

                                            // Debug: Show first few URLs
                                            if (allUrls.isNotEmpty) {
                                              print('🖼️  Sample URLs:');
                                              for (int i = 0;
                                                  i <
                                                      (allUrls.length > 3
                                                          ? 3
                                                          : allUrls.length);
                                                  i++) {
                                                print(
                                                    '    ${i + 1}. ${allUrls[i]}');
                                              }
                                            }

                                            // Filter to prioritize actual car images
                                            List<String> carImages = allUrls
                                                .where((url) =>
                                                    // Prioritize platform.cstatic-images.com (actual car photos)
                                                    url.contains(
                                                        'platform.cstatic-images.com') &&
                                                    (url.contains('/xlarge/') ||
                                                        url.contains(
                                                            '/small/')))
                                                .toList();

                                            // If we have car images, use them. Otherwise fall back to other images
                                            if (carImages.isNotEmpty) {
                                              imageUrls = carImages;
                                              print(
                                                  '🖼️  Using car images: ${imageUrls.length} URLs');
                                            } else {
                                              // Fallback to any image that's not obviously wrong
                                              imageUrls = allUrls
                                                  .where((url) =>
                                                      (url.contains('.jpg') ||
                                                          url.contains(
                                                              '.jpeg') ||
                                                          url.contains(
                                                              '.png') ||
                                                          url.contains(
                                                              '.webp')) &&
                                                      !url.contains(
                                                          'cars_logo') &&
                                                      !url.contains(
                                                          'dealerrater.com/employees') &&
                                                      !url.contains(
                                                          'awards/') &&
                                                      !url.contains(
                                                          'mobile-apps/') &&
                                                      !url.contains('akam/') &&
                                                      !url.contains('pixel_'))
                                                  .toList();
                                              print(
                                                  '🖼️  Using fallback images: ${imageUrls.length} URLs');
                                            }

                                            print(
                                                '🖼️  Filtered car images: ${imageUrls.length}');

                                            // Debug: Show first few filtered URLs
                                            if (imageUrls.isNotEmpty) {
                                              print(
                                                  '🖼️  Sample filtered URLs:');
                                              for (int i = 0;
                                                  i <
                                                      (imageUrls.length > 3
                                                          ? 3
                                                          : imageUrls.length);
                                                  i++) {
                                                print(
                                                    '    ${i + 1}. ${imageUrls[i]}');
                                              }
                                            }

                                            // If filtering removed all images, show all URLs as fallback
                                            if (imageUrls.isEmpty &&
                                                allUrls.isNotEmpty) {
                                              print(
                                                  '🖼️  No car images found, showing all URLs as fallback');
                                              imageUrls = allUrls
                                                  .take(20)
                                                  .toList(); // Limit to first 20
                                            }

                                            print(
                                                '🖼️  Final image count: ${imageUrls.length} URLs');
                                          }
                                        } else if (looksLikeImageUrl) {
                                          imageUrls = [value];
                                        }

                                        // Debug: Print if we think this is an image
                                        if (isImageField ||
                                            looksLikeImageUrl ||
                                            isImageList) {
                                          print(
                                              '🖼️  Detected image field: ${entry.key} = $value');
                                          print(
                                              '🖼️  Extracted ${imageUrls.length} image URLs');
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  '${entry.key}:',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: (isImageField ||
                                                            looksLikeImageUrl ||
                                                            isImageList) &&
                                                        entry.value != null &&
                                                        imageUrls.isNotEmpty
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Horizontal scrollable image list
                                                          SizedBox(
                                                            height: 120,
                                                            child: ListView
                                                                .builder(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              itemCount:
                                                                  imageUrls
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              8.0),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                    child: Image
                                                                        .network(
                                                                      imageUrls[
                                                                          index],
                                                                      width:
                                                                          160,
                                                                      height:
                                                                          120,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) {
                                                                        return Container(
                                                                          width:
                                                                              160,
                                                                          height:
                                                                              120,
                                                                          color:
                                                                              Colors.grey[300],
                                                                          child:
                                                                              const Icon(
                                                                            Icons.broken_image,
                                                                            color:
                                                                                Colors.grey,
                                                                            size:
                                                                                40,
                                                                          ),
                                                                        );
                                                                      },
                                                                      loadingBuilder: (context,
                                                                          child,
                                                                          loadingProgress) {
                                                                        if (loadingProgress ==
                                                                            null)
                                                                          return child;
                                                                        return Container(
                                                                          width:
                                                                              160,
                                                                          height:
                                                                              120,
                                                                          color:
                                                                              Colors.grey[200],
                                                                          child:
                                                                              const Center(
                                                                            child:
                                                                                CircularProgressIndicator(),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            '${imageUrls.length} images - Scroll horizontally to see all',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Text(
                                                        entry.value
                                                                ?.toString() ??
                                                            'N/A',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
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
            ),
          ],
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
