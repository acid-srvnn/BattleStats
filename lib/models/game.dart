import 'package:battlestats/models/player.dart';

enum ScoreType { highScoreWins, lowScoreWins }

class Game {
  final String id;
  final String name;
  final List<Player> players;
  final ScoreType scoreType;
  final int? outValue; // Optional out value
  final List<Round> rounds;
  final DateTime createdAt;
  final DateTime? completedAt;

  Game({
    required this.id,
    required this.name,
    required this.players,
    required this.scoreType,
    this.outValue,
    required this.rounds,
    required this.createdAt,
    this.completedAt,
  });

  bool get isActive => completedAt == null;

  List<int> getPlayerScores() {
    return players.map((player) {
      return rounds.fold(0, (sum, round) {
        final playerRound = round.playerScores[player.id] ?? 0;
        return sum + playerRound;
      });
    }).toList();
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      players: (json['players'] as List).map((p) => Player.fromJson(p as Map<String, dynamic>)).toList(),
      scoreType: ScoreType.values.firstWhere(
        (e) => e.toString() == 'ScoreType.${json['scoreType']}',
      ),
      outValue: json['outValue'] as int?,
      rounds: (json['rounds'] as List? ?? []).map((r) => Round.fromJson(r as Map<String, dynamic>)).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'players': players.map((p) => p.toJson()).toList(),
      'scoreType': scoreType.toString().split('.').last,
      'outValue': outValue,
      'rounds': rounds.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  Game copyWith({
    String? id,
    String? name,
    List<Player>? players,
    ScoreType? scoreType,
    int? outValue,
    List<Round>? rounds,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      players: players ?? this.players,
      scoreType: scoreType ?? this.scoreType,
      outValue: outValue ?? this.outValue,
      rounds: rounds ?? this.rounds,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class Round {
  final int roundNumber;
  final Map<String, int> playerScores; // player.id -> score
  final String? startingPlayerId; // ID of player who starts the round

  Round({
    required this.roundNumber,
    required this.playerScores,
    this.startingPlayerId,
  });

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      roundNumber: json['roundNumber'] as int,
      playerScores: Map<String, int>.from(json['playerScores'] as Map<String, dynamic>),
      startingPlayerId: json['startingPlayerId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'playerScores': playerScores,
      'startingPlayerId': startingPlayerId,
    };
  }

  Round copyWith({int? roundNumber, Map<String, int>? playerScores, String? startingPlayerId}) {
    return Round(
      roundNumber: roundNumber ?? this.roundNumber,
      playerScores: playerScores ?? this.playerScores,
      startingPlayerId: startingPlayerId ?? this.startingPlayerId,
    );
  }
}
