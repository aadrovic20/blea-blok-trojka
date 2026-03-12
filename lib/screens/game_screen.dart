import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Round {
  int p1Stih;
  int p1Zvanje;
  int p2Stih;
  int p2Zvanje;
  int p3Stih;
  int p3Zvanje;
  String? zvac;

  Round(
    this.p1Stih,
    this.p1Zvanje,
    this.p2Stih,
    this.p2Zvanje,
    this.p3Stih,
    this.p3Zvanje, {
    this.zvac,
  });

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

  String? zvaoIgrac;
  String? autoPlayer;

  int get trenutnaIgra =>
      bazaIgra +
      (int.tryParse(p1ZvanjeController.text) ?? 0) +
      (int.tryParse(p2ZvanjeController.text) ?? 0) +
      (int.tryParse(p3ZvanjeController.text) ?? 0);

  List<Round> rounds = [];

  final TextEditingController p1StihController = TextEditingController();
  final TextEditingController p2StihController = TextEditingController();
  final TextEditingController p3StihController = TextEditingController();
  final TextEditingController p1ZvanjeController = TextEditingController();
  final TextEditingController p2ZvanjeController = TextEditingController();
  final TextEditingController p3ZvanjeController = TextEditingController();

  int get score1 => rounds.fold(0, (sum, r) => sum + r.totalP1);
  int get score2 => rounds.fold(0, (sum, r) => sum + r.totalP2);
  int get score3 => rounds.fold(0, (sum, r) => sum + r.totalP3);

  static const Color p1Color = Colors.blue;
  static const Color p2Color = Colors.green;
  static const Color p3Color = Colors.red;

  Color _zvacColor(String? zvac) {
    if (zvac == 'p1') return p1Color;
    if (zvac == 'p2') return p2Color;
    if (zvac == 'p3') return p3Color;
    return Colors.blueAccent;
  }

  List<Color> _zvacGradient(String? zvac) {
    if (zvac == 'p1') return [const Color(0xFF1565C0), p1Color];
    if (zvac == 'p2') return [const Color(0xFF2E7D32), p2Color];
    if (zvac == 'p3') return [const Color(0xFFB71C1C), p3Color];
    return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
    p1StihController.addListener(_calculateAuto);
    p2StihController.addListener(_calculateAuto);
    p3StihController.addListener(_calculateAuto);
    p1ZvanjeController.addListener(() => setState(() {}));
    p2ZvanjeController.addListener(() => setState(() {}));
    p3ZvanjeController.addListener(() => setState(() {}));
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

  void _calculateAuto() {
    Map<String, TextEditingController> ctrls = {
      'p1': p1StihController,
      'p2': p2StihController,
      'p3': p3StihController,
    };

    List<String> filled = [];
    for (var entry in ctrls.entries) {
      String text = entry.value.text.trim();
      if (text.isNotEmpty &&
          int.tryParse(text) != null &&
          autoPlayer != entry.key) {
        filled.add(entry.key);
      }
    }

    if (filled.length == 2) {
      String auto = ['p1', 'p2', 'p3'].firstWhere((p) => !filled.contains(p));
      int sum = filled.fold(
        0,
        (s, p) => s + (int.tryParse(ctrls[p]!.text) ?? 0),
      );
      int autoVal = bazaIgra - sum;

      setState(() {
        autoPlayer = auto;
        ctrls[auto]!.text = autoVal >= 0 ? autoVal.toString() : '0';
      });
    } else if (filled.length < 2) {
      if (autoPlayer != null) {
        String prevAuto = autoPlayer!;
        setState(() => autoPlayer = null);
        if (!filled.contains(prevAuto)) {
          ctrls[prevAuto]!.clear();
        }
      }
    }
  }

  Future<void> saveRounds() async {
    final prefs = await SharedPreferences.getInstance();
    String data = rounds
        .map(
          (r) =>
              '${r.p1Stih},${r.p1Zvanje},${r.p2Stih},${r.p2Zvanje},${r.p3Stih},${r.p3Zvanje},${r.zvac ?? ''}',
        )
        .join('|');
    prefs.setString('rounds', data);
  }

  Future<void> loadRounds() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('rounds');
    if (data == null || data.isEmpty) return;

    List<Round> loaded = [];
    for (String part in data.split('|')) {
      List<String> v = part.split(',');
      if (v.length >= 6) {
        loaded.add(
          Round(
            int.tryParse(v[0]) ?? 0,
            int.tryParse(v[1]) ?? 0,
            int.tryParse(v[2]) ?? 0,
            int.tryParse(v[3]) ?? 0,
            int.tryParse(v[4]) ?? 0,
            int.tryParse(v[5]) ?? 0,
            zvac: v.length > 6 && v[6].isNotEmpty ? v[6] : null,
          ),
        );
      }
    }
    setState(() => rounds = loaded);
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
    await loadRounds();
  }

  Future<void> saveWins() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('wins1', wins1);
    prefs.setInt('wins2', wins2);
    prefs.setInt('wins3', wins3);
  }

  void _applyZvacLogika(
    int p1Stih,
    int p1Zv,
    int p2Stih,
    int p2Zv,
    int p3Stih,
    int p3Zv,
  ) {
    if (zvaoIgrac == null) {
      setState(
        () => rounds.add(Round(p1Stih, p1Zv, p2Stih, p2Zv, p3Stih, p3Zv)),
      );
      saveRounds();
      return;
    }

    double pola = trenutnaIgra / 2;
    int zvacTotal = zvaoIgrac == 'p1'
        ? p1Stih + p1Zv
        : zvaoIgrac == 'p2'
        ? p2Stih + p2Zv
        : p3Stih + p3Zv;

    bool pao = zvacTotal <= pola;

    if (pao) {
      int final1 = zvaoIgrac == 'p1' ? 0 : p1Stih + p1Zv;
      int final2 = zvaoIgrac == 'p2' ? 0 : p2Stih + p2Zv;
      int final3 = zvaoIgrac == 'p3' ? 0 : p3Stih + p3Zv;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "${zvaoIgrac == 'p1'
                      ? player1
                      : zvaoIgrac == 'p2'
                      ? player2
                      : player3} je PAO! (0 bodova)",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      setState(
        () =>
            rounds.add(Round(final1, 0, final2, 0, final3, 0, zvac: zvaoIgrac)),
      );
      saveRounds();
    } else {
      setState(
        () => rounds.add(
          Round(p1Stih, p1Zv, p2Stih, p2Zv, p3Stih, p3Zv, zvac: zvaoIgrac),
        ),
      );
      saveRounds();
    }
  }

  void addRound() {
    if (zvaoIgrac == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.record_voice_over_rounded, color: Colors.white),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Odaberite tko je zvao!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    int p1Stih = int.tryParse(p1StihController.text) ?? 0;
    int p1Zvanje = int.tryParse(p1ZvanjeController.text) ?? 0;
    int p2Stih = int.tryParse(p2StihController.text) ?? 0;
    int p2Zvanje = int.tryParse(p2ZvanjeController.text) ?? 0;
    int p3Stih = int.tryParse(p3StihController.text) ?? 0;
    int p3Zvanje = int.tryParse(p3ZvanjeController.text) ?? 0;

    int sumaStihova = p1Stih + p2Stih + p3Stih;
    if (sumaStihova != bazaIgra) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Štihovi moraju biti točno $bazaIgra (trenutno: $sumaStihova)",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    _applyZvacLogika(p1Stih, p1Zvanje, p2Stih, p2Zvanje, p3Stih, p3Zvanje);
    checkWinner();

    p1StihController.clear();
    p1ZvanjeController.clear();
    p2StihController.clear();
    p2ZvanjeController.clear();
    p3StihController.clear();
    p3ZvanjeController.clear();

    setState(() {
      zvaoIgrac = null;
      autoPlayer = null;
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
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text("Kraj igre"),
            ],
          ),
          content: Text(
            winners.length > 1
                ? "Neriješeno!\n${winners.join(' i ')} dijele pobjedu!"
                : "🏆 ${winners.first} je pobijedio!",
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() => rounds.clear());
                  saveRounds();
                  Navigator.pop(context);
                },
                child: const Text(
                  "Nova runda",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void editRound(int index) {
    final r = rounds[index];

    final e1Stih = TextEditingController(text: r.p1Stih.toString());
    final e1Zvanje = TextEditingController(text: r.p1Zvanje.toString());
    final e2Stih = TextEditingController(text: r.p2Stih.toString());
    final e2Zvanje = TextEditingController(text: r.p2Zvanje.toString());
    final e3Stih = TextEditingController(text: r.p3Stih.toString());
    final e3Zvanje = TextEditingController(text: r.p3Zvanje.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Uredi rundu ${index + 1}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _editPlayerRow(player1, p1Color, e1Stih, e1Zvanje),
              const Divider(height: 20),
              _editPlayerRow(player2, p2Color, e2Stih, e2Zvanje),
              const Divider(height: 20),
              _editPlayerRow(player3, p3Color, e3Stih, e3Zvanje),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => rounds.removeAt(index));
              saveRounds();
              Navigator.pop(context);
            },
            child: const Text("Obriši", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              setState(() {
                rounds[index] = Round(
                  int.tryParse(e1Stih.text) ?? 0,
                  int.tryParse(e1Zvanje.text) ?? 0,
                  int.tryParse(e2Stih.text) ?? 0,
                  int.tryParse(e2Zvanje.text) ?? 0,
                  int.tryParse(e3Stih.text) ?? 0,
                  int.tryParse(e3Zvanje.text) ?? 0,
                  zvac: r.zvac,
                );
              });
              saveRounds();
              Navigator.pop(context);
            },
            child: const Text("Spremi", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _editPlayerRow(
    String label,
    Color color,
    TextEditingController stihCtrl,
    TextEditingController zvanjeCtrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: stihCtrl,
                keyboardType: TextInputType.number,
                textInputAction:
                    TextInputAction.done, // ← DODAJ – tipka Done/Cancel
                onSubmitted: (_) => FocusScope.of(context).unfocus(), // ← DODAJ
                decoration: const InputDecoration(
                  labelText: "Štih",
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: zvanjeCtrl,
                keyboardType: TextInputType.number,
                textInputAction:
                    TextInputAction.done, // ← DODAJ – tipka Done/Cancel
                onSubmitted: (_) => FocusScope.of(context).unfocus(), // ← DODAJ
                decoration: const InputDecoration(
                  labelText: "Zvanje",
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void resetWins() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text("Reset pobjeda"),
          ],
        ),
        content: const Text(
          "Resetirati samo pobjede (trofeje) ili cijelu igru?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Odustani"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              setState(() {
                wins1 = 0;
                wins2 = 0;
                wins3 = 0;
              });
              saveWins();
              Navigator.pop(context);
            },
            child: const Text(
              "Samo pobjede",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                rounds.clear();
                wins1 = 0;
                wins2 = 0;
                wins3 = 0;
              });
              saveWins();
              saveRounds();
              Navigator.pop(context);
            },
            child: const Text("Sve", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _playerCard(String name, int score, int wins, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "$score",
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "🏆 $wins",
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputRow(
    String playerKey,
    String label,
    Color color,
    TextEditingController stihCtrl,
    TextEditingController zvanjeCtrl,
  ) {
    bool isAuto = autoPlayer == playerKey;
    bool isZvac = zvaoIgrac == playerKey;

    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => zvaoIgrac = isZvac ? null : playerKey),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 56,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isZvac ? color : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isZvac ? color : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: isZvac
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.record_voice_over_rounded,
                  color: isZvac ? Colors.white : Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  "Zvao",
                  style: TextStyle(
                    fontSize: 9,
                    color: isZvac ? Colors.white : Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: TextField(
            controller: stihCtrl,
            keyboardType: TextInputType.number,
            textInputAction:
                TextInputAction.done, // ← DODAJ – tipka Done/Cancel
            onSubmitted: (_) => FocusScope.of(context).unfocus(), // ← DODAJ
            readOnly: isAuto,
            style: TextStyle(
              fontSize: 18,
              color: isAuto ? Colors.grey.shade500 : color,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: isAuto ? "$label (auto)" : label,
              labelStyle: TextStyle(
                color: isAuto ? Colors.grey : color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isAuto ? Colors.grey.shade300 : color.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              filled: true,
              fillColor: isAuto
                  ? Colors.grey.shade100
                  : color.withOpacity(0.06),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        SizedBox(
          width: 90,
          child: TextField(
            controller: zvanjeCtrl,
            keyboardType: TextInputType.number,
            textInputAction:
                TextInputAction.done, // ← DODAJ – tipka Done/Cancel
            onSubmitted: (_) => FocusScope.of(context).unfocus(), // ← DODAJ
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: "Zvanje",
              labelStyle: TextStyle(
                color: color.withOpacity(0.6),
                fontSize: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: color.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              filled: true,
              fillColor: color.withOpacity(0.04),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _roundScore(int stih, int zvanje, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$stih",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (zvanje > 0)
          Text(
            "+$zvanje",
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool imaZvanja = trenutnaIgra != bazaIgra;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: AppBar(
          title: const Text(
            "Belot Blok",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: resetWins,
              tooltip: "Reset pobjeda",
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  _playerCard(player1, score1, wins1, p1Color),
                  const SizedBox(width: 8),
                  _playerCard(player2, score2, wins2, p2Color),
                  const SizedBox(width: 8),
                  _playerCard(player3, score3, wins3, p3Color),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: rounds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.style_rounded,
                              size: 56,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Nema rundi još.",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Dodajte prvu rundu!",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: rounds.length,
                        itemBuilder: (context, index) {
                          final r = rounds[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _zvacGradient(r.zvac),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _roundScore(r.p1Stih, r.p1Zvanje, p1Color),
                                  _roundScore(r.p2Stih, r.p2Zvanje, p2Color),
                                  _roundScore(r.p3Stih, r.p3Zvanje, p3Color),
                                ],
                              ),
                              onTap: () => editRound(index),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: imaZvanja ? const Color(0xFFFFFDE7) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: imaZvanja
                        ? const Color(0xFFFFCA28)
                        : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  imaZvanja
                      ? "🃏  Igra: $bazaIgra + zvanja = $trenutnaIgra"
                      : "🃏  Igra: $bazaIgra",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: imaZvanja
                        ? const Color(0xFFF57F17)
                        : Colors.grey.shade500,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

              _inputRow(
                'p1',
                player1,
                p1Color,
                p1StihController,
                p1ZvanjeController,
              ),
              const SizedBox(height: 6),
              _inputRow(
                'p2',
                player2,
                p2Color,
                p2StihController,
                p2ZvanjeController,
              ),
              const SizedBox(height: 6),
              _inputRow(
                'p3',
                player3,
                p3Color,
                p3StihController,
                p3ZvanjeController,
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: addRound,
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  label: const Text(
                    "Dodaj rundu",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
