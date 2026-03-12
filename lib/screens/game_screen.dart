import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Round {
  int p1;
  int p2;
  int p3;

  Round(this.p1, this.p2, this.p3);
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String player1 = "Igrač 1";
  String player2 = "Igrač 2";
  String player3 = "Igrač 3";

  int wins1 = 0;
  int wins2 = 0;
  int wins3 = 0;

  int limit = 1001;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      player1 = prefs.getString('player1') ?? "Igrač 1";
      player2 = prefs.getString('player2') ?? "Igrač 2";
      player3 = prefs.getString('player3') ?? "Igrač 3";
      limit = prefs.getInt('limit') ?? 1001;
    });
  }

  void checkWinner() {
    int s1 = score1;
    int s2 = score2;
    int s3 = score3;

    if (s1 >= limit || s2 >= limit || s3 >= limit) {
      int maxScore = [s1, s2, s3].reduce((a, b) => a > b ? a : b);

      String winner = "";

      if (s1 == maxScore) {
        wins1++;
        winner = player1;
      }

      if (s2 == maxScore) {
        wins2++;
        winner = player2;
      }

      if (s3 == maxScore) {
        wins3++;
        winner = player3;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Kraj runde"),
            content: Text("$winner je pobijedio!"),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    rounds.clear();
                  });

                  Navigator.pop(context);
                },
                child: const Text("Nova runda"),
              ),
            ],
          );
        },
      );
    }
  }

  List<Round> rounds = [];

  final TextEditingController p1Controller = TextEditingController();
  final TextEditingController p2Controller = TextEditingController();
  final TextEditingController p3Controller = TextEditingController();

  int get score1 => rounds.fold(0, (sum, r) => sum + r.p1);
  int get score2 => rounds.fold(0, (sum, r) => sum + r.p2);
  int get score3 => rounds.fold(0, (sum, r) => sum + r.p3);

  void addRound() {
    int p1 = int.tryParse(p1Controller.text) ?? 0;
    int p2 = int.tryParse(p2Controller.text) ?? 0;
    int p3 = int.tryParse(p3Controller.text) ?? 0;

    setState(() {
      rounds.add(Round(p1, p2, p3));
    });

    checkWinner();

    p1Controller.clear();
    p2Controller.clear();
    p3Controller.clear();
  }

  void editRound(int index) {
    final r = rounds[index];

    TextEditingController e1 = TextEditingController(text: r.p1.toString());
    TextEditingController e2 = TextEditingController(text: r.p2.toString());
    TextEditingController e3 = TextEditingController(text: r.p3.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Uredi rundu"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: e1,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Igrač 1"),
              ),

              TextField(
                controller: e2,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Igrač 2"),
              ),

              TextField(
                controller: e3,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Igrač 3"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  rounds[index] = Round(
                    int.tryParse(e1.text) ?? 0,
                    int.tryParse(e2.text) ?? 0,
                    int.tryParse(e3.text) ?? 0,
                  );
                });

                Navigator.pop(context);
              },
              child: const Text("Spremi"),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  rounds.removeAt(index);
                });

                Navigator.pop(context);
              },
              child: const Text("Obriši"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Igra")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(player1, style: const TextStyle(fontSize: 18)),
                          Text(
                            "$score1",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "Pobjede: $wins1",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4), // mali razmak
                Expanded(
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(player2, style: const TextStyle(fontSize: 18)),
                          Text(
                            "$score2",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            "Pobjede: $wins2",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4), // mali razmak
                Expanded(
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(player3, style: const TextStyle(fontSize: 18)),
                          Text(
                            "$score3",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "Pobjede: $wins3",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: rounds.length,
                itemBuilder: (context, index) {
                  final r = rounds[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        "Runda ${index + 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "${r.p1}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "${r.p2}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            "${r.p3}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => editRound(index),
                    ),
                  );
                },
              ),
            ),
            const Divider(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                controller: p1Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: player1,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: const TextStyle(fontSize: 20),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                controller: p2Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: player2,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: const TextStyle(fontSize: 20),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                controller: p3Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: player3,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: const TextStyle(fontSize: 20),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: addRound,
                child: const Text(
                  "Dodaj rundu",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
