import 'package:flutter/material.dart';
import 'package:battlestats/services/game_manager.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late GameManager gameManager;

  @override
  void initState() {
    super.initState();
    gameManager = GameManager();
  }

  @override
  Widget build(BuildContext context) {
    final playerWithMostGames = gameManager.getPlayerWithMostGames();
    final playerWithMostHighScores = gameManager.getPlayerWithMostHighScores();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: gameManager.players.isEmpty
          ? Center(
              child: Text(
                'No players or games yet!\nStart playing to see insights.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Player with most games
                  Text(
                    'Most Active Player',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  playerWithMostGames == null
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No games played yet'),
                          ),
                        )
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: playerWithMostGames.color,
                                  radius: 30,
                                  child: Text(
                                    playerWithMostGames.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        playerWithMostGames.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      Text(
                                        '${gameManager.getPlayerGameCount(playerWithMostGames.id)} games played',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.star, color: Colors.amber),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),

                  // Player with most high scores
                  Text(
                    'Most Wins',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  playerWithMostHighScores == null
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No games completed yet'),
                          ),
                        )
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      playerWithMostHighScores.color,
                                  radius: 30,
                                  child: Text(
                                    playerWithMostHighScores.name[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        playerWithMostHighScores.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      Text(
                                        '${gameManager.getPlayerHighScoreCount(playerWithMostHighScores.id)} high scores',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.emoji_events,
                                    color: Colors.amber),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),

                  // All Players Statistics
                  Text(
                    'All Players',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gameManager.players.length,
                    itemBuilder: (context, index) {
                      final player = gameManager.players[index];
                      final gameCount =
                          gameManager.getPlayerGameCount(player.id);
                      final highScoreCount =
                          gameManager.getPlayerHighScoreCount(player.id);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: player.color,
                            child: Text(
                              player.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(player.name),
                          subtitle: Text(
                            '$gameCount games • $highScoreCount wins',
                          ),
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
