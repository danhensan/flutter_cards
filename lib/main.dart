// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:universal_platform/universal_platform.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'registerpage.dart';
import 'resultspage.dart';

void main() {
  runApp(MaterialApp(
    home: RegisterPage(),
  ));
}

Future<List<CardModel>> fetchCards() async {
  final response = await http.get(Uri.parse(
      'https://gist.githubusercontent.com/darthneel/00e8966f45ef2b64652985d78d11443f/raw/c0935c96ae64d23c2b3cf4501f26a30a3027a35d/deck_of_cards.json'));
  final data = jsonDecode(response.body) as List;
  return data.map((item) {
    return CardModel.fromJson(item);
  }).toList();
}

class CardModel {
  final String value;
  final String suit;
  bool highValueAce = true;

  //aqui foi baseado no código do Will, mas eu chamo ele lá embaixo, no pullCards
  int getNumericValue() {
    if (value == 'A') {
      if (highValueAce) {
        return 11;
      } else {
        return 1;
      }
    } else if (value == 'J' || value == 'Q' || value == 'K') {
      return 10;
    } else {
      return int.parse(value);
    }
  }

  CardModel({required this.value, required this.suit});

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      value: json['value'].toString(),
      suit: json['suit'],
    );
  }
  Widget getCardImage() {
    String imagePath = 'assets/images/${suit}_$value.png';
    return Image.asset(imagePath);
  }
}

class GamePage extends StatefulWidget {
  final String? name;
  final int? age;
  final String? gender;

