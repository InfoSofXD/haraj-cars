import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/car.dart';
import 'package:intl/intl.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({
    Key? key,
    required this.car,
  }) : super(key: key);

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get allImages {
    final images = <String>[];
    if (widget.car.mainImage != null && widget.car.mainImage!.isNotEmpty) {
      images.add(widget.car.mainImage!);
    }
    if (widget.car.otherImages != null) {
      images.addAll(widget.car.otherImages!);
    }
    return images;
  }

  void _launchContact(String contact) async {
    Uri uri;

    if (contact.startsWith('+') || contact.startsWith('00')) {
      // Phone number
      uri = Uri.parse('tel:$contact');
    } else if (contact.contains('@')) {
      // Email
      uri = Uri.parse('mailto:$contact');
    } else if (contact.startsWith('https://wa.me/') ||
        contact.startsWith('wa.me/')) {
      // WhatsApp link
      uri = Uri.parse(
          contact.startsWith('https://') ? contact : 'https://$contact');
    } else if (contact.startsWith('https://t.me/') ||
        contact.startsWith('t.me/')) {
      // Telegram link
      uri = Uri.parse(
          contact.startsWith('https://') ? contact : 'https://$contact');
    } else {
      // Assume it's a phone number
      uri = Uri.parse('tel:$contact');
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Error launching contact: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'SAR ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.car.computedTitle,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery Section
            if (allImages.isNotEmpty) ...[
              Container(
                height: 300,
                width: double.infinity,
                child: Stack(
                  children: [
                    // PageView for images
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: allImages.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          allImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.car_rental,
                                size: 80,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Image counter indicator
                    if (allImages.length > 1)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${allImages.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Previous/Next buttons
                    if (allImages.length > 1) ...[
                      // Previous button
                      if (_currentImageIndex > 0)
                        Positioned(
                          left: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: FloatingActionButton.small(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.chevron_left),
                            ),
                          ),
                        ),

                      // Next button
                      if (_currentImageIndex < allImages.length - 1)
                        Positioned(
                          right: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: FloatingActionButton.small(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              // Image thumbnails
              if (allImages.length > 1)
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _currentImageIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                              width: _currentImageIndex == index ? 3 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.network(
                              allImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.car_rental,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ] else ...[
              // No images placeholder
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.car_rental,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ],

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.car.computedTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        currencyFormat.format(widget.car.price),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  if (widget.car.description.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.car.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Car Specifications
                  const Text(
                    'Car Specifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Specifications Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        // First Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecItem('Brand', widget.car.brand,
                                  Icons.directions_car),
                            ),
                            Expanded(
                              child: _buildSpecItem('Model', widget.car.model,
                                  Icons.directions_car),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Second Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecItem(
                                  'Year',
                                  widget.car.year.toString(),
                                  Icons.calendar_today),
                            ),
                            Expanded(
                              child: _buildSpecItem('Mileage',
                                  '${widget.car.mileage} km', Icons.speed),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Third Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecItem('Transmission',
                                  widget.car.transmission, Icons.settings),
                            ),
                            Expanded(
                              child: _buildSpecItem('Fuel Type',
                                  widget.car.fuelType, Icons.local_gas_station),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Fourth Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecItem('Engine',
                                  widget.car.engineSize, Icons.engineering),
                            ),
                            Expanded(
                              child: _buildSpecItem(
                                  'Power',
                                  '${widget.car.horsepower} HP',
                                  Icons.flash_on),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Fifth Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecItem('Drive',
                                  widget.car.driveType, Icons.all_inclusive),
                            ),
                            Expanded(
                              child: _buildSpecItem('Doors',
                                  '${widget.car.doors}', Icons.door_front_door),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Sixth Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecItem(
                                  'Seats',
                                  '${widget.car.seats}',
                                  Icons.airline_seat_recline_normal),
                            ),
                            Expanded(
                              child: _buildSpecItem('Exterior',
                                  widget.car.exteriorColor, Icons.palette),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Seventh Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecItem('Interior',
                                  widget.car.interiorColor, Icons.chair),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Information
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.contact_phone,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.car.contact,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchContact(widget.car.contact),
                      icon: const Icon(Icons.contact_phone, size: 24),
                      label: const Text(
                        'Contact Seller',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Additional Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Additional Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Listed on:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(widget.car.createdAt),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Last updated:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(widget.car.updatedAt),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
