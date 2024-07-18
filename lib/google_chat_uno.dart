import 'package:process_run/shell.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
Future commit(String message) async {
  print("Committing: $message");
  var path = 'garbage.txt';
  var content = randomGarbage();
  print("Garbage: $content");
  var file = File(path).openWrite(mode: FileMode.write);
  file.write(content);
  print("File: $file");
  print("Wrote junk");
  var shell = Shell();
  print('git add .\noutput:');
  print(shell.runSync('git add .').outText);
  print('git commit -m "$message"\noutput:');
  print(shell.runSync('git commit -m "$message"').outText);
  print('git push\noutput:');
  print(shell.runSync('git push').outText);
}

Future writeGarbage() async {
  var path = 'garbage.txt';
  var content = randomGarbage();
  var file = File(path);
  await file.writeAsString(content);
}

String randomGarbage(){
  var bytes = utf8.encode(DateTime.now().millisecondsSinceEpoch.toString()); // data being hashed
  var digest = sha1.convert(bytes);
  print(digest.toString());
  return digest.toString();
}
