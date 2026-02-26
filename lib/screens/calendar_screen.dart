import 'package:flutter/material.dart';
import 'package:fowra/screens/diary_screen.dart';
import 'package:fowra/services/diary_service.dart';
import 'package:fowra/widgets/custom_bottom_nav_bar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Map<int, bool> _monthlyEntries =
      {}; // Maps day of month to whether an entry exists
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEntriesForMonth(_currentMonth);
  }

  Future<void> _fetchEntriesForMonth(DateTime month) async {
    setState(() {
      _isLoading = true;
    });

    final yearMonthStr =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final response = await DiaryService.fetchMonthlyEntries(yearMonthStr);

    if (response['success']) {
      final List<dynamic> entries = response['data'];
      final Map<int, bool> newEntriesMap = {};

      for (var entry in entries) {
        // Parse "YYYY-MM-DD" back into day
        if (entry['entry_date'] != null) {
          final dateStr = entry['entry_date'].toString().split('T')[0];
          final day = int.parse(dateStr.split('-')[2]);
          newEntriesMap[day] = true;
        }
      }

      // Special handling if switching months back and forth quickly
      if (mounted &&
          _currentMonth.year == month.year &&
          _currentMonth.month == month.month) {
        setState(() {
          _monthlyEntries = newEntriesMap;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _fetchEntriesForMonth(_currentMonth);
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _fetchEntriesForMonth(_currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC4D7BC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildDaysOfWeek(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCalendarGrid(),
            ),
            _buildLegend(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _previousMonth,
                child: const Icon(Icons.arrow_circle_left_outlined, size: 30),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'serif', // Trying to match the bubbly font
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: const Icon(Icons.arrow_circle_right_outlined, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.push_pin, color: Colors.redAccent, size: 16),
              Expanded(child: Container(height: 1, color: Colors.black54)),
              const Icon(Icons.push_pin, color: Colors.redAccent, size: 16),
              Expanded(child: Container(height: 1, color: Colors.black54)),
              const Icon(Icons.push_pin, color: Colors.redAccent, size: 16),
              Expanded(child: Container(height: 1, color: Colors.black54)),
              const Icon(Icons.push_pin, color: Colors.redAccent, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    final days = [
      {'text': 'Sun', 'color': Colors.blue.shade700},
      {'text': 'Mon', 'color': Colors.red.shade900},
      {'text': 'Tue', 'color': Colors.amber.shade700},
      {'text': 'Wed', 'color': Colors.lightBlue.shade700},
      {'text': 'Thu', 'color': Colors.purple.shade500},
      {'text': 'Fri', 'color': Colors.green.shade700},
      {'text': 'Sat', 'color': Colors.pink.shade300},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          return Text(
            day['text'] as String,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: day['color'] as Color,
              shadows: const [
                Shadow(
                  color: Colors.white,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    int totalDays = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    DateTime firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );

    int offset = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<int> daysStatus = List.filled(offset, 0, growable: true);
    for (int i = 1; i <= totalDays; i++) {
      final currentIterDate = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        i,
      );
      final isSubmitted =
          _monthlyEntries.containsKey(i) && _monthlyEntries[i] == true;

      if (isSubmitted) {
        if (currentIterDate == today ||
            currentIterDate.isAtSameMomentAs(today)) {
          daysStatus.add(3); // Event day submitted
        } else {
          daysStatus.add(2); // Afterwards or Past Day submitted
        }
      } else {
        if (currentIterDate.isBefore(today)) {
          daysStatus.add(1); // Past Day not submitted
        } else if (currentIterDate.isAfter(today)) {
          daysStatus.add(4); // Afterwards Day not submitted
        } else {
          daysStatus.add(5); // Event Day not submitted
        }
      }
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.65, // Taller items for plant + number
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: daysStatus.length,
      itemBuilder: (context, index) {
        if (daysStatus[index] == 0) {
          return const SizedBox.shrink();
        }

        final dayNumber = index - offset + 1;
        String assetPath = '';
        switch (daysStatus[index]) {
          case 1:
            assetPath =
                'assets/calender/pastday.png'; // Corrected spelling typo in mockup name
            break;
          case 2:
            assetPath = 'assets/calender/submited.png';
            break;
          case 3:
            assetPath = 'assets/calender/eventday_submited.png';
            break;
          case 4:
            assetPath = 'assets/calender/afterwardsday.png';
            break;
          case 5:
            assetPath = 'assets/calender/eventday.png';
            break;
        }

        return InkWell(
          onTap: () async {
            // Let the user edit past and today's entries, maybe optionally future ones if they pre-plan
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryScreen(
                  date: DateTime(
                    _currentMonth.year,
                    _currentMonth.month,
                    dayNumber,
                  ),
                ),
              ),
            );
            // Refresh data when returning from DiaryScreen just in case they added/deleted an entry
            _fetchEntriesForMonth(_currentMonth);
          },
          child: Column(
            children: [
              Expanded(child: Image.asset(assetPath, fit: BoxFit.contain)),
              const SizedBox(height: 4),
              Text(
                dayNumber.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(
          0xFFA1C298,
        ).withOpacity(0.5), // Slightly darker green
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Submitted Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submitted',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildLegendItem(
                'assets/calender/submited.png',
                'Afterwards &\nPast Day',
              ),
              const SizedBox(height: 10),
              _buildLegendItem(
                'assets/calender/eventday_submited.png',
                'Event Day',
              ),
            ],
          ),
          // Not Submitted Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Not Submitted',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildLegendItem('assets/calender/pastday.png', 'Past Day'),
              const SizedBox(height: 10),
              _buildLegendItem(
                'assets/calender/afterwardsday.png',
                'Afterwards Day',
              ),
              const SizedBox(height: 10),
              _buildLegendItem(
                'assets/calender/eventday.png',
                'Event Day',
              ), // Assuming this is the yellow seed icon
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String assetPath, String label) {
    return Row(
      children: [
        Image.asset(assetPath, width: 23, height: 23),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
