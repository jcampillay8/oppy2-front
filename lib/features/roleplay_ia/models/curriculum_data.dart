class CurriculumLevel {
  final int level;
  final String title;
  final String description;
  final Map<int, String> units;

  const CurriculumLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.units,
  });
}

class CurriculumData {
  static const Map<int, CurriculumLevel> syllabus = {
    1: CurriculumLevel(
      level: 1,
      title: "Foundations (CEFR A1)",
      description: "El alumno desarrollará una habilidad de comunicación básica y será capaz de intercambiar información de manera simple.",
      units: {
        1: "It's nice to meet you",
        2: "All about you",
        3: "What's your schedule?",
        4: "What's he like?",
        5: "A day in the life",
        6: "What is that?",
        7: "How do you get there?",
        8: "How much?"
      },
    ),
    2: CurriculumLevel(
      level: 2,
      title: "Fundamentals (CEFR A2)",
      description: "El alumno desarrollará la habilidad de usar un inglés básico que le permitirá desenvolverse en situaciones de la vida diaria.",
      units: {
        1: "What can you do?",
        2: "What's going on?",
        3: "It was great!",
        4: "Yesterday",
        5: "Home sweet home",
        6: "How much do you want?",
        7: "Going out",
        8: "That's my mom!"
      },
    ),
    3: CurriculumLevel(
      level: 3,
      title: "Intermediate (CEFR A2+)",
      description: "El alumno desarrollará la habilidad de manejarse lingüísticamente con una variedad de situaciones de la vida diaria que requieren un uso predecible del lenguaje.",
      units: {
        1: "Making comparasions",
        2: "Have you ever been to Paris?",
        3: "Life stories",
        4: "Where are you going?",
        5: "What's your problem?",
        6: "Negotiating",
        7: "What if?",
        8: "I'm right aren't?"
      },
    ),
    4: CurriculumLevel(
      level: 4,
      title: "Upper Intermediate (CEFR A2+/B1)",
      description: "El alumno desarrollará la habilidad de expresarse de manera limitada en situaciones familiares y enfrentarse de manera general con información no rutinaria.",
      units: {
        1: "What's new?",
        2: "What are they like?",
        3: "What were you doing?",
        4: "Amazing experiences",
        5: "What I've done",
        6: "Plans for the future",
        7: "Why did they do it?",
        8: "What did you decide?"
      },
    ),
    5: CurriculumLevel(
      level: 5,
      title: "Independent (CEFR B1)",
      description: "El alumno desarrollará la habilidad de expresarse de manera precisa en situaciones familiares y comunicarse de manera limitada en situaciones espontáneas o impredecibles.",
      units: {
        1: "Talking about the past",
        2: "A chance for the better",
        3: "Around the world",
        4: "Good news travels fast!",
        5: "If only I had known!",
        6: "When things go wrong",
        7: "What happened?",
        8: "Blast to the future"
      },
    ),
    6: CurriculumLevel(
      level: 6,
      title: "Experienced (CEFR B1+/B2)",
      description: "El alumno desarrollará la habilidad de usar las principales estructuras del lenguaje con seguridad y será capaz de usar estrategias comunicativas apropiadas.",
      units: {
        1: "Telling a story",
        2: "Describing people",
        3: "Discoveries and inventions",
        4: "Products and ideas",
        5: "Working together",
        6: "Corporate culture",
        7: "Gathering Information",
        8: "Taking about numbers"
      },
    ),
  };

  static CurriculumLevel? getLevel(int level) {
    return syllabus[level];
  }

  static String getUnitTitle(int level, int unit) {
    return syllabus[level]?.units[unit] ?? "General Conversation";
  }
}
