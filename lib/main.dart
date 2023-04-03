import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'dart:core';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Pages1.dart';

const apiKey = 'AIzaSyBUiuITIqoTjhhIKaUfyvzaGgqREvMoGow';
const projectId = 'snake-1fdc7';
bool reseau = true ;
bool test = false;
var isPlaying = false; // var for the game
var scoredef = false; // var for the score
var notseed = true; // cette variable est utiliser pour vérifier que l'on n'a pas deja envoyer les resultats
TargetPlatform platform = defaultTargetPlatform; // savoir sur qu'elle plateform on est
var appop;
var rng = Random();
bool useRawKeyboard = true;

List<Effect> boule = [ // les différent types de boule
  Effect((int value) => value >0 && value <= 30, 1, Colors.red),
  Effect((int value) => value >30 && value <= 70, 2, Colors.orange),
  Effect((int value) => value >70 && value <= 100, 3, Colors.white),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // initialisation
  print(platform);

  final connectivityResult = await (Connectivity().checkConnectivity()); // test internet
  if (connectivityResult == ConnectivityResult.mobile) {
    print('I am connected to a mobile network');
  } 
  if (connectivityResult == ConnectivityResult.wifi) {
    print('I am connected to a wifi network');
  }
  if (connectivityResult == ConnectivityResult.ethernet) {
    print('I am connected to a ethernet');
  }
  if (connectivityResult == ConnectivityResult.vpn) {
    print('I am connected to a vpn');
  }
  if (connectivityResult != ConnectivityResult.wifi && connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.ethernet && connectivityResult != ConnectivityResult.vpn) {
    print('dead network');
    reseau = false;
  }
  if (platform.toString() == 'TargetPlatform.macOS' || platform.toString() == 'TargetPlatform.IOS' ) {
    const FirebaseOptions appop = FirebaseOptions(// info de la firebase pour les versions macOS Chrome et IOS
      apiKey: 'AIzaSyCzzQCpv4mFmXshZMukGoGHRU4qIbRXjvo',
      appId: '1:490930402290:ios:e3a9a98a459930f883716b',
      messagingSenderId: '490930402290',
      projectId: 'snake-1fdc7',
      storageBucket: 'snake-1fdc7.appspot.com',
      iosClientId: '490930402290-d3fv6fqhvlp83tl5rvi05r392sl0r2ln.apps.googleusercontent.com',
      iosBundleId: 'com.example.flutterApplication',
    );
    if (reseau) {
    await Firebase.initializeApp(options: appop);
    }
  } 
  if (platform.toString() == 'TargetPlatform.windows' || platform.toString() == 'TargetPlatform.android') {
    const FirebaseOptions appop = FirebaseOptions( // info de la firebase pour les versions web Chrome et Edge
      apiKey: 'AIzaSyBUiuITIqoTjhhIKaUfyvzaGgqREvMoGow',
      appId: '1:490930402290:web:f0bd3c6234de7b6983716b',
      messagingSenderId: '490930402290',
      projectId: 'snake-1fdc7',
      authDomain: 'snake-1fdc7.firebaseapp.com',
      storageBucket: 'snake-1fdc7.appspot.com',
      measurementId: 'G-VVWNWRSZ07',
    );
    if (reseau) {
    await Firebase.initializeApp(options: appop);
    }
  }


  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int squaresPerRow = 10;
  final int squaresPerCol = 20;
  final fontStyle = const TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();
  String? _message; // the keyboard Listener
  var duration = const Duration(milliseconds: 500); // 1er valeur du timer
  var duration2 = const Duration(milliseconds: 500); // nouvelle valeur du timer quand le snake mange
  String MessageEnd = 'rien'; // message de fin
  var snake = [
    [0, 1],
    [0, 0]
  ];
  var food = [0, 2];
  var direction = 'up'; // first direction 
  var direction2 = 'up'; // pour garder en mémoire la derniére direction
  var randomNumber= 0;

  void add(directionf, List<List<int>> snake) { // fonction pour ajouter 1 de taille au snake
    if (directionf == 'up') {
      snake.insert(0, [snake.first[0], snake.first[1] - 1]);
    }
    if (directionf == 'down') {
      snake.insert(0, [snake.first[0], snake.first[1] + 1]);
    }
    if (direction2 == 'left') {
      snake.insert(0, [snake.first[0]-1, snake.first[1]]);
    }
    if (direction2 == 'right') {
      snake.insert(0, [snake.first[0]+1, snake.first[1]]);
    }
  }


  void startGame() {
    snake = [ // Snake head
      [(squaresPerRow / 2).floor(), (squaresPerCol / 2).floor()]
    ];

    snake.add([snake.first[0], snake.first[1]+1]); // Snake body

    createFood();

    isPlaying = true;
    scoredef = false;
    snakeTime(); // le timer du jeu
  }
  
  int change() { // pour relancer la valeur random
    int randomNumber = rng.nextInt(101);
    return randomNumber;
  }

  void snakeTime() {
    Timer.periodic(duration, (Timer timer) {
      moveSnake(duration2); // fonction pour bouger le snake 
      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
      // print(snake); // debug
      // print(duration); // debug
      // print(duration2); // debug
      // print('direction =' + direction); // debug

      if (duration != duration2) {
        if ( isPlaying = true ) {
        duration = duration2 ;
        timer.cancel();
        snakeTime();
        }
      }
    });
  }

  void moveSnake(var duration) { //Whe move the snake by the var direction and if the snake is not eating he loose the last circle of his body
    setState(() {
      switch(direction) { // on vas dans la direction choisi à part si c'est l'inverse de la direction jouer au tour d'avant donc que le jouer demande au snake de faire un demi tour et d'aller sur lui
        case 'up':
          if (direction2 != 'down') {
            snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          } else {
            snake.insert(0, [snake.first[0], snake.first[1] + 1]);
            direction = 'down';
          } 
        break;     
        case 'down':
          if (direction2 != 'up') {
            snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          } else {
            snake.insert(0, [snake.first[0], snake.first[1] - 1]);
            direction = 'up';
          } 
        break;

        case 'right':
          if (direction2 != 'left') {
            snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          } else {
            snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
            direction = 'left';
          } 
        break;

        case 'left':
          if (direction2 != 'right') {
            snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          } else {
            snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
            direction = 'right';
          } 
        break;
      }
      direction2 = direction; // fin déplacement

      if ((snake.first[0] != food[0] || snake.first[1] != food[1])) {
        snake.removeLast(); // function to lose weight
      }
      else 
      { // vérification pour food et effect
        createFood(); // we multiply the bread
        if ((snake.length - 2)<20) {
        duration2 = duration2 * (0.8 + randomGen.nextDouble() * (0.95 - 0.8)); // speed increase about 10 %
        }
        boule.forEach((effect) {
        if (effect.condition(randomNumber)) {// effect.eat l'effect est jouer si la condition est bonne
          if (effect.eat==1) { // premier effect : on mange 2 fois
            add(direction2, snake);
          }
          if (effect.eat==2) { // deuxième effect : on va moins vite
            duration2 = duration2+const Duration(milliseconds: 100);
          }         
          if (effect.eat==3) { // deuxième effect : on va encore plus vite
            duration2 = duration2*0.9;
          }
        }
      });
      randomNumber = change();
      }
    });
  }

  void createFood() {// crée de la nouriture et la place à un endrois disponible
    food = [
      randomGen.nextInt(squaresPerRow),
      randomGen.nextInt(squaresPerCol)
    ];
    for (final testF in snake) { // si la nourriture est placé sur un endrois ou le snake est alors on replace la nourriture (marche pour une nourriture)
      if (testF.toString()==food.toString()) {
        createFood();
      }
    }
  }

  bool checkGameOver() { 
    if (!isPlaying // We check that we are not out of the field
      || snake.first[1] < 0
      || snake.first[1] >= squaresPerCol
      || snake.first[0] < 0
      || snake.first[0] >= squaresPerRow
    ) {
      return true;
    }

    if (snake.length-2 <0) {
      return true;
    }

    for(var i=1; i < snake.length; ++i) { // Check that the snake still has weight
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
        return true;
      }
    }

    return false;
  }

  void endGame() {
    duration = const Duration(milliseconds: 500);
    duration2 = const Duration(milliseconds: 500);
    scoredef = true;
    isPlaying = false;
    if (snake.length - 2 == -1) { // message de fin
      MessageEnd = 'il semblerait que le principe de cette boule soit de te faire rétrécir';
    }
    if (snake.length - 2 == 0) { // message de fin
      MessageEnd = 'Tu es pas sérieux ?';
    }
    if ((snake.length - 2) <= 5 && (snake.length - 2) > 0) {// message de fin
      MessageEnd = 'Pas ouf ouf';
    }
    if ((snake.length - 2) <= 10 && (snake.length - 2) > 5) {// message de fin
      MessageEnd = 'ca va';
    }
    if ((snake.length - 2) <= 15 && (snake.length - 2) > 10) {// message de fin
      MessageEnd = 'Bravo tu es tout à fait commun';
    }
    if ((snake.length - 2) <= 20 && (snake.length - 2) > 15) {// message de fin
      MessageEnd = 'Pas si mal !';
    }
    if ((snake.length - 2) <= 25 && (snake.length - 2) > 20) {// message de fin
      MessageEnd = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    }
    if ((snake.length - 2) <= 30 && (snake.length - 2) > 25) {// message de fin
      MessageEnd = 'Snake/20';
    }
    if ((snake.length - 2) <= 35 && (snake.length - 2) > 30) {// message de fin
      MessageEnd = 'Tu passes beaucoup de temps sur mon snake';
    }
    if ((snake.length - 2) <= 40 && (snake.length - 2) > 35) {// message de fin
      MessageEnd = 'Presque au top';
    }
    if ((snake.length - 2) > 40) {// message de fin
      MessageEnd = 'GG';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(MessageEnd),
          content: Text(
            'Score: ${snake.length - 2}',
            style: const TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  @override
  void initState() { // for keyboard listener
    super.initState();
    RawKeyboard.instance.addListener(handleKeyEvent);
  }

  @override
  void dispose() { // for keyboard listener
    RawKeyboard.instance.removeListener(handleKeyEvent);
    super.dispose();
  }

  void handleKeyEvent(RawKeyEvent event) { // for keyboard listener
    if (event is RawKeyDownEvent) {
      LogicalKeyboardKey key = event.logicalKey;
      if (key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.keyZ) {
        direction = 'up';
      } else if (key == LogicalKeyboardKey.arrowDown ||
                 key == LogicalKeyboardKey.keyS) {
        direction = 'down';
      } else if (key == LogicalKeyboardKey.arrowLeft ||
                 key == LogicalKeyboardKey.keyQ) {
        direction = 'left';
      } else if (key == LogicalKeyboardKey.arrowRight ||
                 key == LogicalKeyboardKey.keyD) {
        direction = 'right';
      }
    }
  }

  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (direction != 'up' && details.delta.dy > 0) {
                    direction = 'down';
                  } else if (direction != 'down' && details.delta.dy < 0) {
                    direction = 'up';
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (direction != 'left' && details.delta.dx > 0) {
                    direction = 'right';
                  } else if (direction != 'right' && details.delta.dx < 0) {
                    direction = 'left';
                  }
                },
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: handleKeyEvent,
                  child: AspectRatio(
                    aspectRatio: squaresPerRow / (squaresPerCol + 5),
                    child: Padding (
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: squaresPerRow,
                        ),
                        itemCount: squaresPerRow * squaresPerCol,
                        itemBuilder: (BuildContext context, int index) {
                          var color;
                          var x = index % squaresPerRow;
                          var y = (index / squaresPerRow).floor();

                          bool isSnakeBody = false;
                          for (var pos in snake) {
                            if (pos[0] == x && pos[1] == y) {
                              isSnakeBody = true;
                              break;
                            }
                          }

                          if (snake.first[0] == x && snake.first[1] == y) {
                            color = Colors.green;
                          } else if (isSnakeBody) {
                            color = Colors.green[200];
                          } else if (food[0] == x && food[1] == y) {
                            bool testColor= true;
                            boule.forEach((effect) {
                              if (effect.condition(randomNumber)) {
                                color = effect.color;
                                testColor = false;
                              }else if (testColor){
                                color = Colors.deepOrange[100];
                              }
                            });
                          } else {
                            color = Colors.grey[800];
                          }

                          return Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: isPlaying ? Colors.red : Colors.blue,
                      ),
                      child: Text(
                        isPlaying ? 'Restart' : 'Start',
                        style: fontStyle,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          isPlaying = false;
                        } else {
                          notseed = true;
                          startGame();
                        } 
                      }
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      child: Text(
                        scoredef ? 'Enregistrer votre score' : 'score: ${snake.length - 2}',
                        style: fontStyle,
                      ),
                      onPressed: () {
                        if (reseau) {
                          if (scoredef && notseed) {
                            var result = snake.length - 2;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Enregistrer(score: result,test: test,scoredef: scoredef,platform: platform.toString(),)),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                    child: Text(
                      reseau ? 'Tableau des scores': 'pas de réseau',
                      style: fontStyle,
                    ),
                    onPressed: () async {
                      if (reseau) { // on n'appel pas la base si le réseau est dead
                        // Connexion à Firestore
                        final firestore = FirebaseFirestore.instance;

                        // Récupérer les données triées de Firestore
                        var snapshot = await firestore.collection(platform.toString()).orderBy('score', descending: true).limit(7).get();
                        print(snapshot);

                        // Stocker les données triées dans une liste de Map trier par la palteforme
                        List<Map<String, dynamic>?> sortedData = snapshot.docs.map((doc) {
                          return {'name': doc['name'], 'score': doc['score']};
                        }).toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Voir(sortedData: sortedData,platform: platform,)),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
}

class Effect {
  var condition;
  var eat;
  var color;

  Effect(this.condition,this.eat,this.color);

  getCondition() {
    return condition;
  }

  getEat() {
    return eat;
  }
}

