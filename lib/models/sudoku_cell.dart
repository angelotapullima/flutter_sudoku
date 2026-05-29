class SudokuCell {
  final int row;
  final int col;
  final int value;
  final int solutionValue;
  final bool isOriginal;
  final Set<int> notes;
  final bool isError;
  final bool isDivineRevealed;

  const SudokuCell({
    required this.row,
    required this.col,
    required this.value,
    required this.solutionValue,
    this.isOriginal = false,
    this.notes = const {},
    this.isError = false,
    this.isDivineRevealed = false,
  });

  /// Retorna si la celda está vacía.
  bool get isEmpty => value == 0;

  /// Retorna si el valor de la celda es correcto con respecto a la solución.
  bool get isCorrect => value != 0 && value == solutionValue;

  SudokuCell copyWith({
    int? value,
    int? solutionValue,
    bool? isOriginal,
    Set<int>? notes,
    bool? isError,
    bool? isDivineRevealed,
  }) {
    return SudokuCell(
      row: row,
      col: col,
      value: value ?? this.value,
      solutionValue: solutionValue ?? this.solutionValue,
      isOriginal: isOriginal ?? this.isOriginal,
      notes: notes ?? this.notes,
      isError: isError ?? this.isError,
      isDivineRevealed: isDivineRevealed ?? this.isDivineRevealed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
      'value': value,
      'solutionValue': solutionValue,
      'isOriginal': isOriginal,
      'notes': notes.toList(),
      'isError': isError,
      'isDivineRevealed': isDivineRevealed,
    };
  }

  factory SudokuCell.fromJson(Map<String, dynamic> json) {
    return SudokuCell(
      row: json['row'] as int? ?? 0,
      col: json['col'] as int? ?? 0,
      value: json['value'] as int? ?? 0,
      solutionValue: json['solutionValue'] as int? ?? 0,
      isOriginal: json['isOriginal'] as bool? ?? false,
      notes: ((json['notes'] as List<dynamic>?) ?? [])
          .map((e) => e as int)
          .toSet(),
      isError: json['isError'] as bool? ?? false,
      isDivineRevealed: json['isDivineRevealed'] as bool? ?? false,
    );
  }
}
