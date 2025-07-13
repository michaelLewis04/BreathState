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
    final db = DatabaseService.instance;
    final data = await db.getData();
    setState(() {
      rows = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Breathing Records"),centerTitle: true,),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(),)
          : rows.isEmpty
              ? const Center(child: Text("No data available"))
              : RefreshIndicator(
                  onRefresh: loadData, 
                  child: ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return ListTile(
                        title: Text("Date: ${row['date']}"),
                        subtitle: Text("Rate: ${row['rate']}"),
                      );
                    },
                  ),
                ),
    );
  }
}
