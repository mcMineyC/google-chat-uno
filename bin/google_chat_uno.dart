import 'package:google_chat_uno/google_chat_uno.dart' as lib;

import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  List<lib.UnoCard> pile = [];
  List<lib.UnoCard> deck = lib.createDeck();
  deck = lib.shuffleDeck(deck);

  int playingIndex = 1;
  bool clockwise = true;

  print("How many players? ");
  String? playersInput = stdin.readLineSync(encoding: utf8);
  int playerCount = int.parse(playersInput!);
  List<lib.Player> players = lib.createPlayers(playerCount);

  List<Future> futures = [];
  for (lib.Player player in players) {
    player.deal(deck);
  }
  await Future.wait(futures);

  pile.add(deck.removeLast());
  print("The top card is ${pile.last}");
  await lib.notifyPlayers(players, pile);

  print("Enter your commands, q to quit");
  print("Commands are in the form 'player_num action color number', e.g. '1 play Yellow 6'");
  while (true) {
    print("Player $playingIndex is playing");
    String? input = stdin.readLineSync(encoding: utf8);
    if (input == "q") {
      for (lib.Player player in players) {
        await lib.sendMsgToPlayer(player.id, "Thanks for playing, bye!");
      }
      break;
    }
    try {
      List<String> parts = input!.split(" ");
      // int playerNum = int.parse(parts[0]);
      int playerNum = playingIndex;
      String action = parts[0];
      if(action == "play") {
        String color = parts[1];
        String number = "";
        if(color != "Wild") {number = parts[2];}
        else if(parts.length == 3) {number = parts[2];}
        else {number = "";}
        // print("Parsed parts");
        lib.UnoCard cardToPlay = lib.UnoCard(color, number);
        if(players[playerNum-1].canPlay(cardToPlay)) {
          if(cardToPlay.value == "Reverse") clockwise = !clockwise;
          print("About to play card");
          if(players[playerNum-1].hand.length == 0) {
            for(lib.Player player in players) {
              await lib.sendMsgToPlayer(player.id, "P${playerNum} wins!!!");
            }
            break;
          }
          players[playerNum-1].play(cardToPlay, pile, players, lib.nextIndex(playerNum, playerCount, clockwise), deck);
          if(cardToPlay.value == "Skip" || cardToPlay.value == "+2" || cardToPlay.value == "+4") playerNum++;
          print("Player $playerNum played ${cardToPlay.toString()}");
        }else {
          print("Can't play that card, not in hand.");
          continue;
        }
      }else if(action == "draw") {
        players[playerNum-1].draw(deck, pile);
      }else if(action == "uno") {
        players[playerNum-1].uno(deck, pile);
      }else if(action == "test"){
        print("Sending test message");
        futures.clear();
        for (lib.Player player in players) {
          futures.add(lib.sendMsgToPlayer(player.id, "test<br>two line message maybe?"));
        }
        await Future.wait(futures);
        print("Sent test message");
      }
      // print("About to notify players");
      await lib.notifyPlayers(players, pile);
      // print("Notified players");
    }catch(e) {
      print("Invalid input: $input\t\nor other error: $e");
    }
    if (deck.isEmpty) {
      for(int i = 0; i < pile.length; i++) {
        deck.add(pile.removeAt(i));
      }
      print("Deck is empty, reshuffling");
      deck = lib.shuffleDeck(deck);
    }
    print("Pile: ${pile} cards");
    playingIndex = lib.nextIndex(playingIndex, playerCount, clockwise); 
  }
}
