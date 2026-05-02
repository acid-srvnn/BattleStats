import 'package:flutter/material.dart';
import 'package:battlestats/models/game.dart';
import 'package:battlestats/services/game_manager.dart';

class ScorecardScreen extends StatefulWidget {
  final Game game;

  const ScorecardScreen({super.key, required this.game});

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  late Game currentGame;
  late GameManager gameManager;
  late List<int> playerOrder; // Indices to track player order

  @override
  void initState() {
    super.initState();
    gameManager = GameManager();
    currentGame = widget.game;
    // Initialize player order (0, 1, 2, ...)
    playerOrder = List.generate(currentGame.players.length, (i) => i);
  }

  // Helper function to truncate player names to 10 characters with ellipsis
  String _truncatePlayerName(String name, {int maxLength = 10}) {
    if (name.length > maxLength) {
      return '${name.substring(0, maxLength)}...';
    }
    return name;
  }


  @override
  Widget build(BuildContext context) {
    final scores = currentGame.getPlayerScores();

    return Scaffold(
      appBar: AppBar(
        title: Text(currentGame.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Add Round'),
                onTap: () => _addRound(),
              ),
              PopupMenuItem(
                child: const Text('End Game'),
                onTap: () => _endGame(),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Scorecard Table with fixed columns and scrollable rounds
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  // Fixed left columns (Player info) - Reorderable
                  Column(
                    children: [
                      // Header
                      Container(
                        width: 100,
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.5),
                          color: Colors.grey[200],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Center(
                            child: Text(
                              'Player',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      // Reorderable Player rows
                      ...List.generate(
                        playerOrder.length,
                        (displayIndex) {
                          final playerIndex = playerOrder[displayIndex];
                          final player = currentGame.players[playerIndex];
                          return Draggable<int>(
                            data: displayIndex,
                            feedback: Container(
                              width: 100,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 0.5),
                                color: Colors.grey[300],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: player.color,
                                      radius: 10,
                                      child: Text(
                                        player.initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        _truncatePlayerName(player.name),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            child: DragTarget<int>(
                              onAccept: (sourceIndex) {
                                setState(() {
                                  final item = playerOrder.removeAt(sourceIndex);
                                  playerOrder.insert(displayIndex, item);
                                });
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  width: 100,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: candidateData.isNotEmpty
                                          ? Colors.blue
                                          : Colors.grey,
                                      width: candidateData.isNotEmpty ? 1 : 0.5,
                                    ),
                                    color: candidateData.isNotEmpty
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.transparent,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: player.color,
                                          radius: 10,
                                          child: Text(
                                            player.initials,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _truncatePlayerName(player.name),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  // Total score column
                  Column(
                    children: [
                      // Header
                      Container(
                        width: 60,
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.5),
                          color: Colors.grey[200],
                        ),
                        child: const Center(
                          child: Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                      // Total score rows (reordered)
                      ...List.generate(
                        playerOrder.length,
                        (displayIndex) {
                          final playerIndex = playerOrder[displayIndex];
                          return Container(
                            width: 60,
                            height: 32,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 0.5),
                            ),
                            child: Center(
                              child: Text(
                                '${scores[playerIndex]}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  // Scrollable rounds section
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          // Header row with round numbers
                          Row(
                            children: [
                              ...List.generate(
                                currentGame.rounds.length,
                                (roundIndex) {
                                  return Container(
                                    width: 50,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey, width: 0.5),
                                      color: Colors.grey[200],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'R${roundIndex + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          // Data rows (reordered)
                          ...List.generate(
                            playerOrder.length,
                            (displayIndex) {
                              final playerIndex = playerOrder[displayIndex];
                              final player = currentGame.players[playerIndex];
                              final roundScores = currentGame.rounds
                                  .map((r) => r.playerScores[player.id] ?? 0)
                                  .toList();

                              return Row(
                                children: [
                                  ...List.generate(
                                    roundScores.length,
                                    (roundIndex) {
                                      // Auto-rotate starter: R1->player 0, R2->player 1, etc
                                      final starterDisplayIndex = roundIndex % playerOrder.length;
                                      final starterPlayerIndex = playerOrder[starterDisplayIndex];
                                      final isStartingPlayer = playerIndex == starterPlayerIndex;

                                      return GestureDetector(
                                        onTap: () => _editScore(
                                          playerIndex,
                                          roundIndex,
                                          roundScores[roundIndex],
                                        ),
                                        child: Container(
                                          width: 50,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey, width: 0.5),
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Text(
                                                  '${roundScores[roundIndex]}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                              if (isStartingPlayer)
                                                Positioned(
                                                  top: 1,
                                                  right: 1,
                                                  child: Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
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

  void _editScore(int playerIndex, int roundIndex, int currentScore) {
    final scoreController = TextEditingController(text: currentScore.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Edit Score - ${_truncatePlayerName(currentGame.players[playerIndex].name)} - Round ${roundIndex + 1}'),
        content: TextField(
          controller: scoreController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Score',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newScore = int.tryParse(scoreController.text) ?? 0;
              final player = currentGame.players[playerIndex];
              final round = currentGame.rounds[roundIndex];

              final updatedRound = round.copyWith(
                playerScores: {
                  ...round.playerScores,
                  player.id: newScore,
                },
              );

              final updatedRounds = [...currentGame.rounds];
              updatedRounds[roundIndex] = updatedRound;

              setState(() {
                currentGame = currentGame.copyWith(rounds: updatedRounds);
              });

              await gameManager.updateGame(currentGame);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addRound() async {
    final newRound = Round(
      roundNumber: currentGame.rounds.length + 1,
      playerScores: {},
    );

    setState(() {
      currentGame = currentGame.copyWith(
        rounds: [...currentGame.rounds, newRound],
      );
    });

    await gameManager.updateGame(currentGame);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New round added! 🎯')),
    );
  }

  void _endGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Game?'),
        content: const Text('Are you sure you want to end this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final completedGame = currentGame.copyWith(
                completedAt: DateTime.now(),
              );
              await gameManager.updateGame(completedGame);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Game ended! 🎉')),
              );
            },
            child: const Text('End Game'),
          ),
        ],
      ),
    );
  }
}
