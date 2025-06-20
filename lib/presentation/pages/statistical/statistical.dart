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
  double readingPercent = 0;
  double listeningPercent = 0;
  double writingPercent = 0;
  int readingCount = 0;
  int listeningCount = 0;
  int writingCount = 0;
  int readingTime = 0;
  int listeningTime = 0;
  int writingTime = 0;
  Map<String, Map<String, int>> testCountsByDate = {};

  Future<void> fetchStatistics({DateTime? startDate, DateTime? endDate}) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final userId = user.id;
    final now = DateTime.now();
    final defaultStart = DateTime(now.year, now.month - 1, now.day);

    // reset counters
    setState(() {
      readingCount = listeningCount = writingCount = 0;
      readingTime = listeningTime = writingTime = 0;
      testCountsByDate.clear();
    });

    try {
      // 1) Lấy dữ liệu, select join sang tests để có test_type
      final data = await supabase
          .from('test_results')
          .select('completed_at, time, tests(test_type)')
          .eq('user_id', userId)
          .gte('completed_at', (startDate ?? defaultStart).toIso8601String())
          .lte('completed_at', (endDate ?? now).toIso8601String())
          .order('completed_at', ascending: true);

      // 2) data là List<dynamic>
      final List records = data as List;

      // 3) Tally counts, times, map theo ngày
      for (var item in records) {
        final date = (item['completed_at'] as String).split('T').first;
        final t = item['time'] as int;
        final type = (item['tests']?['test_type'] ?? '') as String;

        switch (type) {
          case 'reading':
            readingCount++; readingTime += t;
            break;
          case 'listening':
            listeningCount++; listeningTime += t;
            break;
          case 'writing':
            writingCount++; writingTime += t;
            break;
        }

        testCountsByDate.putIfAbsent(date, () => {
          'reading': 0,
          'listening': 0,
          'writing': 0,
        });
        testCountsByDate[date]![type] = (testCountsByDate[date]![type] ?? 0) + 1;
      }

      // 4) Tính tổng và phần trăm, cập nhật state
      final total = readingCount + listeningCount + writingCount;
      final sumTime = records.fold<int>(0, (s, e) => s + (e['time'] as int));

      setState(() {
        totalTests = total;
        totalTime = sumTime;
        readingPercent = total > 0 ? readingCount / total * 100 : 0;
        listeningPercent = total > 0 ? listeningCount / total * 100 : 0;
        writingPercent = total > 0 ? writingCount / total * 100 : 0;
      });
    } catch (e) {
      print('Lỗi khi lấy dữ liệu: $e');
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
                    value: readingPercent,
                    color: const Color(0xFF4681DA).withOpacity(0.7),
                    title: '${readingPercent.toStringAsFixed(1)}%',
                    radius: 50),
                PieChartSectionData(
                    value: listeningPercent,
                    color: const Color(0xFF4681DA),
                    title: '${listeningPercent.toStringAsFixed(1)}%',
                    radius: 50),
                PieChartSectionData(
                    value: writingPercent,
                    color: Colors.red,
                    title: '${writingPercent.toStringAsFixed(1)}%',
                    radius: 50),
              ],
            ),
          ),
        ),
        const SizedBox(width: 50),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legend(
                const Color(0xFF4681DA).withOpacity(0.7),
                "Reading",
                "$readingCount tests",
                "${readingTime ~/ 60}h ${readingTime % 60}m"),
            const SizedBox(height: 20),
            _legend(
                const Color(0xFF4681DA),
                "Listening",
                "$listeningCount tests",
                "${listeningTime ~/ 60}h ${listeningTime % 60}m"),
            const SizedBox(height: 20),
            _legend(Colors.red, "Writing", "$writingCount tests",
                "${writingTime ~/ 60}h ${writingTime % 60}m"),
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
    List<BarChartGroupData> barGroups = [];
    List<String> dates = testCountsByDate.keys.toList()..sort();

    for (int i = 0; i < dates.length; i++) {
      String date = dates[i];
      int count = testCountsByDate[date]?[title.toLowerCase()] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: count.toDouble(), color: Colors.blue)],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value % 1 == 0) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      }
                      return Container();
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < dates.length) {
                        return Transform.rotate(
                          angle: -0.5, // Góc xoay của nhãn trục X
                          child: Text(dates[index],
                              style: const TextStyle(fontSize: 10)),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Colors.black, width: 1),
                  bottom: BorderSide(color: Colors.black, width: 1),
                  right: BorderSide(color: Colors.transparent),
                  top: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
