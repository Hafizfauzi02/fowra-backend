import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fowra/screens/task_screen.dart';
import 'package:fowra/services/diary_service.dart';

class DiaryScreen extends StatefulWidget {
  final DateTime date;

  const DiaryScreen({super.key, required this.date});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<dynamic> _diaryEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiary();
  }

  Future<void> _loadDiary() async {
    setState(() => _isLoading = true);

    final d = widget.date;
    final dateString =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final result = await DiaryService.fetchDiaryEntries(dateString);
    if (!mounted) return;

    if (result['success'] && result['data'] != null) {
      setState(() {
        _diaryEntries = List<dynamic>.from(result['data']);
        _isLoading = false;
      });
    } else {
      setState(() {
        _diaryEntries = [];
        _isLoading = false;
      });
    }
  }

  void _navigateToTaskScreen({Map<String, dynamic>? existingData}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TaskScreen(date: widget.date, initialData: existingData),
      ),
    );

    if (result == true) {
      _loadDiary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC4D7BC),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: const Color(0xFF2E654D),
                          )
                        : _diaryEntries.isNotEmpty
                        ? _buildSavedState()
                        : Center(child: _buildEmptyState()),
                  ),
                ),
              ],
            ),
            // Floating Action Button
            Positioned(
              bottom: 30,
              right: 30,
              child: FloatingActionButton(
                onPressed: () =>
                    _navigateToTaskScreen(), // Always pass null to create new target
                backgroundColor: const Color(0xFF2E654D), // Dark green
                elevation: 4,
                child: const Icon(Icons.add, size: 36, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, size: 30, color: Colors.black),
            ),
          ),
          const Text(
            'VIEW MY DIARY',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Text(
      'Empty..',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildSavedState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      itemCount: _diaryEntries.length,
      itemBuilder: (context, index) {
        final entry = _diaryEntries[index];
        final notes = entry['notes'] ?? '';
        final imagePath = entry['image_path'] ?? '';

        List<Widget> completedTasks = [];
        if (entry['watering'] == 1 || entry['watering'] == true) {
          completedTasks.add(
            _buildCompletedTaskRow(
              'Watering',
              'assets/taskicon/watering.png',
              Colors.purple.shade300,
            ),
          );
        }
        if (entry['misting'] == 1 || entry['misting'] == true) {
          completedTasks.add(
            _buildCompletedTaskRow(
              'Misting',
              'assets/taskicon/misting.png',
              Colors.amber.shade400,
            ),
          );
        }
        if (entry['fertilizing'] == 1 || entry['fertilizing'] == true) {
          completedTasks.add(
            _buildCompletedTaskRow(
              'Fertilizing',
              'assets/taskicon/fertilizing.png',
              Colors.teal.shade200,
            ),
          );
        }
        if (entry['rotating'] == 1 || entry['rotating'] == true) {
          completedTasks.add(
            _buildCompletedTaskRow(
              'Rotating',
              'assets/taskicon/rotating.png',
              Colors.pink.shade300,
            ),
          );
        }

        return GestureDetector(
          onTap: () => _navigateToTaskScreen(existingData: entry),
          child: Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2E654D), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Report ${index + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E654D),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF2E654D),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (imagePath.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(imagePath),
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (completedTasks.isNotEmpty) ...[
                  const Text(
                    'COMPLETED TASKS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...completedTasks,
                  const SizedBox(height: 12),
                ],
                if (notes.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      notes,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedTaskRow(
    String taskName,
    String assetPath,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF198754),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
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
          const Icon(Icons.check_circle, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}
