import 'package:breath_state/constants/db_constants.dart';
import 'package:breath_state/services/db_service/database_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// TODO Add option for user to delete some data (incase noisy data)
class _HomeScreenState extends State<HomeScreen> {
  List<Map> breathRows = [];
  List<Map> heartRows = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final dbService = DatabaseService.instance;
    final breathData = await dbService.getData(BREATH_TABLE_NAME);
    final heartData = await dbService.getData(HEART_TABLE_NAME);

    setState(() {
      breathRows = breathData;
      heartRows = heartData;
      isLoading = false;
    });
  }

  List<FlSpot> _mapToSpots(List<Map> rows) {
    return rows.asMap().entries.map((entry) {
      final i = entry.key.toDouble();
      final rate = double.tryParse(entry.value['rate'].toString()) ?? 0.0;
      return FlSpot(i, rate);
    }).toList();
  }

  Widget _buildLineChart(List<Map> rows, String title, Color color) {
    final spots = _mapToSpots(rows);

    if (spots.isEmpty) {
      return Center(
        child: Text(
          "No $title data available",
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    final int n = rows.length;

    final int labelCount = n < 6 ? n : 6;
    final Set<int> labelIndices = {};
    if (n == 1) {
      labelIndices.add(0);
    } else {
      for (int i = 0; i < labelCount; i++) {
        int idx = ((i * (n - 1)) / (labelCount - 1)).floor();
        labelIndices.add(idx);
      }
      labelIndices.add(n - 1);
    }

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.black,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.15),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget:
                            (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (!labelIndices.contains(idx) ||
                              idx < 0 ||
                              idx >= rows.length) {
                            return const SizedBox();
                          }

                          EdgeInsets padding = EdgeInsets.zero;
                          if (idx == 0) {
                            padding = const EdgeInsets.only(left: 48);
                          } else if (idx == rows.length - 1) {
                            padding = const EdgeInsets.only(right: 48);
                          }

                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 12,
                            child: Padding(
                              padding: padding,
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  rows[idx]['date'].toString().split(" ").first,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.white10, strokeWidth: 1),
                    getDrawingVerticalLine:
                        (value) =>
                            FlLine(color: Colors.white10, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  minX: 0,
                  maxX: (n - 1).toDouble(),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Breathing Records"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : Column(
                children: [
                  Expanded(
                    child: _buildLineChart(
                      breathRows,
                      "Breathing Rate",
                      Colors.blueAccent,
                    ),
                  ),
                  Expanded(
                    child: _buildLineChart(
                      heartRows,
                      "Heart Rate",
                      Colors.redAccent,
                    ),
                  ),
                ],
              ),
    );
  }
}
