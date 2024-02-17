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
  Map<String, Map<int, Color?>> coloredNumbers = {};
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
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    angkaAcak = generateRandomNumbers(100);
    loadColoredNumbersFromPrefs();
  }


  Future<void> loadColoredNumbersFromPrefs() async {
    for (String angka in angkaAcak) {
      coloredNumbers[angka] = {};
      for (int i = 0; i < warna.length; i++) {
        String key = 'colored_${angka}_$i';
        if (prefs.containsKey(key)) {
          int? colorIndex = prefs.getInt(key);
          coloredNumbers[angka]![i] = warna[colorIndex ?? 0];
        } else {
          coloredNumbers[angka]![i] = null; // Handle null case
        }
      }
    }
    setState(() {}); // Update the UI after loading colored numbers
  }

  Future<void> saveColoredNumberToPrefs(String angka, int colorIndex) async {
    coloredNumbers[angka] ??= {};
    coloredNumbers[angka]![colorIndex] = warna[colorIndex];

    String key = 'colored_${angka}_$colorIndex';
    await prefs.setInt(key, colorIndex);
  }

  void checkAndShowResult() {
    bool allColored = coloredNumbers.values.every((colorMap) {
      return colorMap != null && colorMap.values.any((color) => color != null);
    });

    if (allColored) {
      String result = coloredNumbers.keys.map((angka) {
        int selectedColorIndex = coloredNumbers[angka]!.keys.firstWhere((index) =>
        coloredNumbers[angka]![index] == warna[activeColorIndex]);
        return '$angka($selectedColorIndex)';
      }).join(", ");
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
          (entry) =>
      entry.key == '3' &&
          entry.value.values.any((color) => color == Colors.green),
    );

    if (allColoredGreen) {
      score = 100;
    } else {
      for (int i = 0; i < angkaAcak.length; i++) {
        if (coloredNumbers[angkaAcak[i]]![activeColorIndex] ==
            warna[activeColorIndex]) {
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
                      isSelected: List.generate(
                        5,
                            (index) => index == activeColorIndex,
                      ),
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
                        for (int i = 0; i < warna.length; i++)
                          GestureDetector(
                            onTap: () {
                              String selectedNumber = angka;

                              int colorIndex = prefs.getInt('colored_${selectedNumber}_$i') ?? 0;

                              // Toggle warna karakter yang diklik
                              if (coloredNumbers[selectedNumber]![i] ==
                                  warna[colorIndex]) {
                                coloredNumbers[selectedNumber]![i] = null;
                                saveColoredNumberToPrefs(
                                    selectedNumber, i); // Simpan warna ke Shared Preferences
                              } else {
                                coloredNumbers[selectedNumber]![i] =
                                (selectedNumber == '3' && i == activeColorIndex)
                                    ? Colors.green
                                    : warna[activeColorIndex];
                                saveColoredNumberToPrefs(
                                    selectedNumber, activeColorIndex); // Simpan warna ke Shared Preferences
                              }

                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: coloredNumbers[angka]![i],
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
    List<String> angka = [];

    for (int i = 0; i < jumlah; i++) {
      angka.add((1 + i % 9).toString());
    }

    angka.shuffle();

    return angka;
  }

}
