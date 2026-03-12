import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoundDuo {
  int t1Stih;
  int t1Zvanje;
  int t2Stih;
  int t2Zvanje;
  String? zvac;

  RoundDuo(this.t1Stih, this.t1Zvanje, this.t2Stih, this.t2Zvanje, {this.zvac});

  int get totalT1 => t1Stih + t1Zvanje;
  int get totalT2 => t2Stih + t2Zvanje;
}

class GameScreenDuo extends StatefulWidget {
  const GameScreenDuo({super.key});

  @override
  State<GameScreenDuo> createState() => _GameScreenDuoState();
}

class _GameScreenDuoState extends State<GameScreenDuo> {
  String team1 = "Mi";
  String team2 = "Vi";

  int wins1 = 0;
  int wins2 = 0;

  int limit = 1001;
  final int bazaIgra = 162;

  String? zvaoTim;
  String? autoTeam;

  int get trenutnaIgra =>
      bazaIgra +
      (int.tryParse(t1ZvanjeController.text) ?? 0) +
      (int.tryParse(t2ZvanjeController.text) ?? 0);

  List<RoundDuo> rounds = [];

  final TextEditingController t1StihController = TextEditingController();
  final TextEditingController t2StihController = TextEditingController();
  final TextEditingController t1ZvanjeController = TextEditingController();
  final TextEditingController t2ZvanjeController = TextEditingController();

  int get score1 => rounds.fold(0, (sum, r) => sum + r.totalT1);
  int get score2 => rounds.fold(0, (sum, r) => sum + r.totalT2);

  static const Color t1Color = Colors.blue;
  static const Color t2Color = Colors.red;

  List<Color> _zvacGradient(String? zvac) {
    if (zvac == 't1') return [const Color(0xFF1565C0), t1Color];
    if (zvac == 't2') return [const Color(0xFFB71C1C), t2Color];
    return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
    t1StihController.addListener(_calculateAuto);
    t2StihController.addListener(_calculateAuto);
    t1ZvanjeController.addListener(() => setState(() {}));
    t2ZvanjeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    t1StihController.dispose();
    t2StihController.dispose();
    t1ZvanjeController.dispose();
    t2ZvanjeController.dispose();
    super.dispose();
  }

  void _calculateAuto() {
    Map<String, TextEditingController> ctrls = {
      't1': t1StihController,
      't2': t2StihController,
    };

    List<String> filled = [];
    for (var entry in ctrls.entries) {
      String text = entry.value.text.trim();
      if (text.isNotEmpty &&
          int.tryParse(text) != null &&
          autoTeam != entry.key) {
        filled.add(entry.key);
      }
    }

    if (filled.length == 1) {
      String auto = filled.first == 't1' ? 't2' : 't1';
      int val = int.tryParse(ctrls[filled.first]!.text) ?? 0;
      int autoVal = bazaIgra - val;

      setState(() {
        autoTeam = auto;
        ctrls[auto]!.text = autoVal >= 0 ? autoVal.toString() : '0';
      });
    } else if (filled.isEmpty) {
      if (autoTeam != null) {
        String prevAuto = autoTeam!;
        setState(() => autoTeam = null);
        ctrls[prevAuto]!.clear();
      }
    }
  }

  Future<void> saveRounds() async {
    final prefs = await SharedPreferences.getInstance();
    String data = rounds
        .map(
          (r) =>
              '${r.t1Stih},${r.t1Zvanje},${r.t2Stih},${r.t2Zvanje},${r.zvac ?? ''}',
        )
        .join('|');
    prefs.setString('rounds_duo', data);
  }

  Future<void> loadRounds() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('rounds_duo');
    if (data == null || data.isEmpty) return;

