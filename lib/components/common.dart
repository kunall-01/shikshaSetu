import 'package:flutter/material.dart';
import 'dart:core';

const String blue = "#38bcd0";
const String lightblue = "#93dae5";
const String green = "#248454";
const String darkpink = "#a45c64";
const String skin = "#dcc4c4";
const String deepseablue = "#2f474e";
const String red = "#FF0000";
const String white = "#FFFFFF";
const String lightblack = "#313638";
const String darkskin = "#957373";
const String parentthemecolor = lightblack;

Color color(String color) {
  return Color(int.parse('0xFF${color.replaceFirst('#', '')}'));
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Loading..."),
            ],
          ),
        ),
      );
    },
  );
}

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: CircularProgressIndicator(
            color: color(blue),
          ),
        ),
      );
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  // ignore: avoid_function_literals_in_foreach_calls
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

String capitalizeEachWord(String text) {
  return text.split(' ').map((word) {
    return word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '';
  }).join(' ');
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1);
}

Map<String, String>? extractmethod(String input) {
  RegExp regExp = RegExp(r'(std\d+)\s*/\s*(\S+)');
  Match? match = regExp.firstMatch(input);

  if (match != null) {
    String stdId = match.group(1)!;
    String subjectCode = match.group(2)!.replaceAll(")", "");

    return {'stdId': stdId, 'subjectCode': subjectCode};
  } else {
    return null;
  }
}
