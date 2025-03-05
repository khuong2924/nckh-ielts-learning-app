import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../components/BottomNavBar.dart';
import '../../components/CustomAppBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Statistical extends StatefulWidget {
  const Statistical({super.key});

  @override
  State<Statistical> createState() => _StatisticalState();
}

class _StatisticalState extends State<Statistical> {
  int _currentIndex = 0;
  DateTime? _beginDate;
  DateTime? _endDate;
  final supabase = Supabase.instance.client;
  int totalTests = 0;
  int totalTime = 0;

  Future<void> fetchStatistics({DateTime? startDate, DateTime? endDate}) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('User not logged in');
        return;
      }
      final userId = user.id; // Lấy ID của người đăng nhập

      final now = DateTime.now();
      final defaultStartDate = DateTime(now.year, now.month - 1, now.day);

      final response = await supabase
          .from('test_results')
          .select('completed_at, time')
          .eq('user_id', userId) // Chỉ lấy dữ liệu của user đang đăng nhập
          .gte(
              'completed_at', (startDate ?? defaultStartDate).toIso8601String())
          .lte('completed_at', (endDate ?? now).toIso8601String());

      if (response.isNotEmpty) {
        setState(() {
          totalTests = response.length;
          totalTime =
              response.fold(0, (sum, item) => sum + (item['time'] as int));
        });
      }
    } catch (error) {
      print('Lỗi khi lấy dữ liệu: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _beginDate = DateTime(now.year, now.month - 1, now.day);
    _endDate = now;
    fetchStatistics(startDate: _beginDate, endDate: _endDate);
  }

  Future<void> _selectDate(BuildContext context, bool isBegin) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isBegin) {
          _beginDate = picked;
        } else {
          _endDate = picked;
        }
        fetchStatistics(startDate: _beginDate, endDate: _endDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFEBFF),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onNotificationTap: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Statistical",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _datePickerField("Begin", _beginDate, true),
                          const SizedBox(width: 10),
                          _datePickerField("End", _endDate, false),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoCard("Total Number Tests", "$totalTests Tests"),
                          const SizedBox(width: 10),
                          _infoCard("Total Study Time", "$totalTime minutes"),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _pieChart(),
                      const SizedBox(height: 30),
                      _barChart("Reading"),
                      const SizedBox(height: 10),
                      _barChart("Listening"),
                      const SizedBox(height: 10),
                      _barChart("Writing"),
                    ],
                  ),
                ),
              ),
            ),
            BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePickerField(String label, DateTime? selectedDate, bool isBegin) {
    return Expanded(
      child: InkWell(
        onTap: () => _selectDate(context, isBegin),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          child: Text(
            selectedDate != null
                ? "${selectedDate.toLocal()}".split(' ')[0]
                : "Select Date",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pieChart() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                    value: 33,
                    color: Color(0xFF4681DA).withOpacity(0.7),
                    radius: 50),
                PieChartSectionData(value: 33, color: Colors.red, radius: 50),
                PieChartSectionData(
                    value: 34, color: Color(0xFF4681DA), radius: 50),
              ],
            ),
          ),
        ),
        const SizedBox(width: 50),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legend(Color(0xFF4681DA).withOpacity(0.7), "Reading", "10 tests",
                "10h 15m"),
            const SizedBox(height: 20),
            _legend(Color(0xFF4681DA), "Listening", "10 tests", "10h"),
            const SizedBox(height: 20),
            _legend(Colors.red, "Writing", "10 tests", "10h"),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color color, String title, String tests, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          CircleAvatar(radius: 6, backgroundColor: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Icon(Icons.library_books, size: 14, color: Colors.red),
                  Text(tests),
                  const SizedBox(width: 5),
                  const Icon(Icons.access_time, size: 14, color: Colors.red),
                  Text(time),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barChart(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: List.generate(
                  10,
                  (index) => BarChartGroupData(x: index, barRods: [
                        BarChartRodData(
                            toY: (index % 5 + 3).toDouble(), color: Colors.blue)
                      ])),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: true),
            ),
          ),
        ),
      ],
    );
  }
}
