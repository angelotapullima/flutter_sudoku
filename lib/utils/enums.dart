/// TIPOS DE TUTORIALES GUIADOS
enum TutorialScript {
  lawRow,
  lawCol,
  lawBox,
  masteryExclusion,
  powerVision,
  powerClock,
  powerDivine,
}

/// TIPOS DE LAYOUT SEGÚN DISPOSITIVO Y ORIENTACIÓN
enum DeviceLayoutType { 
  portraitMobile, 
  landscapeMobile, 
  desktop 
}

/// DIFICULTADES DEL JUEGO (8 Niveles Graduales RPG + Tutorial)
enum GameDifficulty {
  apprentice, // Iniciado
  cadet,      // Cadete
  explorer,   // Explorador
  traveler,   // Viajero
  strategist, // Estratega
  expert,     // Experto
  master,     // Maestro
  legend,     // Leyenda del Cosmos
  tutorial,   // Tutorial guiado
}

extension GameDifficultyExtension on GameDifficulty {
  String get label {
    switch (this) {
      case GameDifficulty.apprentice: return 'Iniciado';
      case GameDifficulty.cadet: return 'Cadete';
      case GameDifficulty.explorer: return 'Explorador';
      case GameDifficulty.traveler: return 'Viajero';
      case GameDifficulty.strategist: return 'Estratega';
      case GameDifficulty.expert: return 'Experto';
      case GameDifficulty.master: return 'Maestro';
      case GameDifficulty.legend: return 'Leyenda del Cosmos';
      case GameDifficulty.tutorial: return 'Tutorial';
    }
  }
  

  static GameDifficulty fromString(String value) {
    switch (value.toLowerCase()) {
      case 'iniciado':
      case 'apprentice': return GameDifficulty.apprentice;
      case 'cadete':
      case 'cadet': return GameDifficulty.cadet;
      case 'explorador':
      case 'explorer': return GameDifficulty.explorer;
      case 'viajero':
      case 'traveler': return GameDifficulty.traveler;
      case 'estratega':
      case 'strategist': return GameDifficulty.strategist;
      case 'experto':
      case 'expert': return GameDifficulty.expert;
      case 'maestro':
      case 'master': return GameDifficulty.master;
      case 'leyenda del cosmos':
      case 'leyenda':
      case 'legend': return GameDifficulty.legend;
      default: return GameDifficulty.tutorial;
    }
  }
}
