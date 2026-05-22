class GlobalTournament {
  final int id;
  final String title;
  final String difficulty;
  final String puzzleData;
  final String solutionData;
  final DateTime endDate;
  final int prizeFirst;

  GlobalTournament({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.puzzleData,
    required this.solutionData,
    required this.endDate,
    required this.prizeFirst,
  });

  factory GlobalTournament.fromJson(Map<String, dynamic> json) {
    return GlobalTournament(
      id: json['id'],
      title: json['title'],
      difficulty: json['difficulty'],
      puzzleData: json['puzzle_data'],
      solutionData: json['solution_data'] ?? '',
      endDate: DateTime.parse(json['end_date']),
      prizeFirst: json['prize_pool_first'] ?? 500,
    );
  }
}

class DailyMission {
  final int id;
  final String title;
  final String description;
  final int requirementValue;
  final int currentProgress;
  final int rewardCoins;
  final int rewardXp;
  final bool isCompleted;

  DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.requirementValue,
    required this.currentProgress,
    required this.rewardCoins,
    required this.rewardXp,
    required this.isCompleted,
  });

  factory DailyMission.fromJson(Map<String, dynamic> json) {
    return DailyMission(
      id: json['mission_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      requirementValue: json['requirement_value'],
      currentProgress: json['current_progress'] ?? 0,
      rewardCoins: json['reward_coins'],
      rewardXp: json['reward_xp'],
      isCompleted: json['is_completed'] ?? false,
    );
  }
}
