import 'package:flutter/material.dart';
import 'package:battlestats/models/game.dart';
import 'package:battlestats/models/player.dart';
import 'package:battlestats/services/game_manager.dart';
import 'package:battlestats/screens/scorecard_screen.dart';
import 'package:uuid/uuid.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  late GameManager gameManager;
  final gameNameController = TextEditingController();
  final outValueController = TextEditingController();
  
  List<Player> selectedPlayers = [];
  ScoreType selectedScoreType = ScoreType.highScoreWins;

  @override
  void initState() {
    super.initState();
    gameManager = GameManager();
  }

  @override
  void dispose() {
    gameNameController.dispose();
    outValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start New Game'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Name
            Text('Game Name (Optional)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: gameNameController,
              decoration: const InputDecoration(
                hintText: 'e.g., Rummy Game',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Score Type
            Text('Score Type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Column(
              children: [
                RadioListTile<ScoreType>(
                  title: const Text('High Score Wins'),
                  value: ScoreType.highScoreWins,
                  groupValue: selectedScoreType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedScoreType = value);
                    }
                  },
                ),
                RadioListTile<ScoreType>(
                  title: const Text('Low Score Wins'),
                  value: ScoreType.lowScoreWins,
                  groupValue: selectedScoreType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedScoreType = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Select Players
            Text('Select Players', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            gameManager.players.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'No players available. Go to "Manage Players" to add players.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : Column(
                    children: gameManager.players.map((player) {
                      final isSelected = selectedPlayers.contains(player);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (checked) {
                          setState(() {
                            if (checked ?? false) {
                              selectedPlayers.add(player);
                            } else {
                              selectedPlayers.remove(player);
                            }
                          });
                        },
                        title: Text(player.name),
                        secondary: CircleAvatar(
                          backgroundColor: player.color,
                          child: Text(
                            player.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 24),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedPlayers.length < 2
                    ? null
                    : () async => await _startGame(context),
                child: const Text('Start Game', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startGame(BuildContext context) async {
    final gameName = gameNameController.text.isEmpty
        ? 'Game ${DateTime.now().toString().split('.')[0]}'
        : gameNameController.text;

    final outValue = outValueController.text.isEmpty
        ? null
        : int.tryParse(outValueController.text);

    final newGame = Game(
      id: const Uuid().v4(),
      name: gameName,
      players: selectedPlayers,
      scoreType: selectedScoreType,
      outValue: outValue,
      rounds: [Round(roundNumber: 1, playerScores: {})],
      createdAt: DateTime.now(),
    );

    await gameManager.addGame(newGame);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ScorecardScreen(game: newGame),
      ),
    );
  }
}
