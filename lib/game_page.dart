import 'package:flutter/material.dart';
import 'dart:math';

import 'package:word_game/levels.dart';

class GameScreen extends StatefulWidget {
  final String playerName;

  const GameScreen({super.key, required this.playerName});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int level = 1;
  String word = "";
  List<String> shuffledLetters = [];
  List<int> selectedLetterIndices = [];
  String userAnswer = "";
  int incorrectAttempts = 0;

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
      incorrectAttempts = 0;
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
        incorrectAttempts++;
        selectedLetterIndices.clear();
        userAnswer = '';
      });

      if (incorrectAttempts >= 2) {
        _showGameOverDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Incorrecte, réessaie ! Tentatives restantes : ${2 - incorrectAttempts}',
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Félicitations !',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tu as trouvé le mot du niveau $level : "$word" !\nPrêt pour le niveau suivant ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                level++;
                _loadLevel();
              });
            },
            child: const Text(
              'Niveau Suivant',
              style: TextStyle(color: Colors.blue),
            ),
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
        title: const Text(
          'Félicitations !',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: const Text('Tu as fini tous les niveaux ! Quel champion !'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(
                ctx,
              ).pop({'playerName': widget.playerName, 'score': level});
            },
            child: const Text('Rejouer', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Échec !',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Désolé ${widget.playerName}, tu as fait trop d\'erreurs. Le mot était "$word".\nTon score est de ${level - 1} niveaux.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                ctx,
              ).pop({'playerName': widget.playerName, 'score': level - 1});
            },
            child: const Text(
              'Retour à l\'accueil',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trouver le mot - Niveau $level - ${widget.playerName}'),
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Indice:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            levels[level - 1]['hint'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
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
                        letterSpacing: 3,
                      ),
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
