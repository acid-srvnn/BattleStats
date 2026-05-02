import 'package:flutter/material.dart';
import 'package:battlestats/models/player.dart';
import 'package:battlestats/services/game_manager.dart';
import 'package:uuid/uuid.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  late GameManager gameManager;

  @override
  void initState() {
    super.initState();
    gameManager = GameManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Players'),
      ),
      body: gameManager.players.isEmpty
          ? Center(
              child: Text(
                'No players yet!\nTap + to add a player',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              itemCount: gameManager.players.length,
              itemBuilder: (context, index) {
                final player = gameManager.players[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: player.color,
                    child: Text(
                      player.initials,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(player.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePlayer(player),
                  ),
                  onTap: () => _editPlayer(player),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlayerDialog(context),
        tooltip: 'Add Player',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = playerColors[0];

    showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Player'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Player Name',
                    hintText: 'Enter player name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Choose Color:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: playerColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final newPlayer = Player(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    color: selectedColor,
                  );
                  await gameManager.addPlayer(newPlayer);
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    ).then((added) {
      if (added == true) {
        this.setState(() {});
        // Clear any existing snackbar and show new one immediately
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player added! 🎮')),
        );
      }
    });
  }

  void _editPlayer(Player player) {
    final nameController = TextEditingController(text: player.name);
    Color selectedColor = player.color;

    showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Player'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Player Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Choose Color:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: playerColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final updatedPlayer = player.copyWith(
                    name: nameController.text,
                    color: selectedColor,
                  );
                  await gameManager.updatePlayer(updatedPlayer);
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    ).then((updated) {
      if (updated == true) {
        this.setState(() {});
        // Clear any existing snackbar and show new one immediately
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player updated! ✨')),
        );
      }
    });
  }

  void _deletePlayer(Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player?'),
        content: Text('Are you sure you want to delete ${player.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await gameManager.deletePlayer(player.id);
              Navigator.pop(context);
              setState(() {});
              // Clear any existing snackbar and show new one immediately
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Player deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
