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

class AngkaObject {
  final String value;
  late Map<int, Color?> coloredNumbers;

  AngkaObject(this.value);
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<AngkaObject> angkaAcak = [];
  int activeColorIndex = 0;
  late SharedPreferences prefs;

  final List<Color> warna = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.brown,
    Colors.orange,
  ];

  DateTime lastTapTime = DateTime.now();
  AngkaObject? lastTappedObject;

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
    angkaAcak = angkaAcak.map((angkaObj) {
      angkaObj.coloredNumbers = {};
      for (int i = 0; i < warna.length; i++) {
        String key = 'colored_${angkaObj.value}_$i';
        if (prefs.containsKey(key)) {
          int? colorIndex = prefs.getInt(key);
          angkaObj.coloredNumbers[i] = warna[colorIndex ?? 0];
        } else {
          angkaObj.coloredNumbers[i] = null; // Handle null case
        }
      }
      return angkaObj;
    }).toList();
    setState(() {}); // Update the UI after loading colored numbers
  }

  Future<void> saveColoredNumberToPrefs(AngkaObject angkaObj, int colorIndex) async {
    angkaObj.coloredNumbers[colorIndex] = warna[colorIndex];

    String key = 'colored_${angkaObj.value}_$colorIndex';
    await prefs.setInt(key, colorIndex);
  }

  void checkAndShowResult() {
    bool allColored = angkaAcak.every((angkaObj) {
      return angkaObj.coloredNumbers.values.any((color) => color != null);
    });

    if (allColored) {
      String result = angkaAcak.map((angkaObj) {
        int selectedColorIndex = angkaObj.coloredNumbers.keys.firstWhere(
              (index) => angkaObj.coloredNumbers[index] == warna[activeColorIndex],
        );
        return '${angkaObj.value}($selectedColorIndex)';
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

    bool allColoredGreen = angkaAcak.every(
          (angkaObj) => angkaObj.value == '3' && angkaObj.coloredNumbers[2] == Colors.green,
    );

    if (allColoredGreen) {
      score = 100; // Max score if all '3' are green
    } else {
      for (AngkaObject angkaObj in angkaAcak) {
        if (angkaObj.value != '3' && angkaObj.coloredNumbers[2] == Colors.green) {
          // Skip if it's not '3' and colored green
          continue;
        }

        if (angkaObj.coloredNumbers[activeColorIndex] == warna[activeColorIndex]) {
          score += (angkaObj.value == '3') ? 10 : int.parse(angkaObj.value);
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
                    children: angkaAcak.map((AngkaObject angkaObj) {
                      return GestureDetector(
                        onTap: () {
                          int colorIndex = prefs.getInt('colored_${angkaObj.value}_$activeColorIndex') ?? 0;

                          Duration timeBetweenTaps = DateTime.now().difference(lastTapTime);

                          if (timeBetweenTaps < Duration(milliseconds: 500) &&
                              lastTappedObject == angkaObj) {
                            angkaObj.coloredNumbers[activeColorIndex] = null;
                            saveColoredNumberToPrefs(
                              angkaObj,
                              activeColorIndex,
                            );
                          } else {
                            angkaObj.coloredNumbers[activeColorIndex] =
                            (angkaObj.value == '3' && activeColorIndex == 2)
                                ? Colors.green
                                : warna[activeColorIndex];
                            saveColoredNumberToPrefs(
                              angkaObj,
                              activeColorIndex,
                            );
                          }

                          setState(() {});
                          lastTapTime = DateTime.now();
                          lastTappedObject = angkaObj;
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: angkaObj.coloredNumbers[activeColorIndex],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            angkaObj.value,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      );
                    }).toList(),
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

  List<AngkaObject> generateRandomNumbers(int jumlah) {
    List<AngkaObject> angkaAcak = [];

    List<String> deretAngka = List.generate(10, (index) => index.toString());
    deretAngka.shuffle();

    for (int i = 0; i < jumlah; i++) {
      int index = i % deretAngka.length; // Use modulo to repeat the sequence
      AngkaObject angkaObj = AngkaObject(deretAngka[index]);
      angkaAcak.add(angkaObj);
    }

    return angkaAcak;
  }
}
