import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Round {
  int p1Stih;
  int p1Zvanje;
  int p2Stih;
  int p2Zvanje;
  int p3Stih;
  int p3Zvanje;

  Round(
    this.p1Stih,
    this.p1Zvanje,
    this.p2Stih,
    this.p2Zvanje,
    this.p3Stih,
    this.p3Zvanje,
  );

  // Ukupni bodovi po igraču (štih + zvanje)
  int get totalP1 => p1Stih + p1Zvanje;
  int get totalP2 => p2Stih + p2Zvanje;
  int get totalP3 => p3Stih + p3Zvanje;
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
  final int bazaIgra = 162;

  List<Round> rounds = [];

  // Controlleri za štihove
  final TextEditingController p1StihController = TextEditingController();
  final TextEditingController p2StihController = TextEditingController();
  final TextEditingController p3StihController = TextEditingController();

  // Controlleri za zvanja
  final TextEditingController p1ZvanjeController = TextEditingController();
  final TextEditingController p2ZvanjeController = TextEditingController();
  final TextEditingController p3ZvanjeController = TextEditingController();

  // Ukupni bodovi po igraču
  int get score1 => rounds.fold(0, (sum, r) => sum + r.totalP1);
  int get score2 => rounds.fold(0, (sum, r) => sum + r.totalP2);
  int get score3 => rounds.fold(0, (sum, r) => sum + r.totalP3);

  @override
  void initState() {
    super.initState();
    loadSettings();

    // Listener za automatski izračun p3 štihova
    p1StihController.addListener(updateP3Auto);
    p2StihController.addListener(updateP3Auto);
  }

  @override
  void dispose() {
    p1StihController.dispose();
    p2StihController.dispose();
    p3StihController.dispose();
    p1ZvanjeController.dispose();
    p2ZvanjeController.dispose();
    p3ZvanjeController.dispose();
    super.dispose();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      player1 = prefs.getString('player1') ?? "Igrač 1";
      player2 = prefs.getString('player2') ?? "Igrač 2";
      player3 = prefs.getString('player3') ?? "Igrač 3";
      limit = prefs.getInt('limit') ?? 1001;
      wins1 = prefs.getInt('wins1') ?? 0;
      wins2 = prefs.getInt('wins2') ?? 0;
      wins3 = prefs.getInt('wins3') ?? 0;
    });
  }

  Future<void> saveWins() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('wins1', wins1);
    prefs.setInt('wins2', wins2);
    prefs.setInt('wins3', wins3);
  }

  // Automatski izračunaj p3 štihove (bazaIgra - p1 - p2)
  void updateP3Auto() {
    int p1 = int.tryParse(p1StihController.text) ?? 0;
    int p2 = int.tryParse(p2StihController.text) ?? 0;
    int p3Auto = bazaIgra - p1 - p2;

    setState(() {
      p3StihController.text = p3Auto >= 0 ? p3Auto.toString() : '0';
    });
  }

  void checkWinner() {
    int s1 = score1;
    int s2 = score2;
    int s3 = score3;

    if (s1 >= limit || s2 >= limit || s3 >= limit) {
      int maxScore = [s1, s2, s3].reduce((a, b) => a > b ? a : b);

      List<String> winners = [];
      if (s1 == maxScore) {
        wins1++;
        winners.add(player1);
      }
      if (s2 == maxScore) {
        wins2++;
        winners.add(player2);
      }
      if (s3 == maxScore) {
        wins3++;
        winners.add(player3);
      }

      saveWins();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Kraj runde"),
            content: Text(
              winners.length > 1
                  ? "Neriješeno! Pobjednici: ${winners.join(', ')}"
                  : "${winners.first} je pobijedio!",
            ),
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

  void addRound() {
    int p1Stih = int.tryParse(p1StihController.text) ?? 0;
    int p1Zvanje = int.tryParse(p1ZvanjeController.text) ?? 0;
    int p2Stih = int.tryParse(p2StihController.text) ?? 0;
    int p2Zvanje = int.tryParse(p2ZvanjeController.text) ?? 0;
    int p3Stih = int.tryParse(p3StihController.text) ?? 0;
    int p3Zvanje = int.tryParse(p3ZvanjeController.text) ?? 0;

    setState(() {
      rounds.add(Round(p1Stih, p1Zvanje, p2Stih, p2Zvanje, p3Stih, p3Zvanje));
    });

    checkWinner();

    // Clear sva polja
    p1StihController.clear();
    p1ZvanjeController.clear();
    p2StihController.clear();
    p2ZvanjeController.clear();
    p3StihController.clear();
    p3ZvanjeController.clear();
  }

  void editRound(int index) {
    final r = rounds[index];

    TextEditingController e1Stih = TextEditingController(
      text: r.p1Stih.toString(),
    );
    TextEditingController e1Zvanje = TextEditingController(
      text: r.p1Zvanje.toString(),
    );
    TextEditingController e2Stih = TextEditingController(
      text: r.p2Stih.toString(),
    );
    TextEditingController e2Zvanje = TextEditingController(
      text: r.p2Zvanje.toString(),
    );
    TextEditingController e3Stih = TextEditingController(
      text: r.p3Stih.toString(),
    );
    TextEditingController e3Zvanje = TextEditingController(
      text: r.p3Zvanje.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Uredi rundu"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: e1Stih,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "$player1 štih"),
                ),
                TextField(
                  controller: e1Zvanje,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "$player1 zvanje"),
                ),
                const Divider(),
                TextField(
                  controller: e2Stih,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "$player2 štih"),
                ),
                TextField(
                  controller: e2Zvanje,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "$player2 zvanje"),
                ),
                const Divider(),
                TextField(
                  controller: e3Stih,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "$player3 štih"),
                ),
                TextField(
                  controller: e3Zvanje,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "$player3 zvanje"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  rounds[index] = Round(
                    int.tryParse(e1Stih.text) ?? 0,
                    int.tryParse(e1Zvanje.text) ?? 0,
                    int.tryParse(e2Stih.text) ?? 0,
                    int.tryParse(e2Zvanje.text) ?? 0,
                    int.tryParse(e3Stih.text) ?? 0,
                    int.tryParse(e3Zvanje.text) ?? 0,
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

  void resetWins() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset pobjeda"),
          content: const Text(
            "Jeste li sigurni da želite resetirati sve pobjede?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Odustani"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  wins1 = 0;
                  wins2 = 0;
                  wins3 = 0;
                });
                saveWins();
                Navigator.pop(context);
              },
              child: const Text("Reset", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Belot Blok"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetWins,
            tooltip: "Reset pobjeda",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Prikaz rezultata igrača
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            player1,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$score1",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "🏆 $wins1",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            player2,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$score2",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            "🏆 $wins2",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            player3,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$score3",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "🏆 $wins3",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Lista rundi
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "${r.p1Stih}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  if (r.p1Zvanje > 0)
                                    Text(
                                      "+${r.p1Zvanje}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "${r.p2Stih}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                                  if (r.p2Zvanje > 0)
                                    Text(
                                      "+${r.p2Zvanje}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "${r.p3Stih}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                  if (r.p3Zvanje > 0)
                                    Text(
                                      "+${r.p3Zvanje}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Ukupno: ${r.totalP1 + r.totalP2 + r.totalP3} bodova",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
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

            // Input polja za novu rundu
            Text(
              "Nova igra (baza: $bazaIgra)",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Igrač 1
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: p1StihController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "$player1 štih",
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: p1ZvanjeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Zvanje",
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Igrač 2
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: p2StihController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "$player2 štih",
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.green[50],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: p2ZvanjeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Zvanje",
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.green[50],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Igrač 3 (auto štih)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: p3StihController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "$player3 štih (auto)",
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.red[50],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: p3ZvanjeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Zvanje",
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.red[50],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: addRound,
                child: const Text(
                  "Dodaj rundu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
