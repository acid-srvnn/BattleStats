import 'package:flutter/material.dart';

class Player {
  final String id;
  final String name;
  final Color color;

  Player({
    required this.id,
    required this.name,
    required this.color,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
    };
  }

  Player copyWith({String? name, Color? color}) {
    return Player(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  String toString() => 'Player(id: $id, name: $name)';
}

// Predefined colors for players
final List<Color> playerColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.pink,
  Colors.cyan,
  Colors.teal,
  Colors.amber,
  Colors.indigo,
];
