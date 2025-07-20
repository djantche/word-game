// main.dart
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WordConnectGame());
}

class WordConnectGame extends StatelessWidget {
  const WordConnectGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trouver le mot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 5,
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int level = 1;
  String word = "";
  List<String> shuffledLetters = [];
  List<int> selectedLetterIndices = [];
  String userAnswer = "";

  final List<Map<String, dynamic>> levels = [
    {'word': 'FLUTTER', 'hint': 'Framework populaire'},
    {'word': 'DART', 'hint': 'Langage de programmation'},
    {'word': 'CODE', 'hint': 'Ce que les devs écrivent'},
    {'word': 'EMILIEN', 'hint': 'Les 12 coups de midi'},
    {'word': 'HISTOIRE', 'hint': 'Tu racontes des ...'},
    {'word': 'ANDROID', 'hint': 'Système d\'exploitation mobile'},
    {'word': 'WIDGET', 'hint': 'Composant UI dans Flutter'},
    {'word': 'FIREBASE', 'hint': 'Backend proposé par Google'},
    {'word': 'GOOGLE', 'hint': 'Créateur de Flutter'},
    {'word': 'VARIABLE', 'hint': 'Contient une valeur modifiable'},
    {'word': 'FONCTION', 'hint': 'Tu l\'appelles avec des parenthèses'},
    {'word': 'CLASSE', 'hint': 'Modèle pour créer des objets'},
    {'word': 'NAVIGATOR', 'hint': 'Permet de changer de page dans Flutter'},
    {
      'word': 'ASYNC',
      'hint': 'Mot-clé pour exécuter du code de manière non bloquante'
    },
    {'word': 'STATE', 'hint': 'Ce que tu gères avec setState()'},
    {'word': 'DEBUG', 'hint': 'Étape pour corriger les erreurs'},
    {'word': 'ERROR', 'hint': 'Ce que tu obtiens quand ça plante'},
    {'word': 'LOADING', 'hint': 'Ce qui s\'affiche pendant un fetch'},
    {'word': 'GITHUB', 'hint': 'Héberge ton code et tes projets'},
    {'word': 'BRANCH', 'hint': 'Une version parallèle dans Git'},
    {'word': 'MERGE', 'hint': 'Tu lances ça pour combiner deux branches'},
    {'word': 'PULL', 'hint': 'Tu fais ça avant de coder à plusieurs'},
    {'word': 'PUSH', 'hint': 'Tu fais ça pour envoyer ton code'},
    {'word': 'REACT', 'hint': 'Une autre bibliothèque frontend très populaire'},
    {'word': 'HTML', 'hint': 'Langage de base pour les pages web'},
    {'word': 'CSS', 'hint': 'Fait le style de tes pages'},
    {'word': 'JAVASCRIPT', 'hint': 'Langage client du web'},
    {'word': 'PYTHON', 'hint': 'Langage souvent utilisé pour l\'IA'},
    {'word': 'ALGORITHME', 'hint': 'Enchaînement d\'instructions logiques'},
    {'word': 'STAGE', 'hint': 'Ce que tu dois faire en entreprise'},
    {'word': 'PROJET', 'hint': 'Travail à rendre en fin de semestre'},
    {'word': 'EXAMEN', 'hint': 'Ça arrive en fin de période'},
    {'word': 'ETUDIANT', 'hint': 'Celui qui apprend'},
    {'word': 'PROFESSEUR', 'hint': 'Celui qui enseigne'},
    {'word': 'TABLEAU', 'hint': 'Contient plusieurs éléments dans une liste'},
    {'word': 'INT', 'hint': 'Type de variable pour un nombre entier'},
    {'word': 'STRING', 'hint': 'Type pour une chaîne de caractères'},
    {'word': 'BOOLEAN', 'hint': 'true ou false'},
    {'word': 'CONSOLE', 'hint': 'Où s\'affichent les print()'},
    {'word': 'LOOP', 'hint': 'Pour répéter du code plusieurs fois'},
    {'word': 'IF', 'hint': 'Condition de base'},
    {'word': 'ELSE', 'hint': 'Sinon...'},
    {'word': 'RETURN', 'hint': 'Sort d\'une fonction et renvoie une valeur'},
    {'word': 'IMPORT', 'hint': 'Tu le fais pour utiliser un autre fichier'},
    {
      'word': 'PACKAGE',
      'hint': 'Ensemble de fonctionnalités prêtes à l\'emploi'
    },
    {'word': 'API', 'hint': 'Permet à deux systèmes de communiquer'},
    {'word': 'JSON', 'hint': 'Format d\'échange de données très courant'},
    {'word': 'SERVER', 'hint': 'Ce qui traite les requêtes'},
    {'word': 'CLIENT', 'hint': 'C\'est toi ou ton app'},
    {'word': 'LOGIN', 'hint': 'Ce que tu fais pour accéder à ton compte'},
    {'word': 'PASSWORD', 'hint': 'Ce que tu ne dois jamais partager'},
    {'word': 'SECURITE', 'hint': 'Très important pour les données'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  void _loadLevel() {
    setState(() {
      word = levels[level - 1]['word'];
      shuffledLetters = word.split('')..shuffle(Random());
      selectedLetterIndices.clear();
      userAnswer = "";
    });
  }

  void _addLetterToAnswer(int index) {
    setState(() {
      if (!selectedLetterIndices.contains(index)) {
        selectedLetterIndices.add(index);
        _updateUserAnswer();
      }
    });
  }

  void _removeLastLetter() {
    setState(() {
      if (selectedLetterIndices.isNotEmpty) {
        selectedLetterIndices.removeLast();
        _updateUserAnswer();
      }
    });
  }

  void _updateUserAnswer() {
    userAnswer = selectedLetterIndices.map((i) => shuffledLetters[i]).join();
  }

  void _checkAnswer() {
    if (userAnswer == word) {
      if (level < levels.length) {
        _showLevelCompleteDialog();
      } else {
        _showCompletionDialog();
      }
    } else {
      setState(() {
        selectedLetterIndices.clear();
        userAnswer = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrecte, réessaie !'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Félicitations !',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        content: Text(
            'Tu as trouvé le mot du niveau $level : "$word" !\nPrêt pour le niveau suivant ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                level++;
                _loadLevel();
              });
            },
            child: const Text('Niveau Suivant',
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Félicitations !',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        content: const Text('Tu as fini tous les niveaux ! Quel champion !'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                level = 1;
                _loadLevel();
              });
            },
            child: const Text('Rejouer', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trouver le mot - Niveau $level'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    margin: const EdgeInsets.all(20),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Indice:',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            levels[level - 1]['hint'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      userAnswer.isEmpty ? '...' : userAnswer,
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                          letterSpacing: 3),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(shuffledLetters.length, (index) {
                        bool isSelected = selectedLetterIndices.contains(index);
                        return ElevatedButton(
                          onPressed: isSelected
                              ? null
                              : () => _addLetterToAnswer(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Colors.grey
                                : Theme.of(context)
                                    .elevatedButtonTheme
                                    .style
                                    ?.backgroundColor
                                    ?.resolve(MaterialState.values.toSet()),
                            foregroundColor: isSelected
                                ? Colors.white70
                                : Theme.of(context)
                                    .elevatedButtonTheme
                                    .style
                                    ?.foregroundColor
                                    ?.resolve(MaterialState.values.toSet()),
                            elevation: isSelected ? 2 : 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(50, 50),
                          ),
                          child: Text(
                            shuffledLetters[index],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white70 : Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _removeLastLetter,
                        icon: const Icon(Icons.backspace),
                        label: const Text('Annuler'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: _checkAnswer,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Soumettre'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                        ),
                      ),
                    ],
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
