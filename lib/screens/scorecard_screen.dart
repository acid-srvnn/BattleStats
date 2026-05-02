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
  bool _isReorderingEnabled = false;
  int? _editingPlayerIndex;
  int? _editingRoundIndex;
  final TextEditingController _scoreController = TextEditingController();
  final FocusNode _scoreFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    gameManager = GameManager();
    currentGame = widget.game;
    // Initialize player order (0, 1, 2, ...)
    playerOrder = List.generate(currentGame.players.length, (i) => i);
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _scoreFocusNode.dispose();
    super.dispose();
  }

  // Helper function to truncate player names to 10 characters with ellipsis
  String _truncatePlayerName(String name, {int maxLength = 10}) {
    if (name.length > maxLength) {
      return '${name.substring(0, maxLength)}...';
    }
    return name;
  }


  Color? _getScoreColor(int score, List<int> allScores, ScoreType scoreType) {
    if (allScores.isEmpty) return null;
    final uniqueScores = allScores.toSet().toList();
    
    if (scoreType == ScoreType.highScoreWins) {
      uniqueScores.sort((a, b) => b.compareTo(a)); // Higher is better
    } else {
      uniqueScores.sort((a, b) => a.compareTo(b)); // Lower is better
    }
    
    if (uniqueScores.length < 2) return null;

    if (score == uniqueScores.first) return Colors.green.withOpacity(0.2);
    if (score == uniqueScores.last) return Colors.red.withOpacity(0.2);

    if (uniqueScores.length >= 3) {
      if (score == uniqueScores[1]) return Colors.blue.withOpacity(0.2);
    }
    if (uniqueScores.length >= 4) {
      if (score == uniqueScores[uniqueScores.length - 2]) return Colors.orange.withOpacity(0.2);
    }

    return null;
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
                child: Text(_isReorderingEnabled ? 'Disable Reorder' : 'Enable Reorder'),
                onTap: () {
                  setState(() {
                    _isReorderingEnabled = !_isReorderingEnabled;
                  });
                },
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
                            maxSimultaneousDrags: _isReorderingEnabled ? 1 : 0,
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
                                final isCandidate = _isReorderingEnabled && candidateData.isNotEmpty;
                                return Container(
                                  width: 100,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isCandidate
                                          ? Colors.blue
                                          : Colors.grey,
                                      width: isCandidate ? 1 : 0.5,
                                    ),
                                    color: isCandidate
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
                              color: _getScoreColor(scores[playerIndex], scores, currentGame.scoreType),
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
                                      final round = currentGame.rounds[roundIndex];
                                      final isStartingPlayer = player.id == round.startingPlayerId;
                                      final isEditing = _editingPlayerIndex == playerIndex && _editingRoundIndex == roundIndex;
                                      final allScoresInRound = currentGame.players
                                          .map((p) => currentGame.rounds[roundIndex].playerScores[p.id] ?? 0)
                                          .toList();

                                      return GestureDetector(
                                        onTap: () => _startEditing(
                                          playerIndex,
                                          roundIndex,
                                          roundScores[roundIndex],
                                        ),
                                        onLongPress: () => _setStartingPlayer(roundIndex, player.id),
                                        child: Container(
                                          width: 50,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: isEditing ? Colors.blue : Colors.grey,
                                              width: isEditing ? 2 : 0.5,
                                            ),
                                            color: isEditing
                                                ? Colors.blue.withOpacity(0.1)
                                                : _getScoreColor(roundScores[roundIndex], allScoresInRound, currentGame.scoreType),
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: isEditing
                                                    ? TextField(
                                                        controller: _scoreController,
                                                        focusNode: _scoreFocusNode,
                                                        keyboardType: TextInputType.number,
                                                        textAlign: TextAlign.center,
                                                        autofocus: true,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        decoration: const InputDecoration(
                                                          border: InputBorder.none,
                                                          contentPadding: EdgeInsets.zero,
                                                          isDense: true,
                                                        ),
                                                        textInputAction: TextInputAction.next,
                                                        onSubmitted: (value) => _submitScore(value),
                                                      )
                                                    : Text(
                                                        '${roundScores[roundIndex]}',
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
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

  void _startEditing(int playerIndex, int roundIndex, int currentScore) {
    setState(() {
      _editingPlayerIndex = playerIndex;
      _editingRoundIndex = roundIndex;
      _scoreController.text = currentScore == 0 ? '' : currentScore.toString();
      _scoreController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _scoreController.text.length,
      );
    });
    
    // Request focus after the frame is built to keep the keyboard open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scoreFocusNode.canRequestFocus) {
        _scoreFocusNode.requestFocus();
      }
    });
  }

  void _submitScore(String value) async {
    if (_editingPlayerIndex == null || _editingRoundIndex == null) return;

    final newScore = int.tryParse(value) ?? 0;
    final player = currentGame.players[_editingPlayerIndex!];
    final roundIndex = _editingRoundIndex!;
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

    // Move to next player in visual order
    final currentDisplayIndex = playerOrder.indexOf(_editingPlayerIndex!);
    if (currentDisplayIndex < playerOrder.length - 1) {
      final nextPlayerIndex = playerOrder[currentDisplayIndex + 1];
      final nextScore = currentGame.rounds[roundIndex].playerScores[currentGame.players[nextPlayerIndex].id] ?? 0;
      _startEditing(nextPlayerIndex, roundIndex, nextScore);
    } else {
      // End of round entry
      setState(() {
        _editingPlayerIndex = null;
        _editingRoundIndex = null;
      });
    }
  }

  void _setStartingPlayer(int roundIndex, String playerId) async {
    final updatedRounds = [...currentGame.rounds];
    updatedRounds[roundIndex] = updatedRounds[roundIndex].copyWith(startingPlayerId: playerId);

    setState(() {
      currentGame = currentGame.copyWith(rounds: updatedRounds);
    });

    await gameManager.updateGame(currentGame);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting player updated! 🟢'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _addRound() async {
    String? nextStartingPlayerId;

    if (currentGame.rounds.isNotEmpty) {
      final lastRound = currentGame.rounds.last;
      final lastStarterId = lastRound.startingPlayerId;

      if (lastStarterId != null) {
        // Find current display index of last starter
        final lastStarterPlayerIndex = currentGame.players.indexWhere((p) => p.id == lastStarterId);
        final lastStarterDisplayIndex = playerOrder.indexOf(lastStarterPlayerIndex);

        // Next player in visual order
        final nextDisplayIndex = (lastStarterDisplayIndex + 1) % playerOrder.length;
        nextStartingPlayerId = currentGame.players[playerOrder[nextDisplayIndex]].id;
      }
    }

    // Default for first round or fallback
    nextStartingPlayerId ??= currentGame.players[playerOrder[0]].id;

    final newRound = Round(
      roundNumber: currentGame.rounds.length + 1,
      playerScores: {},
      startingPlayerId: nextStartingPlayerId,
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
