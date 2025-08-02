import 'package:breath_state/constants/db_constants.dart';
import 'package:breath_state/services/db_service/database_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

//TODO Add option for user to delete some data (incase noisy data)

class _HomeScreenState extends State<HomeScreen> {
  List<Map> rows = [];
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

    final combined = [
      ...breathData.map((e) => {...e, 'type': 'breath'}),
      ...heartData.map((e) => {...e, 'type': 'heart'}),
    ];

    setState(() {
      rows = combined;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Breathing Records"), centerTitle: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : rows.isEmpty
              ? const Center(child: Text("No data available"))
              : RefreshIndicator(
                onRefresh: loadData,
                child: ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    final type =
                        row['type'] == 'heart'
                            ? 'Heart Rate'
                            : 'Breathing Rate';
                    return ListTile(
                      title: Text("$type - Date: ${row['date']}"),
                      subtitle: Text("Rate: ${row['rate']}"),
                    );
                  },
                ),
              ),
    );
  }
}
