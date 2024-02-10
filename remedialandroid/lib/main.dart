import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<String> angkaAcak;
  int activeColorIndex = 0;
  Map<String, Color?> coloredNumbers = {};
  late SharedPreferences prefs;

  final List<Color> warna = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.brown,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    angkaAcak = generateRandomNumbers(100);
    loadColoredNumbersFromPrefs();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> loadColoredNumbersFromPrefs() async {
    for (String angka in angkaAcak) {
      String key = 'colored_$angka';
      if (prefs.containsKey(key)) {
        int colorIndex = prefs.getInt(key) ?? 0;
        coloredNumbers[angka] = warna[colorIndex];
      }
    }
  }

  Future<void> saveColoredNumberToPrefs(String angka, int colorIndex) async {
    // Hapus warna yang sudah ada untuk semua karakter
    coloredNumbers.clear();

    // Simpan warna yang baru
    coloredNumbers[angka] = warna[colorIndex];

    String key = 'colored_$angka';
    await prefs.setInt(key, colorIndex);
  }

  void checkAndShowResult() {
    bool allColored = coloredNumbers.values.every((color) => color != null);
    if (allColored) {
      String result = coloredNumbers.keys.join();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hasil'),
            content: Text(result),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow,
                ),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Warnai semua angka terlebih dahulu!'),
        ),
      );
    }
  }

  void showScore() {
    int score = 0;
    bool allColoredGreen = coloredNumbers.entries.every(
          (entry) => entry.key == '3' && entry.value == Colors.green,
    );

    if (allColoredGreen) {
      score = 100;
    } else {
      for (int i = 0; i < angkaAcak.length; i++) {
        if (coloredNumbers[angkaAcak[i]] == warna[activeColorIndex]) {
          score += int.parse(angkaAcak[i]);
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Skor'),
          content: Text('Skor: $score'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow,
              ),
              child: Text('OK'),
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
        title: Text('Angka Acak'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Warnai angka 3 dengan warna hijau',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleButtons(
                      direction: Axis.vertical,
                      children: [
                        Icon(Icons.circle, color: Colors.red),
                        Icon(Icons.circle, color: Colors.blue),
                        Icon(Icons.circle, color: Colors.green),
                        Icon(Icons.circle, color: Colors.brown),
                        Icon(Icons.circle, color: Colors.orange),
                      ],
                      isSelected: List.generate(5, (index) => index == activeColorIndex),
                      onPressed: (index) {
                        setState(() {
                          activeColorIndex = index;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      for (String angka in angkaAcak)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              String selectedNumber = angkaAcak[angkaAcak.indexOf(angka) % angkaAcak.length];

                              if (coloredNumbers[selectedNumber] == warna[activeColorIndex]) {
                                coloredNumbers[selectedNumber] = null;
                                saveColoredNumberToPrefs(selectedNumber, 0); // Simpan warna ke Shared Preferences
                              } else {
                                coloredNumbers[selectedNumber] = warna[activeColorIndex];
                                saveColoredNumberToPrefs(selectedNumber, activeColorIndex); // Simpan warna ke Shared Preferences
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: coloredNumbers[angka],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              angka,
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                checkAndShowResult();
                showScore();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow,
              ),
              child: Text('SELESAI', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  List<String> generateRandomNumbers(int jumlah) {
    Random random = Random();
    List<String> angka = [];

    for (int i = 0; i < jumlah; i++) {
      angka.add(random.nextInt(10).toString());
    }

    return angka;
  }
}
