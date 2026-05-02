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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Fixed left columns (Player info) - Reorderable
                  Column(
                    children: [
                      // Header
                      Container(
                        width: 200,
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: Colors.grey[200],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Player',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                maxLines: 2,
                              ),
                            ],
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
                              width: 200,
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.grey[300],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: player.color,
                                      radius: 14,
                                      child: Text(
                                        player.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        player.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                                  width: 200,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: candidateData.isNotEmpty
                                          ? Colors.blue
                                          : Colors.grey,
                                      width: candidateData.isNotEmpty ? 2 : 1,
                                    ),
                                    color: candidateData.isNotEmpty
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.transparent,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: player.color,
                                          radius: 14,
                                          child: Text(
                                            player.name[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            player.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                        width: 80,
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: Colors.grey[200],
                        ),
                        child: const Center(
                          child: Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Total score rows (reordered)
                      ...List.generate(
                        playerOrder.length,
                        (displayIndex) {
                          final playerIndex = playerOrder[displayIndex];
                          return Container(
                            width: 80,
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Center(
                              child: Text(
                                '${scores[playerIndex]}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                                    width: 60,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      color: Colors.grey[200],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'R${roundIndex + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
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
                                          width: 60,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Text(
                                                  '${roundScores[roundIndex]}',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              if (isStartingPlayer)
                                                Positioned(
                                                  top: 2,
                                                  right: 2,
                                                  child: Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration:
                                                        BoxDecoration(
                                                      color: Colors.green,
                                                      shape:
                                                          BoxShape.circle,
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
            'Edit Score - ${currentGame.players[playerIndex].name} - Round ${roundIndex + 1}'),
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
