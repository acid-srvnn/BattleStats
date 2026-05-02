import 'dart:convert';
import 'package:battlestats/models/game.dart';
import 'package:battlestats/models/player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameManager {
  static final GameManager _instance = GameManager._internal();
  
  List<Player> players = [];
  List<Game> games = [];
  late SharedPreferences _prefs;

  factory GameManager() {
    return _instance;
  }

  GameManager._internal();

  // Initialize SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await loadData();
  }

  // Save all data to SharedPreferences
  Future<void> saveData() async {
    try {
      final playersJson = jsonEncode(players.map((p) => p.toJson()).toList());
      final gamesJson = jsonEncode(games.map((g) => g.toJson()).toList());
      
      await _prefs.setString('players', playersJson);
      await _prefs.setString('games', gamesJson);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  // Load all data from SharedPreferences
  Future<void> loadData() async {
    try {
      final playersJson = _prefs.getString('players');
      final gamesJson = _prefs.getString('games');
      
      if (playersJson != null) {
        final decoded = jsonDecode(playersJson) as List;
        players = decoded.map((p) => Player.fromJson(p as Map<String, dynamic>)).toList();
      }
      
      if (gamesJson != null) {
        final decoded = jsonDecode(gamesJson) as List;
        games = decoded.map((g) => Game.fromJson(g as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  // Player operations
  Future<void> addPlayer(Player player) async {
    players.add(player);
    await saveData();
  }

  Future<void> updatePlayer(Player player) async {
    final index = players.indexWhere((p) => p.id == player.id);
    if (index != -1) {
      players[index] = player;
      await saveData();
    }
  }

  Future<void> deletePlayer(String playerId) async {
    players.removeWhere((p) => p.id == playerId);
    await saveData();
  }

  Player? getPlayer(String playerId) {
    try {
      return players.firstWhere((p) => p.id == playerId);
    } catch (e) {
      return null;
    }
  }

  // Game operations
  Future<void> addGame(Game game) async {
    games.add(game);
    await saveData();
  }

  Future<void> updateGame(Game game) async {
    final index = games.indexWhere((g) => g.id == game.id);
    if (index != -1) {
      games[index] = game;
      await saveData();
    }
  }

  Game? getGame(String gameId) {
    try {
      return games.firstWhere((g) => g.id == gameId);
    } catch (e) {
      return null;
    }
  }

  List<Game> getActiveGames() {
    return games.where((g) => g.isActive).toList();
  }

  List<Game> getCompletedGames() {
    return games.where((g) => !g.isActive).toList();
  }

  // Statistics
  int getPlayerGameCount(String playerId) {
    return games.where((g) => g.players.any((p) => p.id == playerId)).length;
  }

  int getPlayerHighScoreCount(String playerId) {
    int count = 0;
    for (var game in games) {
      final playerIndex = game.players.indexWhere((p) => p.id == playerId);
      if (playerIndex == -1) continue;

      final scores = game.getPlayerScores();
      final playerScore = scores[playerIndex];

      bool isHighScore;
      if (game.scoreType == ScoreType.highScoreWins) {
        isHighScore = playerScore == scores.reduce((a, b) => a > b ? a : b);
      } else {
        isHighScore = playerScore == scores.reduce((a, b) => a < b ? a : b);
      }

      if (isHighScore) count++;
    }
    return count;
  }

  Player? getPlayerWithMostGames() {
    if (players.isEmpty) return null;
    Player? topPlayer;
    int maxGames = 0;

    for (var player in players) {
      final gameCount = getPlayerGameCount(player.id);
      if (gameCount > maxGames) {
        maxGames = gameCount;
        topPlayer = player;
      }
    }
    return topPlayer;
  }

  Player? getPlayerWithMostHighScores() {
    if (players.isEmpty) return null;
    Player? topPlayer;
    int maxHighScores = 0;

    for (var player in players) {
      final highScoreCount = getPlayerHighScoreCount(player.id);
      if (highScoreCount > maxHighScores) {
        maxHighScores = highScoreCount;
        topPlayer = player;
      }
    }
    return topPlayer;
  }
}
