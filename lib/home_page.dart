// home_page.dart
import 'package:flutter/material.dart';
import 'game_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _players = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final String? playersString = prefs.getString('players_scores');
    if (playersString != null) {
      setState(() {
        _players = (jsonDecode(playersString) as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
        _players.sort((a, b) => b['score'].compareTo(a['score']));
      });
    }
  }

  Future<void> _saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    final String playersString = jsonEncode(_players);
    await prefs.setString('players_scores', playersString);
  }

  void _addScore(String playerName, int score) {
    setState(() {
      _players.add({'name': playerName, 'score': score});
      _players.sort((a, b) => b['score'].compareTo(a['score']));
      _saveScores();
    });
  }

  Future<void> _resetScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('players_scores');
    setState(() {
      _players.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scores réinitialisés !'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPlayerNameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Entrez votre nom'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'Votre nom'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _nameController.clear();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final playerName = _nameController.text.trim();
              if (playerName.isNotEmpty) {
                Navigator.of(ctx).pop();

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(playerName: playerName),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  final returnedPlayerName = result['playerName'] as String;
                  final score = result['score'] as int;
                  _addScore(returnedPlayerName, score);
                }
                _loadScores();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un nom pour commencer !'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trouver le mot - Accueil'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Trouver le Mot',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Text(
                'Meilleurs Scores',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              const SizedBox(height: 20),
              _players.isEmpty
                  ? Text(
                      'Aucun score enregistré pour le moment.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _players.length,
                        itemBuilder: (context, index) {
                          final player = _players[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 5,
                            ),
                            elevation: 3,
                            child: ListTile(
                              leading: Icon(
                                Icons.person,
                                color: Colors.blue.shade600,
                              ),
                              title: Text(
                                player['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                'Score: ${player['score']}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 50),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _showPlayerNameDialog,
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text('Nouvelle partie'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 18,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.green.shade900.withOpacity(0.5),
                      ),
                    ),
                  ),
                  if (_players.isNotEmpty) ...[
                    const SizedBox(width: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _resetScores,
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        ),
                        label: const Text('Réinitialiser les scores'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: Colors.red.shade900.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