    List<RoundDuo> loaded = [];
    for (String part in data.split('|')) {
      List<String> v = part.split(',');
      if (v.length >= 4) {
        loaded.add(
          RoundDuo(
            int.tryParse(v[0]) ?? 0,
            int.tryParse(v[1]) ?? 0,
            int.tryParse(v[2]) ?? 0,
            int.tryParse(v[3]) ?? 0,
            zvac: v.length > 4 && v[4].isNotEmpty ? v[4] : null,
          ),
        );
      }
    }
    setState(() => rounds = loaded);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      team1 = prefs.getString('team1') ?? "Mi";
      team2 = prefs.getString('team2') ?? "Vi";
      limit = prefs.getInt('limit') ?? 1001;
      wins1 = prefs.getInt('duo_wins1') ?? 0;
      wins2 = prefs.getInt('duo_wins2') ?? 0;
    });
    await loadRounds();
  }

  Future<void> saveWins() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('duo_wins1', wins1);
    prefs.setInt('duo_wins2', wins2);
  }

  void _applyZvacLogika(int t1Stih, int t1Zv, int t2Stih, int t2Zv) {
    if (zvaoTim == null) {
      setState(() => rounds.add(RoundDuo(t1Stih, t1Zv, t2Stih, t2Zv)));
      saveRounds();
      return;
    }

    double pola = trenutnaIgra / 2;
    int zvacTotal = zvaoTim == 't1' ? t1Stih + t1Zv : t2Stih + t2Zv;
    bool pao = zvacTotal <= pola;

    if (pao) {
      int final1 = zvaoTim == 't1' ? 0 : t1Stih + t1Zv;
      int final2 = zvaoTim == 't2' ? 0 : t2Stih + t2Zv;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "${zvaoTim == 't1' ? team1 : team2} su PALI! (0 bodova)",
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

      setState(() => rounds.add(RoundDuo(final1, 0, final2, 0, zvac: zvaoTim)));
      saveRounds();
    } else {
      setState(
        () => rounds.add(RoundDuo(t1Stih, t1Zv, t2Stih, t2Zv, zvac: zvaoTim)),
      );
      saveRounds();
    }
  }

  void addRound() {
    if (zvaoTim == null) {
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

    int t1Stih = int.tryParse(t1StihController.text) ?? 0;
    int t1Zvanje = int.tryParse(t1ZvanjeController.text) ?? 0;
    int t2Stih = int.tryParse(t2StihController.text) ?? 0;
    int t2Zvanje = int.tryParse(t2ZvanjeController.text) ?? 0;

    int sumaStihova = t1Stih + t2Stih;
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

    _applyZvacLogika(t1Stih, t1Zvanje, t2Stih, t2Zvanje);
    checkWinner();

    t1StihController.clear();
    t1ZvanjeController.clear();
    t2StihController.clear();
    t2ZvanjeController.clear();

    setState(() {
      zvaoTim = null;
      autoTeam = null;
    });
  }

  void checkWinner() {
    int s1 = score1;
    int s2 = score2;

    if (s1 >= limit || s2 >= limit) {
      int maxScore = s1 > s2 ? s1 : s2;

      List<String> winners = [];
      if (s1 == maxScore) {
        wins1++;
        winners.add(team1);
      }
      if (s2 == maxScore) {
        wins2++;
        winners.add(team2);
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
                : "🏆 ${winners.first} pobjeđuju!",
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
                  "Nova igra",
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
    final e1Stih = TextEditingController(text: r.t1Stih.toString());
    final e1Zvanje = TextEditingController(text: r.t1Zvanje.toString());
    final e2Stih = TextEditingController(text: r.t2Stih.toString());
    final e2Zvanje = TextEditingController(text: r.t2Zvanje.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Uredi rundu ${index + 1}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _editTeamRow(team1, t1Color, e1Stih, e1Zvanje),
            const Divider(height: 20),
            _editTeamRow(team2, t2Color, e2Stih, e2Zvanje),
          ],
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
                rounds[index] = RoundDuo(
                  int.tryParse(e1Stih.text) ?? 0,
                  int.tryParse(e1Zvanje.text) ?? 0,
                  int.tryParse(e2Stih.text) ?? 0,
                  int.tryParse(e2Zvanje.text) ?? 0,
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

  Widget _editTeamRow(
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

  Widget _teamCard(String name, int score, int wins, Color color) {
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
                fontSize: 14,
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
                fontSize: 38,
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
    String teamKey,
    String label,
    Color color,
    TextEditingController stihCtrl,
    TextEditingController zvanjeCtrl,
  ) {
    bool isAuto = autoTeam == teamKey;
    bool isZvac = zvaoTim == teamKey;

    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => zvaoTim = isZvac ? null : teamKey),
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
            "Belot – Mi / Vi",
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
              // Tim kartice
              Row(
                children: [
                  _teamCard(team1, score1, wins1, t1Color),
                  const SizedBox(width: 12),
                  _teamCard(team2, score2, wins2, t2Color),
                ],
              ),

              const SizedBox(height: 10),

              // Lista rundi
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
                                  _roundScore(r.t1Stih, r.t1Zvanje, t1Color),
                                  _roundScore(r.t2Stih, r.t2Zvanje, t2Color),
                                ],
                              ),
                              onTap: () => editRound(index),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 8),

              // Baza igre info
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
                't1',
                team1,
                t1Color,
                t1StihController,
                t1ZvanjeController,
              ),
              const SizedBox(height: 6),
              _inputRow(
                't2',
                team2,
                t2Color,
                t2StihController,
                t2ZvanjeController,
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
