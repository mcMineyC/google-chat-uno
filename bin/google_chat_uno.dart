import 'package:google_chat_uno/google_chat_uno.dart' as lib;

import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  while (true) {
    String? input = stdin.readLineSync(encoding: utf8);
    print("Hejo ${input}");
    bool yn = stdin.readLineSync(encoding: utf8) == "y";
    if (yn && input != null) {
      lib.commit("gchat-uno-p1", input);
    }
  }
}
