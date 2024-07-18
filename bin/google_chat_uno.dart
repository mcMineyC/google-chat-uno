import 'package:google_chat_uno/google_chat_uno.dart' as google_chat_uno;

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  var app = Router();

  app.get('/hello', (Request request) {
    return Response.ok('hello-world');
  });

  app.get('/url/<id>', (Request request, String id) async {
    return Response.ok(id.toString());
  });
  var handler = const Pipeline()
    .addMiddleware(logRequests())
    .addMiddleware(corsHeaders(originChecker: (origin) {
      if(origin.contains('localhost')) return true;
      else if(origin.contains('eatthecow.mooo.com')) return true;
      else if(origin.contains('taxi-native.vercel.app')) return true;
      else return false;
    }))
    .addHandler(app);
  var server = await io.serve(handler, '0.0.0.0', 8080);
  print("Server running at http://${server.address.host}:${server.port}");
}
