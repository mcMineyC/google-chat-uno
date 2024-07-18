import 'package:process_run/shell.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
Future commit(String pat, String message) async {
  print("Committing: $message");
  var path = '$pat/garbage.txt';
  var content = randomGarbage();
  var file = File(path).openWrite(mode: FileMode.write);
  file.write(content);
  var shell = Shell();
  print('git add .');
  shell.runSync('git add .');
  print('git commit -m "$message"');
  shell.runSync('git commit -m "$message"');
  print('git push');
  shell.runSync('git push');
  print('Done');
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