  const GamePage({super.key, this.name, this.age, this.gender});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Future<List<CardModel>> deckCards;
  var rng = Random();
  var listOfCards = List.generate(52, (i) => i);
  var playerOneHand = <CardModel>[];
  int playerOneSum = 0;
  int playerTwoSum = 0;
  var playerTwoHand = <CardModel>[];
  bool stopPressed = false;
  bool isPlayerOneTurn = true;
  bool isFirstStop = true;
  bool bothPlayersStopped = false;
  int playerOneWins = 0;
  int playerTwoWins = 0;
  int draws = 0;

//coloquei as variáveis para serem acrescidas, nos casos de empate,
// vitória ou derrota
  String getGameResult() {
    if (bothPlayersStopped || playerOneSum > 21 || playerTwoSum > 21) {
      if (playerOneSum > 21 && playerTwoSum <= 21) {
        playerTwoWins++;
        return 'PLAYER 2 WON';
      } else if (playerTwoSum > 21 && playerOneSum <= 21) {
        playerOneWins++;
        return 'PLAYER 1 WON';
      } else if (playerOneSum == playerTwoSum) {
        draws++;
        return 'DRAW';
      } else if (playerOneSum <= 21 && playerOneSum > playerTwoSum) {
        playerOneWins++;
        return 'PLAYER 1 WON';
      } else if (playerTwoSum <= 21 && playerTwoSum > playerOneSum) {
        playerTwoWins++;
        return 'PLAYER 2 WON';
      } else {
        return 'ALL PLAYERS ARE BUSTED';
      }
    } else {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    deckCards = fetchCards();
    listOfCards.shuffle(rng);
    pullCards();
    pullCards();
  }

  // modifiquei mais para assimilar no meu cérebro que .then funciona também com o async
  // e retirei o processamento de dentro do setState
  void pullCards() async {
    if (listOfCards.isNotEmpty) {
      listOfCards.shuffle(rng);
      List<CardModel> cards = await deckCards;
      CardModel newCard = cards[listOfCards.removeLast()];

      if (isPlayerOneTurn) {
        playerOneHand.add(newCard);
        playerOneSum += newCard.getNumericValue();
        playerOneSum = checkAceValue(playerOneHand, playerOneSum);
      } else {
        playerTwoHand.add(newCard);
        playerTwoSum += newCard.getNumericValue();
        playerTwoSum = checkAceValue(playerTwoHand, playerTwoSum);
      }
      setState(() {});
    }
  }

  //separei as coisas que estavam dentro do pullCards,
  //para facilitar a leitura e usabilidade
  void playTurn() {
    pullCards();
    if (isPlayerOneTurn && playerOneSum >= 21) {
      isPlayerOneTurn = false;
      pullCards();
      pullCards();
    } else if (!isPlayerOneTurn && playerTwoSum >= 21) {
      isPlayerOneTurn = true;
    }
  }

  int checkAceValue(List<CardModel> playerHand, int playerSum) {
    if (playerSum > 21) {
      for (CardModel card in playerHand) {
        if (card.value == 'A' && card.highValueAce) {
          card.highValueAce = false;
          playerSum = playerHand
              .map((playerCard) => playerCard.getNumericValue())
              .fold(0,
                  (accumulatedScore, cadValue) => accumulatedScore + cadValue);
          break;
        }
      }
    }
    return playerSum;
  }

  void resetGame() {
    setState(() {
      listOfCards = List.generate(52, (i) => i);
      playerOneHand = [];
      playerOneSum = 0;
      playerTwoHand = [];
      playerTwoSum = 0;
      stopPressed = false;
      isPlayerOneTurn = true;
      isFirstStop = true;
      listOfCards.shuffle(rng);
      bothPlayersStopped = false;
      playerOneWins = 0;
      playerTwoWins = 0;
      draws = 0;
      for (var card in playerOneHand) {
        if (card.value == 'A') {
          card.highValueAce = true;
        }
      }
      pullCards();
      pullCards();
    });
  }

  // eu modifiquei a função stopGame para passAndStopTurn
  // (porque fazia mais sentido, porque passa a vez e para)
  // foi a função que mais foi modificada, porque precisava funcionar
  void passAndStopTurn() {
    if (!stopPressed) {
      stopPressed = true;
      isPlayerOneTurn = false;
      if (isFirstStop) {
        pullCards();
        pullCards();
        isFirstStop = false;
      }
    } else {
      isPlayerOneTurn = true;
      stopPressed = false;
      bothPlayersStopped = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xff0a6c03),
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text(
            'ALMOST BLACKJACK',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: FutureBuilder<List<CardModel>>(
                      future: deckCards,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Player 1 : ${widget.name} - Age: ${widget.age}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                // aqui eu comecei usar este universalPlataform,
                                // para deixar o design "responsivo" quando for Windows
                                height: UniversalPlatform.isWindows ? 271 : 200,
                                child: Stack(
                                  children: List.generate(playerOneHand.length,
                                      (index) {
                                    final leftMargin =
                                        UniversalPlatform.isWindows
                                            ? index * 24
                                            : index * 14;
                                    return Container(
                                      margin: EdgeInsets.only(
                                          left: leftMargin.toDouble()),
                                      child: SizedBox(
                                        width: UniversalPlatform.isWindows
                                            ? 190
                                            : 115,
                                        height: UniversalPlatform.isWindows
                                            ? 271
                                            : 164,
                                        child: Padding(
                                          padding: EdgeInsets.all(3),
                                          child: playerOneHand[index]
                                              .getCardImage(),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    '$playerOneSum',
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  ),
                                  Text(
                                    playerOneSum == 21
                                        ? 'BLACKJACK'
                                        : playerOneSum > 21
                                            ? 'BUSTED'
                                            : '',
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Player 2: Bot - Age: ထ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: UniversalPlatform.isWindows ? 271 : 200,
                          child: Stack(
                            children:
                                List.generate(playerTwoHand.length, (index) {
                              final leftMargin = UniversalPlatform.isWindows
                                  ? index * 23
                                  : index * 14;
                              return Container(
                                margin: EdgeInsets.only(
                                    left: leftMargin.toDouble()),
                                child: SizedBox(
                                  width:
                                      UniversalPlatform.isWindows ? 190 : 115,
                                  height:
                                      UniversalPlatform.isWindows ? 271 : 164,
                                  child: Padding(
                                    padding: EdgeInsets.all(3),
                                    child: playerTwoHand[index].getCardImage(),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              '$playerTwoSum',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white),
                            ),
                            Text(
                              playerTwoSum == 21
                                  ? 'BLACKJACK'
                                  : playerTwoSum > 21
                                      ? 'BUSTED'
                                      : '',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  EdgeInsets.only(bottom: UniversalPlatform.isWindows ? 4 : 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    getGameResult(),
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(height: 25),
                  SizedBox(
                    width: 170,
                    height: UniversalPlatform.isWindows ? 30 : 25,
                    child: ElevatedButton(
                      onPressed: bothPlayersStopped
                          ? null
                          : () {
                              pullCards();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'HIT',
                        style: TextStyle(
                            fontSize: UniversalPlatform.isWindows ? 20 : 15,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: UniversalPlatform.isWindows ? 25 : 30),
                  SizedBox(
                    width: 170,
                    height: UniversalPlatform.isWindows ? 30 : 25,
                    child: ElevatedButton(
                      onPressed: bothPlayersStopped ? null : passAndStopTurn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'STOP',
                        style: TextStyle(
                            fontSize: UniversalPlatform.isWindows ? 20 : 15,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: UniversalPlatform.isWindows ? 25 : 30),
                  SizedBox(
                    width: 170,
                    height: UniversalPlatform.isWindows ? 30 : 25,
                    child: ElevatedButton(
                      onPressed: resetGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'PLAY AGAIN',
                        style: TextStyle(
                            fontSize: UniversalPlatform.isWindows ? 20 : 15,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: UniversalPlatform.isWindows ? 25 : 30),
                  SizedBox(
                    width: 170,
                    height: UniversalPlatform.isWindows ? 30 : 25,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultsPage(
                              playerOneWins: playerOneWins,
                              playerTwoWins: playerTwoWins,
                              draws: draws,
                              backAndResetGame: resetGame,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'STATISTICS',
                        style: TextStyle(
                          fontSize: UniversalPlatform.isWindows ? 20 : 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
