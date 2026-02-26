import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fowra/screens/Login_screen.dart';
import 'package:fowra/screens/add_plant_screen.dart';
import 'package:fowra/screens/plant_detail_screen.dart';
import 'package:fowra/services/plant_service.dart';
import 'package:fowra/services/auth_service.dart';
import 'package:fowra/widgets/custom_bottom_nav_bar.dart';

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({super.key});

  @override
  State<MyDiaryScreen> createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen> {
  bool _isProfileExpanded = false;
  List<dynamic> _plants = [];
  bool _isLoadingPlants = true;
  String _errorMessage = '';
  String _userName = 'Loading...';
  String _userYear = 'N/A';
  String _userClass = 'N/A';

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndPlants();
  }

  Future<void> _fetchUserDataAndPlants() async {
    setState(() {
      _isLoadingPlants = true;
      _errorMessage = '';
    });

    try {
      final userDetails = await AuthService.getUserDetails();

      final plantsData = await PlantService.getPlants();
      if (!mounted) return;

      setState(() {
        _userName = userDetails['name'] ?? 'Student Farmer';
        _userYear = userDetails['year'] ?? 'N/A';
        _userClass = userDetails['class'] ?? 'N/A';

        _plants = plantsData;
        _isLoadingPlants = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoadingPlants = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC4D7BC),
      appBar: AppBar(
        title: const Text(
          'My Diary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileContainer(),
              const SizedBox(height: 24),
              _buildPlantListContainer(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Spacing for bottom nav bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildProfileContainer() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isProfileExpanded = !_isProfileExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 24,
                ), // Placeholder to center 'PROFILE' roughly
                const Text(
                  'PROFILE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E654D),
                  ),
                ),
                Icon(
                  _isProfileExpanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF2E654D),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Member since 2024',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isProfileExpanded) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildProfileDetailRow('Name', _userName),
              const SizedBox(height: 12),
              _buildProfileDetailRow('Year', _userYear),
              const SizedBox(height: 12),
              _buildProfileDetailRow('Class', _userClass),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPlantListContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ), // box shadow
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PLANT LIST',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: Color(0xFF2E654D), // Dark green text
                ),
              ),
              // Plus Button
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddPlantScreen(),
                    ),
                  );
                  // Refresh list if a plant was added
                  if (result == true) {
                    _fetchUserDataAndPlants();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50), // Green button background
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_isLoadingPlants)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage.isNotEmpty)
            Center(
              child: Text(
                'Failed to load plants.\nPlease check connection.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade300),
              ),
            )
          else if (_plants.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No plants yet.\nTap + to add one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _plants.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plant = _plants[index];
                return Dismissible(
                  key: Key(plant['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    final plantId = plant['id'];

                    // Optimistically remove from list
                    setState(() {
                      _plants.removeAt(index);
                    });

                    // Call backend to delete
                    final result = await PlantService.deletePlant(plantId);

                    if (result['success'] == false) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'])),
                      );
                      // Since it failed, fetch again to restore list
                      _fetchUserDataAndPlants();
                    }
                  },
                  child: _buildPlantItem(plant),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlantItem(Map<String, dynamic> plant) {
    final plantName = plant['name'] ?? 'Unknown';
    final assetPath = plant['image_path'] ?? 'assets/plantlist/tomato.webp';

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailScreen(plant: plant),
          ),
        );
        if (result == true) {
          _fetchUserDataAndPlants();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9), // Light green tint
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFC4D7BC)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: assetPath.startsWith('assets')
                    ? Image.asset(
                        assetPath,
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(assetPath),
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
