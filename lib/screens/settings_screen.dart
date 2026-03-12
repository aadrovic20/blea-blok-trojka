import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController player1 = TextEditingController();
  final TextEditingController player2 = TextEditingController();
  final TextEditingController player3 = TextEditingController();

  int limit = 1001;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      player1.text = prefs.getString('player1') ?? "";
      player2.text = prefs.getString('player2') ?? "";
      player3.text = prefs.getString('player3') ?? "";
      limit = prefs.getInt('limit') ?? 1001;
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('player1', player1.text);
    await prefs.setString('player2', player2.text);
    await prefs.setString('player3', player3.text);
    await prefs.setInt('limit', limit);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Postavke spremljene")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Postavke")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: player1,
              decoration: const InputDecoration(labelText: "Igrač 1"),
            ),

            TextField(
              controller: player2,
              decoration: const InputDecoration(labelText: "Igrač 2"),
            ),

            TextField(
              controller: player3,
              decoration: const InputDecoration(labelText: "Igrač 3"),
            ),

            const SizedBox(height: 20),

            const Text("Cilj igre"),

            RadioListTile(
              title: const Text("501"),
              value: 501,
              groupValue: limit,
              onChanged: (value) {
                setState(() => limit = value!);
              },
            ),

            RadioListTile(
              title: const Text("701"),
              value: 701,
              groupValue: limit,
              onChanged: (value) {
                setState(() => limit = value!);
              },
            ),

            RadioListTile(
              title: const Text("1001"),
              value: 1001,
              groupValue: limit,
              onChanged: (value) {
                setState(() => limit = value!);
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveSettings,
              child: const Text("Spremi postavke"),
            ),
          ],
        ),
      ),
    );
  }
}
