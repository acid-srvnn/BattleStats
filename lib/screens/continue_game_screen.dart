import 'package:flutter/material.dart';
import 'package:battlestats/services/game_manager.dart';
import 'package:battlestats/screens/scorecard_screen.dart';
import 'package:battlestats/models/game.dart';

class ContinueGameScreen extends StatefulWidget {
  const ContinueGameScreen({super.key});

  @override
  State<ContinueGameScreen> createState() => _ContinueGameScreenState();
}

class _ContinueGameScreenState extends State<ContinueGameScreen> {
  late GameManager gameManager;

  @override
  void initState() {
    super.initState();
    gameManager = GameManager();
  }

  @override
  Widget build(BuildContext context) {
    final activeGames = gameManager.getActiveGames();
    final completedGames = gameManager.getCompletedGames();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Games'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.play_arrow), text: 'Active'),
              Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Active Games Tab
            activeGames.isEmpty
                ? Center(
                    child: Text(
                      'No active games!\nStart a new game to begin.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: activeGames.length,
                    itemBuilder: (context, index) {
                      final game = activeGames[index];

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(game.name),
                          subtitle: Text(
                            '${game.players.length} players • ${game.rounds.length} rounds',
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScorecardScreen(game: game),
                              ),
                            ).then((_) => setState(() {}));
                          },
                        ),
                      );
                    },
                  ),

            // Completed Games Tab
            completedGames.isEmpty
                ? Center(
                    child: Text(
                      'No completed games!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: completedGames.length,
                    itemBuilder: (context, index) {
                      final game = completedGames[index];
                      final scores = game.getPlayerScores();
                      String winner = '';

                      if (game.players.isNotEmpty && scores.isNotEmpty) {
                        int winnerIndex = 0;
                        if (game.scoreType == ScoreType.highScoreWins) {
                          winnerIndex = scores
                              .indexOf(scores.reduce((a, b) => a > b ? a : b));
                        } else {
                          winnerIndex = scores
                              .indexOf(scores.reduce((a, b) => a < b ? a : b));
                        }
                        winner = game.players[winnerIndex].name;
                      }

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(game.name),
                          subtitle: Text(
                            'Winner: $winner • ${game.rounds.length} rounds',
                          ),
                          trailing: const Icon(Icons.visibility),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScorecardScreen(game: game),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
