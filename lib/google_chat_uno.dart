import 'package:process_run/shell.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
Future commit(String pat, String message) async {
  print("Committing: $message");
  var path = '$pat/garbage.txt';
  var content = randomGarbage();
  var shell = Shell();
  // print('echo "$content" > "$path"');
  var r = shell.runSync('sh -c "echo \'$content\' > $path"');
  // print(r.outText.toString());
  print('git add .');
  r = shell.runSync('sh -c "cd $pat && git add ."');
  // print(r.outText.toString());
  print('sh -c "cd $pat && git commit -m \'$message\'"');
  r = shell.runSync('sh -c "cd $pat && git commit -m \'$message\'"');
  // print(r.outText.toString());
  print('git push');
  shell.runSync('sh -c "cd $pat && git push"');
  print('Done');
}

String randomGarbage(){
  var bytes = utf8.encode(DateTime.now().millisecondsSinceEpoch.toString()); // data being hashed
  var digest = sha1.convert(bytes);
  print(digest.toString());
  return digest.toString();
}
