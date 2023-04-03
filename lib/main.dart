import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firedart/firedart.dart' as firedart;
import 'package:tuple/tuple.dart';
import 'package:flutter/foundation.dart';
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
DateTime selectedDate = DateTime(2023, 04, 03); //date pour l'event
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

List<Effect> boule = [ // les différent types de boule
Effect((int value) => value >=0 && value <= 20, [() => add(direction2, snake)], Colors.red),// le rouge ne peux pas apparaître dans les coins 
Effect((int value) => value >20 && value <= 40, [() => duration2 = duration2+const Duration(milliseconds: 30)], Colors.orange),
Effect((int value) => value >40 && value <= 60, [() => duration2 = duration2*0.95], Colors.white),
Effect((int value) => value >60 && value <= 100, [() => print('')], Colors.blue),
];

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // initialisation
  print(platform);

  final connectivityResult = await (Connectivity().checkConnectivity()); // test internet
  if (connectivityResult == ConnectivityResult.mobile) {
    print('I am connected to a mobile network.');
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
      if (duration > duration2) {
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
      direction2 = direction;
      if (snake.first[0] != food[0] || snake.first[1] != food[1]) {
        snake.removeLast(); // function to lose weight
      } else       
      { // vérification pour food et effect
        createFood(); // we multiply the bread
        if ((snake.length - 2)<26) {
        duration2 = duration2 * (0.8 + randomGen.nextDouble() * (0.95 - 0.8)); // speed increase about 10 %
        }
        boule.forEach((effect) {
        if (effect.testCondition(randomNumber)) {
          effect.executeEat();
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
    boule.forEach((effect) {
      if (effect.testCondition(randomNumber)) {
        if (effect.color.toString()=='MaterialColor(primary value: Color(0xfff44336))') {
          if (food == [0,0] || food == [squaresPerRow-1,squaresPerCol-1] || food == [0,squaresPerCol-1] || food == [squaresPerRow-1,0] ) {
            createFood();
          }
        }
      }
    });
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
    if ((snake.length - 2) <= 5 && (snake.length - 2) > 0) {
      MessageEnd = 'Pas ouf ouf';
    }
    if ((snake.length - 2) <= 10 && (snake.length - 2) > 5) {
      MessageEnd = 'ca va';
    }
    if ((snake.length - 2) <= 15 && (snake.length - 2) > 10) {
      MessageEnd = 'Bravo tu es tout à fait commun';
    }
    if ((snake.length - 2) <= 20 && (snake.length - 2) > 15) {
      MessageEnd = 'Pas si mal !';
    }
    if ((snake.length - 2) <= 25 && (snake.length - 2) > 20) {
      MessageEnd = 'dommage tu es sur windows';
    }
    if ((snake.length - 2) <= 30 && (snake.length - 2) > 25) {
      MessageEnd = 'Snake/20';
    }
    if ((snake.length - 2) <= 35 && (snake.length - 2) > 30) {
      MessageEnd = 'Tu passes beaucoup de temps sur mon snake';
    }
    if ((snake.length - 2) <= 40 && (snake.length - 2) > 35) {
      MessageEnd = 'Presque au top';
    }
    if ((snake.length - 2) > 40) {
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
        child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: handleKeyEvent,
            child: AspectRatio(
              aspectRatio: squaresPerRow / (squaresPerCol + 5),
                child: Padding (
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child:GridView.builder(
                      physics: const NeverScrollableScrollPhysics(), // on ne peux pas scroll
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( // création de la grille
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
                      }
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
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      child: Text(
                        isPlaying ? 'Restart' : 'Start',
                        style: fontStyle,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          isPlaying = false;
                        } else {
                          notseed=true;
                          startGame();
                        }
                      }
                    ),
                  ),
                  Expanded(
                    child: TextButton( // button pour enregistrer sont score
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      child: Text(
                        scoredef ? 'Enregistrer votre score' : 'Votre score: ${snake.length - 2}' ,
                        style: fontStyle,
                      ),          
                      onPressed: () {
                        if (reseau) {
                          if (!test) {
                            firedart.Firestore.initialize(projectId);
                            test = true;
                          }
                          if (scoredef && notseed) { // pour enregistrer sont score
                            var result = snake.length - 2;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Enregistrer(score: result,test: test,scoredef: scoredef,scoreCollection: firedart.Firestore.instance.collection(platform.toString()),)),
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
                    child: Text( // pour voir les scores des autres
                        reseau ? 'Tableau des scores': 'pas de réseau',
                        style: fontStyle,
                      ),  
                    onPressed: () async {
                      if (reseau) { // on n'appel pas la base si le réseau est dead
                        if (!test) { // on initialize une fois
                          firedart.Firestore.initialize(projectId); // on se connecte avec le projet id
                          test = true;
                          }
                          var name1;
                          var score1;
                          firedart.CollectionReference scoreCollection = firedart.Firestore.instance.collection(platform.toString()); // get the reference to the 'score' collection
                          var documents = await scoreCollection.limit(7).orderBy(descending: true, 'score').get(); // retrieve all documents in the collection
                          List<Tuple2<String, int>> scores = [];

                          for (var doc in documents) {
                          String name = doc['name'];
                          int score = doc['score']; // int.parse est pour faire toInt
                          Tuple2<String, int> tuple = Tuple2.fromList([name, score]);
                          scores.add(tuple);
                          }
                          scores.sort((a, b) => b.item2.compareTo(a.item2)); // trier en ordre décroissant
                          // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Voir(users: scores,platform: platform.toString(),)),
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

  bool testCondition(int value) {
    return condition(value);
  }

  void executeEat() {
    eat.forEach((f) => f());
  }
}