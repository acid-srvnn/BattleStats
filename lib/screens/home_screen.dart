import 'package:flutter/material.dart';
import 'package:battlestats/screens/players_screen.dart';
import 'package:battlestats/screens/new_game_screen.dart';
import 'package:battlestats/screens/continue_game_screen.dart';
import 'package:battlestats/services/game_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GameManager gameManager;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    gameManager = GameManager();
    _initializeGameManager();
  }

  Future<void> _initializeGameManager() async {
    await gameManager.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final playerWithMostGames = gameManager.getPlayerWithMostGames();
    final playerWithMostHighScores = gameManager.getPlayerWithMostHighScores();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Menu Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎮 Battle Stats',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 40),
                  _buildMenuButton(
                    context,
                    label: 'Manage Players',
                    icon: Icons.person_add,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlayersScreen()),
                    ).then((_) => setState(() {})),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    label: 'Start New Game',
                    icon: Icons.add_circle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NewGameScreen()),
                    ).then((_) => setState(() {})),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    label: 'Continue Game',
                    icon: Icons.play_arrow,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ContinueGameScreen()),
                    ).then((_) => setState(() {})),
                  ),
                ],
              ),
            ),

            // Insights Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Most Active Player
                  if (playerWithMostGames != null)
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: playerWithMostGames.color,
                              radius: 24,
                              child: Text(
                                playerWithMostGames.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Most Active',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    playerWithMostGames.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${gameManager.getPlayerGameCount(playerWithMostGames.id)} games',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.star, color: Colors.amber),
                          ],
                        ),
                      ),
                    ),

                  // Most Wins
                  if (playerWithMostHighScores != null)
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: playerWithMostHighScores.color,
                              radius: 24,
                              child: Text(
                                playerWithMostHighScores.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Most Wins',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    playerWithMostHighScores.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${gameManager.getPlayerHighScoreCount(playerWithMostHighScores.id)} wins',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.emoji_events, color: Colors.amber),
                          ],
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

  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
