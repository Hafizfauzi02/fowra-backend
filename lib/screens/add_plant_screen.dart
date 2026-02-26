import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fowra/services/plant_service.dart';
import 'package:image_picker/image_picker.dart';

class AddPlantScreen extends StatefulWidget {
  final Map<String, dynamic>? plantToEdit;

  const AddPlantScreen({super.key, this.plantToEdit});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final TextEditingController _nameController = TextEditingController();

  // State variables for the selectors
  int? _sunValue;
  int? _waterValue;
  int? _soilPhValue;
  int? _harvestValue;
  int? _heightValue;

  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.plantToEdit != null) {
      final plant = widget.plantToEdit!;
      _nameController.text = plant['name'] ?? '';
      _sunValue = plant['sun_exposure'];
      _waterValue = plant['water_amount'];
      _soilPhValue = plant['soil_ph'];
      _harvestValue = plant['harvest_days'];
      _heightValue = plant['height'];

      final imagePath = plant['image_path'];
      if (imagePath != null && !imagePath.startsWith('assets')) {
        _selectedImage = File(imagePath);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF2E654D,
      ), // Dark green background for header
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildImagePickerPlaceholder(),
                      const SizedBox(height: 20),
                      _buildNameInputBox(),
                      const SizedBox(height: 20),
                      // List of selectors
                      _buildSelectorPill(
                        'Sun (m)',
                        Icons.wb_sunny,
                        Colors.amber,
                        _sunValue,
                        (val) => setState(() => _sunValue = val),
                      ),
                      const SizedBox(height: 12),
                      _buildSelectorPill(
                        'Water (ml) ',
                        Icons.water_drop,
                        Colors.cyan,
                        _waterValue,
                        (val) => setState(() => _waterValue = val),
                      ),
                      const SizedBox(height: 12),
                      _buildSelectorPill(
                        'Soil Ph (pH)',
                        Icons.science,
                        const Color(0xFF5D4037),
                        _soilPhValue,
                        (val) => setState(() => _soilPhValue = val),
                      ),
                      const SizedBox(height: 12),
                      _buildSelectorPill(
                        'Harvest (days)',
                        Icons.agriculture,
                        Colors.deepOrangeAccent,
                        _harvestValue,
                        (val) => setState(() => _harvestValue = val),
                      ),
                      const SizedBox(height: 12),
                      _buildSelectorPill(
                        'Height (feet)',
                        Icons.height,
                        Colors.green.shade800,
                        _heightValue,
                        (val) => setState(() => _heightValue = val),
                      ),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
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

  Widget _buildAppBar() {
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
          Text(
            widget.plantToEdit != null ? 'Edit Plant' : 'Add New Plant',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Top right Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePickerPlaceholder() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _selectedImage != null
              ? Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(color: Colors.white),
                    // Inner button "Choose Image..."
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Choose\nImage...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNameInputBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Name',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Name',
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorPill(
    String title,
    IconData iconData,
    Color iconColor,
    int? currentValue,
    Function(int) onSelected,
  ) {
    return GestureDetector(
      onTap: () {
        _showNumberPickerDialog(title, currentValue, onSelected);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(iconData, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              currentValue != null ? currentValue.toString() : 'Select',
              style: TextStyle(
                fontSize: 16,
                color: currentValue != null ? Colors.black87 : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showNumberPickerDialog(
    String title,
    int? currentValue,
    Function(int) onSelected,
  ) async {
    int tempValue = currentValue ?? 1;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Select $title'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (tempValue > 0) {
                        setDialogState(() {
                          tempValue--;
                        });
                      }
                    },
                  ),
                  Text(
                    tempValue.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setDialogState(() {
                        tempValue++;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    onSelected(tempValue);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        onPressed: _isLoading ? null : _savePlantDetails,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'SAVE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _savePlantDetails() async {
    // Basic validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a plant name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final plantData = {
      'name': _nameController.text.trim(),
      'image_path':
          _selectedImage?.path ??
          (widget.plantToEdit?['image_path'] ?? 'assets/plantlist/tomato.webp'),
      'sun_exposure': _sunValue ?? 0,
      'water_amount': _waterValue ?? 0,
      'soil_ph': _soilPhValue ?? 0,
      'harvest_days': _harvestValue ?? 0,
      'height': _heightValue ?? 0,
    };

    final result = widget.plantToEdit != null
        ? await PlantService.updatePlant(widget.plantToEdit!['id'], plantData)
        : await PlantService.addPlant(plantData);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plant details saved perfectly!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(
        context,
        true,
      ); // Go back after saving, pass true to refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to save plant details'),
        ),
      );
    }
  }
}
