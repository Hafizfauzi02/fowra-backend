import 'dart:io';
import 'package:flutter/material.dart';

import 'package:fowra/screens/add_plant_screen.dart';

class PlantDetailScreen extends StatelessWidget {
  final Map<String, dynamic> plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final imagePath = plant['image_path'] ?? 'assets/plantlist/tomato.webp';
    final plantName = plant['name'] ?? 'Unknown';

    // Derived strings
    final sunDays = '${plant['sun_exposure'] ?? 0} Hours/Day';
    final waterFreq = '${plant['water_amount'] ?? 0} ml';
    final soilPh = '${plant['soil_ph'] ?? 0} pH';
    final harvestTime = '${plant['harvest_days'] ?? 0} Days\nAfter Planting';
    final heightVal = '${plant['height'] ?? 0} Feet';

    // Format date added
    String dateAdded = 'Unknown Date';
    if (plant['created_at'] != null) {
      try {
        final parsedDate = DateTime.parse(plant['created_at']);
        dateAdded = '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      } catch (e) {
        // ignore format error
      }
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFF2E654D,
      ), // Dark green background for header
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context, plant),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFC4D7BC), // Light green background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Main image header
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: imagePath.startsWith('assets')
                            ? Image.asset(
                                imagePath,
                                width: double.infinity,
                                height:
                                    200, // Fixed height for the header image
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(imagePath),
                                width: double.infinity,
                                height:
                                    200, // Fixed height for the header image
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(
                        height: 20,
                      ), // Space between image and white card
                      // White Card Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildPlantImageAndName(
                              imagePath,
                              plantName,
                              dateAdded,
                            ),
                            const SizedBox(height: 30),

                            // Detail Rows
                            _buildDetailRow(
                              Icons.wb_sunny,
                              Colors.amber,
                              'Sun',
                              sunDays,
                            ),
                            _buildDivider(),
                            _buildDetailRow(
                              Icons.water_drop,
                              Colors.cyan,
                              'Water',
                              waterFreq,
                            ),
                            _buildDivider(),
                            _buildDetailRow(
                              Icons.science,
                              const Color(0xFF5D4037),
                              'Soil Ph',
                              soilPh,
                            ),
                            _buildDivider(),
                            _buildDetailRow(
                              Icons.agriculture,
                              Colors.deepOrangeAccent,
                              'Harvest',
                              harvestTime,
                            ),
                            _buildDivider(),
                            _buildDetailRow(
                              Icons.height,
                              Colors.green.shade800,
                              'Height',
                              heightVal,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
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

  Widget _buildAppBar(BuildContext context, Map<String, dynamic> plant) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: const [
                Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                Text(
                  'Back',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),

          // Title
          const Text(
            'My Plants',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Edit/Badge container over on the right
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPlantScreen(plantToEdit: plant),
                    ),
                  );
                  if (result == true) {
                    if (!context.mounted) return;
                    Navigator.pop(
                      context,
                      true,
                    ); // Pop back to diary screen to refresh
                  }
                },
                child: const Icon(Icons.edit, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text(
                      '60',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Color(0xFF2E654D),
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlantImageAndName(
    String imagePath,
    String plantName,
    String dateAdded,
  ) {
    return Column(
      children: [
        // Profile image circle
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF1F8E9), // Light background behind image
            border: Border.all(color: Colors.grey.shade200, width: 2),
          ),
          child: ClipOval(
            child: imagePath.startsWith('assets')
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_florist,
                        size: 50,
                        color: Colors.grey,
                      );
                    },
                  )
                : Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_florist,
                        size: 50,
                        color: Colors.grey,
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          plantName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              dateAdded,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData iconData,
    Color iconColor,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(iconData, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade200, thickness: 1.5, height: 1);
  }
}
