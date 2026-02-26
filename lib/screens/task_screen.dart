import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fowra/services/diary_service.dart';

class TaskScreen extends StatefulWidget {
  final DateTime date;
  final Map<String, dynamic>? initialData;

  const TaskScreen({super.key, required this.date, this.initialData});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // Store checkbox states
  final Map<String, bool> _tasks = {
    'Watering': false,
    'Misting': false,
    'Fertilizing': false,
    'Rotating': false,
  };

  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = true; // True for new entries, False when viewing existing
  File? _selectedImage;
  TimeOfDay? _selectedTime;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.now(); // Default to current time for new

    if (widget.initialData != null) {
      final data = widget.initialData!;
      _isEditing = false; // Existing entries start in View mode

      final timeStr = data['entry_time'];
      if (timeStr != null && timeStr.toString().isNotEmpty) {
        final parts = timeStr.toString().split(':');
        if (parts.length >= 2) {
          _selectedTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }

      _tasks['Watering'] = data['watering'] == 1 || data['watering'] == true;
      _tasks['Misting'] = data['misting'] == 1 || data['misting'] == true;
      _tasks['Fertilizing'] =
          data['fertilizing'] == 1 || data['fertilizing'] == true;
      _tasks['Rotating'] = data['rotating'] == 1 || data['rotating'] == true;
      _notesController.text = data['notes'] ?? '';

      final imagePath = data['image_path'];
      if (imagePath != null && imagePath.isNotEmpty) {
        _selectedImage = File(imagePath);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    }
  }

  Future<void> _saveEntry() async {
    setState(() => _isLoading = true);

    // Format date to YYYY-MM-DD
    final d = widget.date;
    final dateString =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final timeString = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00'
        : null;

    final entryData = {
      if (widget.initialData != null && widget.initialData!['id'] != null)
        'id': widget.initialData!['id'],
      'entry_date': dateString,
      'entry_time': timeString,
      'watering': _tasks['Watering'] == true,
      'misting': _tasks['Misting'] == true,
      'fertilizing': _tasks['Fertilizing'] == true,
      'rotating': _tasks['Rotating'] == true,
      'notes': _notesController.text.trim(),
      'image_path': _selectedImage?.path,
    };

    final result = await DiaryService.saveDiaryEntry(entryData);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diary entry saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to save')),
      );
    }
  }

  Future<void> _deleteEntry() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text(
          'Are you sure you want to delete this daily report?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final entryId = widget.initialData?['id'];
    if (entryId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final result = await DiaryService.deleteDiaryEntry(entryId);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diary entry deleted'),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pop(context, true); // Return true to refresh DiaryScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to delete')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC4D7BC),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopActions(context),
            const SizedBox(height: 10),
            _buildDateHeader(),
            const SizedBox(height: 30),
            const Text(
              'TASK FOR TODAY',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  _buildTaskItem('Watering', 'assets/taskicon/watering.png'),
                  const SizedBox(height: 16),
                  _buildTaskItem('Misting', 'assets/taskicon/misting.png'),
                  const SizedBox(height: 16),
                  _buildTaskItem(
                    'Fertilizing',
                    'assets/taskicon/fertilizing.png',
                  ),
                  const SizedBox(height: 16),
                  _buildTaskItem('Rotating', 'assets/taskicon/rotating.png'),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _notesController,
                    maxLines: null,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      hintText: 'Add notes..',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                      border: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        _selectedImage!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 60), // Space for bottom toolbar
                ],
              ),
            ),
            _buildBottomToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, size: 30, color: Colors.black),
          ),
          Row(
            children: [
              if (widget.initialData != null) ...[
                GestureDetector(
                  onTap: _isLoading ? null : _deleteEntry,
                  child: const Icon(
                    Icons.delete,
                    size: 28,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  child: Icon(
                    Icons.edit,
                    size: 28,
                    color: _isEditing
                        ? const Color(0xFF2E654D)
                        : Colors.black87,
                  ),
                ),
                const SizedBox(width: 15),
              ],
              if (_isEditing)
                GestureDetector(
                  onTap: _isLoading ? null : _saveEntry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E654D), // Dark green save button
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'SAVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    if (!_isEditing) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E654D), // Dark green
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Widget _buildDateHeader() {
    final monthNames = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];

    // Use selectedTime if available, else fallback to widget.date
    final displayHour = _selectedTime?.hour ?? widget.date.hour;
    final displayMinute = _selectedTime?.minute ?? widget.date.minute;

    String amPm = displayHour >= 12 ? 'P.M' : 'A.M';
    int hour12 = displayHour > 12
        ? displayHour - 12
        : (displayHour == 0 ? 12 : displayHour);
    String minuteStr = displayMinute.toString().padLeft(2, '0');
    String timeStr = '$hour12.$minuteStr $amPm';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${widget.date.day}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _isEditing
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${monthNames[widget.date.month - 1]} ${widget.date.year} | $timeStr',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _isEditing
                              ? const Color(0xFF2E654D)
                              : Colors.black87,
                        ),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.edit_calendar,
                          size: 14,
                          color: Color(0xFF2E654D),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Using eventday.png as placeholder for the small plant pot on top right
          Image.asset('assets/calender/eventday.png', width: 40, height: 40),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String taskName, String assetPath) {
    bool isDone = _tasks[taskName] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: const Color(
          0xFF198754,
        ), // Bootstrap success green used in mockup
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Circle task icon background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(taskName),
              shape: BoxShape.circle,
            ),
            child: Image.asset(assetPath, width: 24, height: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              taskName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          GestureDetector(
            onTap: _isEditing
                ? () {
                    setState(() {
                      _tasks[taskName] = !isDone;
                    });
                  }
                : null,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 1.5),
                borderRadius: BorderRadius.circular(6),
                color: isDone ? Colors.white : Colors.transparent,
              ),
              child: isDone
                  ? const Icon(Icons.check, color: Color(0xFF198754), size: 24)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconBackgroundColor(String task) {
    switch (task) {
      case 'Watering':
        return Colors.purple.shade300;
      case 'Misting':
        return Colors.amber.shade400;
      case 'Fertilizing':
        return Colors.teal.shade200;
      case 'Rotating':
        return Colors.pink.shade300;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBottomToolbar() {
    return IgnorePointer(
      ignoring: !_isEditing,
      child: Opacity(
        opacity: _isEditing ? 1.0 : 0.6,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF8BC34A), // Light green toolbar
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: const Icon(Icons.image_outlined, color: Colors.black87),
              ),
              const Icon(Icons.videocam_outlined, color: Colors.black87),
              const Icon(Icons.mic_none_outlined, color: Colors.black87),
              const Icon(
                Icons.sentiment_satisfied_outlined,
                color: Colors.black87,
              ),
              const Icon(Icons.format_size_outlined, color: Colors.black87),
              const Icon(Icons.local_offer_outlined, color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }
}
