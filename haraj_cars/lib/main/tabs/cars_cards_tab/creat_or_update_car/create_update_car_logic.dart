// add_car_screen.dart

import 'package:flutter/material.dart';
import '../../../../models/car.dart';
import 'logic/creat_update_car.dart';

class AddCarScreen extends StatefulWidget {
  final Car? car; // Optional car for edit mode
  
  const AddCarScreen({Key? key, this.car}) : super(key: key);

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  late CreateUpdateCarLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = CreateUpdateCarLogic();
    _logic.initialize(existingCar: widget.car);
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _logic.setLoading(true);
    });

    try {
      final success = await _logic.saveCar(existingCar: widget.car);

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.car != null 
                  ? 'Car updated successfully!' 
                  : 'Car added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.car != null 
                  ? 'Failed to update car. Please try again.' 
                  : 'Failed to save car. Please try again.'),
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
          _logic.setLoading(false);
        });
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
      String label, DateTime? selectedDate, String fieldName, String hint) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                await _logic.selectDate(context, fieldName);
                setState(() {});
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedDate != null
                            ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                            : hint,
                        style: TextStyle(
                          color: selectedDate != null
                              ? Colors.black87
                              : Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (selectedDate != null)
                      GestureDetector(
                        onTap: () {
                          _logic.clearDate(fieldName);
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.clear,
                            color: Colors.red.shade600,
                            size: 16,
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
    );
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
                      Text(
                        widget.car != null ? 'Edit Car' : 'Add New Car',
                        style: const TextStyle(
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
                        onTap: () async {
                          await _logic.pickImage();
                          setState(() {});
                        },
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
                          child: _logic.selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _logic.selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : widget.car?.mainImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        widget.car!.mainImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildImagePlaceholder();
                                        },
                                      ),
                                    )
                                  : _buildImagePlaceholder(),
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
                              onPressed: () async {
                                await _logic.pickOtherImage();
                                setState(() {});
                              },
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
                          if (_logic.otherImages.isNotEmpty || 
                              (widget.car?.otherImages?.isNotEmpty ?? false))
                            Text(
                              '${_logic.otherImages.length + (widget.car?.otherImages?.length ?? 0)} image(s)',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontFamily: 'Tajawal',
                              ),
                            ),
                        ],
                      ),
                      if (_logic.otherImages.isNotEmpty || 
                          (widget.car?.otherImages?.isNotEmpty ?? false)) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _logic.otherImages.length + 
                                (widget.car?.otherImages?.length ?? 0),
                            itemBuilder: (context, index) {
                              if (index < _logic.otherImages.length) {
                                // New selected images
                                return Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _logic.otherImages[index],
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            _logic.removeOtherImage(index);
                                            setState(() {});
                                          },
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
                              } else {
                                // Existing images
                                final existingIndex = index - _logic.otherImages.length;
                                return Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      widget.car!.otherImages![existingIndex],
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Basic Information Section
                      _buildSectionHeader(
                          'Basic Information', Icons.info_outline),
                      const SizedBox(height: 16),

                      // Description - Full width
                      TextFormField(
                        controller: _logic.descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          hintText: 'Describe the car...',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Price and Contact in a row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _logic.priceController,
                              decoration: const InputDecoration(
                                labelText: 'Price *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                                hintText: 'e.g., 50000',
                              ),
                              keyboardType: TextInputType.number,
                              validator: _logic.validatePrice,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _logic.contactController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Info *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.contact_phone),
                                hintText: 'Phone, WhatsApp, or Email',
                              ),
                              validator: _logic.validateContact,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Car Specifications Section
                      _buildSectionHeader(
                          'Car Specifications', Icons.directions_car),
                      const SizedBox(height: 16),

                      // Brand and Model Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _logic.selectedBrand.isEmpty
                                  ? null
                                  : _logic.selectedBrand,
                              decoration: const InputDecoration(
                                labelText: 'Brand *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.directions_car),
                              ),
                              items: _logic.brands.map((String brand) {
                                return DropdownMenuItem<String>(
                                  value: brand,
                                  child: Text(brand),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _logic.updateBrand(newValue ?? '');
                                });
                              },
                              validator: _logic.validateBrand,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _logic.modelController,
                              decoration: const InputDecoration(
                                labelText: 'Model *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.directions_car),
                                hintText: 'e.g., Corolla',
                              ),
                              validator: _logic.validateModel,
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
                              controller: _logic.yearController,
                              decoration: const InputDecoration(
                                labelText: 'Year *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                                hintText: 'e.g., 2018',
                              ),
                              keyboardType: TextInputType.number,
                              validator: _logic.validateYear,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _logic.mileageController,
                              decoration: const InputDecoration(
                                labelText: 'Mileage (km) *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.speed),
                                hintText: 'e.g., 50000',
                              ),
                              keyboardType: TextInputType.number,
                              validator: _logic.validateMileage,
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
                              value: _logic.selectedTransmission,
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
                                  _logic.updateTransmission(newValue!);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _logic.selectedFuelType,
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
                                  _logic.updateFuelType(newValue!);
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
                              controller: _logic.engineController,
                              decoration: const InputDecoration(
                                labelText: 'Engine *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.engineering),
                                hintText: 'e.g., 2.0L',
                              ),
                              validator: _logic.validateEngine,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _logic.horsepowerController,
                              decoration: const InputDecoration(
                                labelText: 'Horsepower *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.flash_on),
                                hintText: 'e.g., 150',
                              ),
                              keyboardType: TextInputType.number,
                              validator: _logic.validateHorsepower,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Drive Type and Colors Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _logic.selectedDriveType,
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
                                  _logic.updateDriveType(newValue!);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _logic.exteriorColorController,
                              decoration: const InputDecoration(
                                labelText: 'Exterior Color *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.palette),
                                hintText: 'e.g., White',
                              ),
                              validator: _logic.validateExteriorColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Interior Color, Doors and Seats Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _logic.interiorColorController,
                              decoration: const InputDecoration(
                                labelText: 'Interior Color *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.chair),
                                hintText: 'e.g., Black',
                              ),
                              validator: _logic.validateInteriorColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _logic.doorsController,
                              decoration: const InputDecoration(
                                labelText: 'Doors *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.door_front_door),
                                hintText: 'e.g., 4',
                              ),
                              keyboardType: TextInputType.number,
                              validator: _logic.validateDoors,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _logic.seatsController,
                              decoration: const InputDecoration(
                                labelText: 'Seats *',
                                border: OutlineInputBorder(),
                                prefixIcon:
                                    Icon(Icons.airline_seat_recline_normal),
                                hintText: 'e.g., 5',
                              ),
                              keyboardType: TextInputType.number,
                              validator: _logic.validateSeats,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // VIN Field
                      TextFormField(
                        controller: _logic.vinController,
                        decoration: const InputDecoration(
                          labelText: 'VIN (Vehicle Identification Number)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.confirmation_number),
                          hintText: 'e.g., 1HGBH41JXMN109186',
                        ),
                        validator: _logic.validateVin,
                      ),

                      const SizedBox(height: 24),

                      // Timestamp Fields Section
                      _buildSectionHeader(
                        _logic.status == 3
                            ? 'Auction & Timing Settings'
                            : 'Timing Settings',
                        _logic.status == 3 ? Icons.gavel : Icons.schedule,
                      ),
                      const SizedBox(height: 16),

                      // Show/Un-Show Dates Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              'Show At',
                              _logic.showAt,
                              'showAt',
                              'When to show',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                              'Un-Show At',
                              _logic.unShowAt,
                              'unShowAt',
                              'When to hide',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Auction Start Date - Only show if status is Auction (3)
                      if (_logic.status == 3) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.gavel,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Auction mode selected - set auction start and end times',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                'Auction Start At',
                                _logic.auctionStartAt,
                                'auctionStartAt',
                                'When auction starts',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDateField(
                                'Auction End At',
                                _logic.auctionEndAt,
                                'auctionEndAt',
                                'When auction ends',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Delete At Date
                      _buildDateField(
                        'Delete At',
                        _logic.deleteAt,
                        'deleteAt',
                        'When to automatically delete this listing',
                      ),

                      const SizedBox(height: 24),

                      // Status Section
                      _buildSectionHeader('Availability Status', Icons.flag),
                      const SizedBox(height: 16),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.flag,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _logic.status,
                                  decoration: const InputDecoration(
                                    labelText: 'Status',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 1,
                                      child: Text('Available'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Text('Unavailable'),
                                    ),
                                    DropdownMenuItem(
                                      value: 3,
                                      child: Text('Auction'),
                                    ),
                                    DropdownMenuItem(
                                      value: 4,
                                      child: Text('Sold'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _logic.updateStatus(value!);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
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
                          onPressed: _logic.isLoading ? null : _saveCar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _logic.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  widget.car != null ? 'Update Car' : 'Add Car',
                                  style: const TextStyle(
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

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: 60,
          color: Colors.black.withOpacity(0.7),
        ),
        const SizedBox(height: 8),
        Text(
          widget.car != null ? 'Tap to change image' : 'Tap to add main image',
          style: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontSize: 16,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }
}
