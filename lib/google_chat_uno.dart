import 'package:process_run/shell.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

Future sendMsgToPlayer(int id, String message) async {
  await commit('./gchat-uno-p$id', message);
}

Future commit(String pat, String message) async {
  // print("Committing: $message");
  var path = 'garbage.txt';
  var content = randomGarbage();
  var shell = Shell(workingDirectory: pat);
  await shell.run('sh -c "echo \'$content\' > $path"');
  await shell.run('git add .');
  await shell.run('git commit -m \'$message\'');
  await shell.run('git push');
  print("Sent?");
}

String randomGarbage(){
  var bytes = utf8.encode(DateTime.now().millisecondsSinceEpoch.toString()); // data being hashed
  var digest = sha1.convert(bytes);
  // print(digest.toString());
  return digest.toString();
}

const colors = ['Red', 'Green', 'Blue', 'Yellow'];
const values = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'Skip', 'Reverse', '+2'];

// Class representing an Uno card
class UnoCard {
  String color;
  String value;

  UnoCard(this.color, this.value);

  @override
  String toString() {
    return '$color $value';
  }
}

class Player {
  int id;
  List<UnoCard> hand;

  Player(this.id, this.hand);
  
  void deal(List<UnoCard> deck) {
    hand = dealCards(deck);
  }

  void play(UnoCard card, List<UnoCard> pile, List<Player> players, int nextIndex, List<UnoCard> deck) {
    var index = 0;
    for (int i = 0; i < hand.length; i++) {
      UnoCard c = hand[i];
      if (c.color == card.color && c.value == card.value) {
        index = i;
      }
    }
    print("Removing card $index");
    var cardToPlay = hand.removeAt(index);
    print("Card removed");
    int nindex = nextIndex-1;
    switch(cardToPlay.value) {
      case '+4':
        for (int i = 0; i < 4; i++) {
          players[nindex].draw(deck, pile);
        }
        break;
      case '+2':
        for (int i = 0; i < 2; i++) {
          players[nindex].draw(deck, pile);
        }
        break;
    }
    pile.add(cardToPlay);
    print("Added card to pile");
  }

  bool canPlay(UnoCard card) {
    if (hand.isEmpty) {
      print('Player ${id} cannot play card, hand is empty');
      return false;
    }
    for (UnoCard c in hand) {
      if (c.color == card.color && c.value == card.value) {
        return true;
      }
    }
    print('Player ${id} cannot play card');
    return false;
  }

  String sayHand(){
    String output = '';
    int index = 0;
    for (var card in hand){
      index++;
      output += "${card.color} ${card.value}${index < hand.length ? ', ' : ''}";
    }
    return output;
  }

  void draw(List<UnoCard> deck, List<UnoCard> pile) {
    hand.add(drawCard(deck, pile));
  }

  void uno(List<UnoCard> deck, List<UnoCard> pile) {
    hand.add(drawCard(deck, pile));
    hand.add(drawCard(deck, pile));
  }
}


// Function to create a deck of Uno cards
List<UnoCard> createDeck() {
  List<UnoCard> deck = [];
  for (String color in colors) {
    for (String value in values) {
      deck.add(UnoCard(color, value));
    }
  }
  deck.addAll(List<UnoCard>.generate(4, (i) => UnoCard('Wild', '+4')));
  deck.addAll(List<UnoCard>.generate(4, (i) => UnoCard('Wild', '')));
  return deck;
}

// Function to shuffle the deck using Fisher-Yates algorithm
List<UnoCard> shuffleDeck(List<UnoCard> dack) {
  List<UnoCard> deck = [];
  deck.addAll(dack);
  final random = Random();
  for (int i = deck.length - 1; i > 0; i--) {
    int j = random.nextInt(i + 1);
    var temp = deck[i];
    deck[i] = deck[j];
    deck[j] = temp;
  }
  return deck;
}

// Function to draw a card from the deck
UnoCard drawCard(List<UnoCard> deck, List<UnoCard> pile) {
  if (deck.isEmpty) {
    for (int i = 0; i < pile.length; i++) {
      deck.add(pile.removeLast());
    }
    deck = shuffleDeck(deck);
  }
  return deck.removeLast();
}

// Function to deal initial cards to each player
List<UnoCard> dealCards(List<UnoCard> deck) {
  List<UnoCard> hand = [];
  for (int i = 0; i < 7; i++) {
    UnoCard card = drawCard(deck, []);
    hand.add(card);
  }
  return hand;
}

List<Player> createPlayers(int numPlayers) {
  var players = List<Player>.generate(numPlayers, (i) => Player(i+1, []));
  return players;
}

Future notifyPlayers(List<Player> players, List<UnoCard> pile) async {
  List<Future> futures = [];
  print("other cards");
  String others = players.map((p) => [p.hand.length, p.id]).map((p) => "P${p[1]}: ${p[0]} cards").join(', ');
  print("list");
  List<String> msgs = [
    others,
    "The top card of the pile is ${pile.last}",
  ];
  print("player iter");
  for (Player player in players) {
    msgs.add(player.sayHand());
    futures.add(sendMsgToPlayer(player.id, msgs.join('<br>')));
    msgs.removeLast();
  }
  print("futures");
  await Future.wait(futures);
  print("done");
}

int nextIndex(int playerNum, int playerCount, clockwise) {
  print("next index $playerNum $playerCount $clockwise");
  if(clockwise) {
    if(playerNum == playerCount) {
      print("No more players");
      return 1;
    } else {
      return playerNum += 1;
    }
  } else {
    if(playerNum == 1) {
      return playerCount;
    } else {
      return playerNum -= 1;
    }
  }
}
