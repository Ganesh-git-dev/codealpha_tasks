import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout.dart';
import '../models/flashcard.dart';
import '../models/lesson.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('skillhub.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exerciseType TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        caloriesBurned REAL NOT NULL,
        steps INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE flashcards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        category TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE lessons(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        translation TEXT NOT NULL,
        pronunciation TEXT NOT NULL,
        language TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE quiz_results(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        language TEXT NOT NULL,
        category TEXT NOT NULL,
        score INTEGER NOT NULL,
        total INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await _seedSampleData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quiz_results(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          language TEXT NOT NULL,
          category TEXT NOT NULL,
          score INTEGER NOT NULL,
          total INTEGER NOT NULL,
          date TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _seedSampleData(Database db) async {
    List<Map<String, dynamic>> sampleFlashcards = [
      {'question': 'What is Flutter?', 'answer': 'A UI toolkit by Google for building natively compiled apps', 'category': 'Technology', 'createdAt': DateTime.now().toIso8601String()},
      {'question': 'What is Dart?', 'answer': 'A programming language optimized for UI', 'category': 'Technology', 'createdAt': DateTime.now().toIso8601String()},
      {'question': 'What is SQLite?', 'answer': 'A lightweight relational database engine', 'category': 'Database', 'createdAt': DateTime.now().toIso8601String()},
      {'question': 'What is an API?', 'answer': 'Application Programming Interface', 'category': 'Technology', 'createdAt': DateTime.now().toIso8601String()},
      {'question': 'What is Git?', 'answer': 'A distributed version control system', 'category': 'Technology', 'createdAt': DateTime.now().toIso8601String()},
    ];
    for (var c in sampleFlashcards) {
      await db.insert('flashcards', c);
    }

    List<Map<String, dynamic>> sampleLessons = [
      // === SPANISH ===
      // Greetings
      {'word': 'Hola', 'translation': 'Hello', 'pronunciation': 'OH-lah', 'language': 'Spanish', 'category': 'Greetings'},
      {'word': 'Gracias', 'translation': 'Thank you', 'pronunciation': 'GRAH-see-ahs', 'language': 'Spanish', 'category': 'Greetings'},
      {'word': 'Buenos días', 'translation': 'Good morning', 'pronunciation': 'BWEH-nos DEE-ahs', 'language': 'Spanish', 'category': 'Greetings'},
      {'word': 'Adiós', 'translation': 'Goodbye', 'pronunciation': 'ah-dee-OHS', 'language': 'Spanish', 'category': 'Greetings'},
      {'word': 'Por favor', 'translation': 'Please', 'pronunciation': 'por fah-VOR', 'language': 'Spanish', 'category': 'Greetings'},
      // Numbers
      {'word': 'Uno', 'translation': 'One', 'pronunciation': 'OO-noh', 'language': 'Spanish', 'category': 'Numbers'},
      {'word': 'Dos', 'translation': 'Two', 'pronunciation': 'dohs', 'language': 'Spanish', 'category': 'Numbers'},
      {'word': 'Tres', 'translation': 'Three', 'pronunciation': 'trehs', 'language': 'Spanish', 'category': 'Numbers'},
      {'word': 'Diez', 'translation': 'Ten', 'pronunciation': 'dee-EHS', 'language': 'Spanish', 'category': 'Numbers'},
      {'word': 'Cien', 'translation': 'One hundred', 'pronunciation': 'see-EHN', 'language': 'Spanish', 'category': 'Numbers'},
      // Colors
      {'word': 'Rojo', 'translation': 'Red', 'pronunciation': 'ROH-hoh', 'language': 'Spanish', 'category': 'Colors'},
      {'word': 'Azul', 'translation': 'Blue', 'pronunciation': 'ah-SOOL', 'language': 'Spanish', 'category': 'Colors'},
      {'word': 'Verde', 'translation': 'Green', 'pronunciation': 'BEHR-deh', 'language': 'Spanish', 'category': 'Colors'},
      {'word': 'Amarillo', 'translation': 'Yellow', 'pronunciation': 'ah-mah-REE-yoh', 'language': 'Spanish', 'category': 'Colors'},
      {'word': 'Negro', 'translation': 'Black', 'pronunciation': 'NEH-groh', 'language': 'Spanish', 'category': 'Colors'},
      // Food
      {'word': 'Agua', 'translation': 'Water', 'pronunciation': 'AH-gwah', 'language': 'Spanish', 'category': 'Food & Drinks'},
      {'word': 'Pan', 'translation': 'Bread', 'pronunciation': 'pahn', 'language': 'Spanish', 'category': 'Food & Drinks'},
      {'word': 'Leche', 'translation': 'Milk', 'pronunciation': 'LEH-cheh', 'language': 'Spanish', 'category': 'Food & Drinks'},
      {'word': 'Arroz', 'translation': 'Rice', 'pronunciation': 'ah-ROHS', 'language': 'Spanish', 'category': 'Food & Drinks'},
      {'word': 'Pollo', 'translation': 'Chicken', 'pronunciation': 'POH-yoh', 'language': 'Spanish', 'category': 'Food & Drinks'},
      // Family
      {'word': 'Madre', 'translation': 'Mother', 'pronunciation': 'MAH-dreh', 'language': 'Spanish', 'category': 'Family'},
      {'word': 'Padre', 'translation': 'Father', 'pronunciation': 'PAH-dreh', 'language': 'Spanish', 'category': 'Family'},
      {'word': 'Hermano', 'translation': 'Brother', 'pronunciation': 'ehr-MAH-noh', 'language': 'Spanish', 'category': 'Family'},
      {'word': 'Hermana', 'translation': 'Sister', 'pronunciation': 'ehr-MAH-nah', 'language': 'Spanish', 'category': 'Family'},
      {'word': 'Abuelo', 'translation': 'Grandfather', 'pronunciation': 'ah-BWEH-loh', 'language': 'Spanish', 'category': 'Family'},
      // Travel
      {'word': 'Aeropuerto', 'translation': 'Airport', 'pronunciation': 'ah-eh-roh-PWEHR-toh', 'language': 'Spanish', 'category': 'Travel'},
      {'word': 'Hotel', 'translation': 'Hotel', 'pronunciation': 'oh-TEL', 'language': 'Spanish', 'category': 'Travel'},
      {'word': 'Pasaporte', 'translation': 'Passport', 'pronunciation': 'pah-sah-POHR-teh', 'language': 'Spanish', 'category': 'Travel'},
      {'word': 'Playa', 'translation': 'Beach', 'pronunciation': 'PLAH-yah', 'language': 'Spanish', 'category': 'Travel'},
      {'word': 'Coche', 'translation': 'Car', 'pronunciation': 'KOH-cheh', 'language': 'Spanish', 'category': 'Travel'},
      // Weather
      {'word': 'Sol', 'translation': 'Sun', 'pronunciation': 'sohl', 'language': 'Spanish', 'category': 'Weather'},
      {'word': 'Lluvia', 'translation': 'Rain', 'pronunciation': 'YOO-bee-ah', 'language': 'Spanish', 'category': 'Weather'},
      {'word': 'Nieve', 'translation': 'Snow', 'pronunciation': 'nee-EH-beh', 'language': 'Spanish', 'category': 'Weather'},
      {'word': 'Viento', 'translation': 'Wind', 'pronunciation': 'bee-EHN-toh', 'language': 'Spanish', 'category': 'Weather'},
      {'word': 'Calor', 'translation': 'Heat', 'pronunciation': 'kah-LOHR', 'language': 'Spanish', 'category': 'Weather'},
      // Animals
      {'word': 'Perro', 'translation': 'Dog', 'pronunciation': 'PEH-rroh', 'language': 'Spanish', 'category': 'Animals'},
      {'word': 'Gato', 'translation': 'Cat', 'pronunciation': 'GAH-toh', 'language': 'Spanish', 'category': 'Animals'},
      {'word': 'Pájaro', 'translation': 'Bird', 'pronunciation': 'PAH-hah-roh', 'language': 'Spanish', 'category': 'Animals'},
      {'word': 'Pez', 'translation': 'Fish', 'pronunciation': 'pehs', 'language': 'Spanish', 'category': 'Animals'},
      {'word': 'Caballo', 'translation': 'Horse', 'pronunciation': 'kah-BAH-yoh', 'language': 'Spanish', 'category': 'Animals'},

      // === FRENCH ===
      // Greetings
      {'word': 'Bonjour', 'translation': 'Hello', 'pronunciation': 'bohn-ZHOOR', 'language': 'French', 'category': 'Greetings'},
      {'word': 'Merci', 'translation': 'Thank you', 'pronunciation': 'mair-SEE', 'language': 'French', 'category': 'Greetings'},
      {'word': 'Au revoir', 'translation': 'Goodbye', 'pronunciation': 'oh ruh-VWAR', 'language': 'French', 'category': 'Greetings'},
      {'word': 'S\'il vous plaît', 'translation': 'Please', 'pronunciation': 'seel voo PLEH', 'language': 'French', 'category': 'Greetings'},
      {'word': 'Bonsoir', 'translation': 'Good evening', 'pronunciation': 'bohn-SWAR', 'language': 'French', 'category': 'Greetings'},
      // Numbers
      {'word': 'Un', 'translation': 'One', 'pronunciation': 'uhn', 'language': 'French', 'category': 'Numbers'},
      {'word': 'Deux', 'translation': 'Two', 'pronunciation': 'duh', 'language': 'French', 'category': 'Numbers'},
      {'word': 'Trois', 'translation': 'Three', 'pronunciation': 'trwah', 'language': 'French', 'category': 'Numbers'},
      {'word': 'Dix', 'translation': 'Ten', 'pronunciation': 'dees', 'language': 'French', 'category': 'Numbers'},
      {'word': 'Cent', 'translation': 'One hundred', 'pronunciation': 'sahn', 'language': 'French', 'category': 'Numbers'},
      // Colors
      {'word': 'Rouge', 'translation': 'Red', 'pronunciation': 'roozh', 'language': 'French', 'category': 'Colors'},
      {'word': 'Bleu', 'translation': 'Blue', 'pronunciation': 'bluh', 'language': 'French', 'category': 'Colors'},
      {'word': 'Vert', 'translation': 'Green', 'pronunciation': 'vehr', 'language': 'French', 'category': 'Colors'},
      {'word': 'Jaune', 'translation': 'Yellow', 'pronunciation': 'zhohn', 'language': 'French', 'category': 'Colors'},
      {'word': 'Noir', 'translation': 'Black', 'pronunciation': 'nwar', 'language': 'French', 'category': 'Colors'},
      // Food
      {'word': 'Eau', 'translation': 'Water', 'pronunciation': 'oh', 'language': 'French', 'category': 'Food & Drinks'},
      {'word': 'Pain', 'translation': 'Bread', 'pronunciation': 'pan', 'language': 'French', 'category': 'Food & Drinks'},
      {'word': 'Lait', 'translation': 'Milk', 'pronunciation': 'leh', 'language': 'French', 'category': 'Food & Drinks'},
      {'word': 'Riz', 'translation': 'Rice', 'pronunciation': 'ree', 'language': 'French', 'category': 'Food & Drinks'},
      {'word': 'Poulet', 'translation': 'Chicken', 'pronunciation': 'poo-LEH', 'language': 'French', 'category': 'Food & Drinks'},
      // Family
      {'word': 'Mère', 'translation': 'Mother', 'pronunciation': 'mehr', 'language': 'French', 'category': 'Family'},
      {'word': 'Père', 'translation': 'Father', 'pronunciation': 'pehr', 'language': 'French', 'category': 'Family'},
      {'word': 'Frère', 'translation': 'Brother', 'pronunciation': 'frehr', 'language': 'French', 'category': 'Family'},
      {'word': 'Soeur', 'translation': 'Sister', 'pronunciation': 'suhr', 'language': 'French', 'category': 'Family'},
      {'word': 'Grand-père', 'translation': 'Grandfather', 'pronunciation': 'grahn-PEHR', 'language': 'French', 'category': 'Family'},

      // === GERMAN ===
      // Greetings
      {'word': 'Guten Tag', 'translation': 'Good day', 'pronunciation': 'GOO-ten TAHK', 'language': 'German', 'category': 'Greetings'},
      {'word': 'Danke', 'translation': 'Thanks', 'pronunciation': 'DAHN-kuh', 'language': 'German', 'category': 'Greetings'},
      {'word': 'Tschüss', 'translation': 'Bye', 'pronunciation': 'chews', 'language': 'German', 'category': 'Greetings'},
      {'word': 'Hallo', 'translation': 'Hello', 'pronunciation': 'HAH-loh', 'language': 'German', 'category': 'Greetings'},
      {'word': 'Bitte', 'translation': 'Please', 'pronunciation': 'BIT-tuh', 'language': 'German', 'category': 'Greetings'},
      // Numbers
      {'word': 'Eins', 'translation': 'One', 'pronunciation': 'eyns', 'language': 'German', 'category': 'Numbers'},
      {'word': 'Zwei', 'translation': 'Two', 'pronunciation': 'tsvey', 'language': 'German', 'category': 'Numbers'},
      {'word': 'Drei', 'translation': 'Three', 'pronunciation': 'dry', 'language': 'German', 'category': 'Numbers'},
      {'word': 'Zehn', 'translation': 'Ten', 'pronunciation': 'tsehn', 'language': 'German', 'category': 'Numbers'},
      {'word': 'Hundert', 'translation': 'One hundred', 'pronunciation': 'HOON-dert', 'language': 'German', 'category': 'Numbers'},
      // Colors
      {'word': 'Rot', 'translation': 'Red', 'pronunciation': 'roht', 'language': 'German', 'category': 'Colors'},
      {'word': 'Blau', 'translation': 'Blue', 'pronunciation': 'blau', 'language': 'German', 'category': 'Colors'},
      {'word': 'Grün', 'translation': 'Green', 'pronunciation': 'groon', 'language': 'German', 'category': 'Colors'},
      {'word': 'Gelb', 'translation': 'Yellow', 'pronunciation': 'gelp', 'language': 'German', 'category': 'Colors'},
      {'word': 'Schwarz', 'translation': 'Black', 'pronunciation': 'shvarts', 'language': 'German', 'category': 'Colors'},
      // Food
      {'word': 'Wasser', 'translation': 'Water', 'pronunciation': 'VAH-ser', 'language': 'German', 'category': 'Food & Drinks'},
      {'word': 'Brot', 'translation': 'Bread', 'pronunciation': 'broht', 'language': 'German', 'category': 'Food & Drinks'},
      {'word': 'Milch', 'translation': 'Milk', 'pronunciation': 'milch', 'language': 'German', 'category': 'Food & Drinks'},
      {'word': 'Reis', 'translation': 'Rice', 'pronunciation': 'reys', 'language': 'German', 'category': 'Food & Drinks'},
      {'word': 'Apfel', 'translation': 'Apple', 'pronunciation': 'AP-fel', 'language': 'German', 'category': 'Food & Drinks'},

      // === ITALIAN ===
      // Greetings
      {'word': 'Ciao', 'translation': 'Hello/Bye', 'pronunciation': 'CHOW', 'language': 'Italian', 'category': 'Greetings'},
      {'word': 'Grazie', 'translation': 'Thank you', 'pronunciation': 'GRAHT-see-eh', 'language': 'Italian', 'category': 'Greetings'},
      {'word': 'Arrivederci', 'translation': 'Goodbye', 'pronunciation': 'ah-ree-veh-DEHR-chee', 'language': 'Italian', 'category': 'Greetings'},
      {'word': 'Per favore', 'translation': 'Please', 'pronunciation': 'pehr fah-VOH-reh', 'language': 'Italian', 'category': 'Greetings'},
      {'word': 'Buongiorno', 'translation': 'Good morning', 'pronunciation': 'bwohn-JOHR-noh', 'language': 'Italian', 'category': 'Greetings'},
      // Numbers
      {'word': 'Uno', 'translation': 'One', 'pronunciation': 'OO-noh', 'language': 'Italian', 'category': 'Numbers'},
      {'word': 'Due', 'translation': 'Two', 'pronunciation': 'DOO-eh', 'language': 'Italian', 'category': 'Numbers'},
      {'word': 'Tre', 'translation': 'Three', 'pronunciation': 'treh', 'language': 'Italian', 'category': 'Numbers'},
      {'word': 'Dieci', 'translation': 'Ten', 'pronunciation': 'dee-EH-chee', 'language': 'Italian', 'category': 'Numbers'},
      {'word': 'Cento', 'translation': 'One hundred', 'pronunciation': 'CHEN-toh', 'language': 'Italian', 'category': 'Numbers'},
      // Colors
      {'word': 'Rosso', 'translation': 'Red', 'pronunciation': 'ROHS-soh', 'language': 'Italian', 'category': 'Colors'},
      {'word': 'Blu', 'translation': 'Blue', 'pronunciation': 'bloo', 'language': 'Italian', 'category': 'Colors'},
      {'word': 'Verde', 'translation': 'Green', 'pronunciation': 'VEHR-deh', 'language': 'Italian', 'category': 'Colors'},
      {'word': 'Giallo', 'translation': 'Yellow', 'pronunciation': 'JAH-loh', 'language': 'Italian', 'category': 'Colors'},
      {'word': 'Nero', 'translation': 'Black', 'pronunciation': 'NEH-roh', 'language': 'Italian', 'category': 'Colors'},
      // Food
      {'word': 'Acqua', 'translation': 'Water', 'pronunciation': 'AHK-wah', 'language': 'Italian', 'category': 'Food & Drinks'},
      {'word': 'Pane', 'translation': 'Bread', 'pronunciation': 'PAH-neh', 'language': 'Italian', 'category': 'Food & Drinks'},
      {'word': 'Latte', 'translation': 'Milk', 'pronunciation': 'LAHT-teh', 'language': 'Italian', 'category': 'Food & Drinks'},
      {'word': 'Riso', 'translation': 'Rice', 'pronunciation': 'REE-zoh', 'language': 'Italian', 'category': 'Food & Drinks'},
      {'word': 'Pizza', 'translation': 'Pizza', 'pronunciation': 'PEET-sah', 'language': 'Italian', 'category': 'Food & Drinks'},
      // Family
      {'word': 'Madre', 'translation': 'Mother', 'pronunciation': 'MAH-dreh', 'language': 'Italian', 'category': 'Family'},
      {'word': 'Padre', 'translation': 'Father', 'pronunciation': 'PAH-dreh', 'language': 'Italian', 'category': 'Family'},
      {'word': 'Fratello', 'translation': 'Brother', 'pronunciation': 'frah-TEL-loh', 'language': 'Italian', 'category': 'Family'},
      {'word': 'Sorella', 'translation': 'Sister', 'pronunciation': 'soh-REL-lah', 'language': 'Italian', 'category': 'Family'},
      {'word': 'Nonna', 'translation': 'Grandmother', 'pronunciation': 'NON-nah', 'language': 'Italian', 'category': 'Family'},

      // === JAPANESE ===
      // Greetings
      {'word': 'こんにちは', 'translation': 'Hello', 'pronunciation': 'KON-nee-chee-wah', 'language': 'Japanese', 'category': 'Greetings'},
      {'word': 'ありがとう', 'translation': 'Thank you', 'pronunciation': 'ah-ree-GAH-toh', 'language': 'Japanese', 'category': 'Greetings'},
      {'word': 'さようなら', 'translation': 'Goodbye', 'pronunciation': 'sah-YOH-nah-rah', 'language': 'Japanese', 'category': 'Greetings'},
      {'word': 'おはよう', 'translation': 'Good morning', 'pronunciation': 'oh-hah-YOH', 'language': 'Japanese', 'category': 'Greetings'},
      {'word': 'こんばんは', 'translation': 'Good evening', 'pronunciation': 'KON-bahn-wah', 'language': 'Japanese', 'category': 'Greetings'},
      // Numbers
      {'word': 'いち', 'translation': 'One', 'pronunciation': 'ee-chee', 'language': 'Japanese', 'category': 'Numbers'},
      {'word': 'に', 'translation': 'Two', 'pronunciation': 'nee', 'language': 'Japanese', 'category': 'Numbers'},
      {'word': 'さん', 'translation': 'Three', 'pronunciation': 'sahn', 'language': 'Japanese', 'category': 'Numbers'},
      {'word': 'じゅう', 'translation': 'Ten', 'pronunciation': 'joo', 'language': 'Japanese', 'category': 'Numbers'},
      {'word': 'ひゃく', 'translation': 'One hundred', 'pronunciation': 'hyah-koo', 'language': 'Japanese', 'category': 'Numbers'},
      // Colors
      {'word': 'あか', 'translation': 'Red', 'pronunciation': 'ah-kah', 'language': 'Japanese', 'category': 'Colors'},
      {'word': 'あお', 'translation': 'Blue', 'pronunciation': 'ah-oh', 'language': 'Japanese', 'category': 'Colors'},
      {'word': 'みどり', 'translation': 'Green', 'pronunciation': 'mee-doh-ree', 'language': 'Japanese', 'category': 'Colors'},
      {'word': 'きいろ', 'translation': 'Yellow', 'pronunciation': 'kee-ee-roh', 'language': 'Japanese', 'category': 'Colors'},
      {'word': 'くろ', 'translation': 'Black', 'pronunciation': 'koo-roh', 'language': 'Japanese', 'category': 'Colors'},
      // Food
      {'word': 'みず', 'translation': 'Water', 'pronunciation': 'mee-zoo', 'language': 'Japanese', 'category': 'Food & Drinks'},
      {'word': 'パン', 'translation': 'Bread', 'pronunciation': 'pahn', 'language': 'Japanese', 'category': 'Food & Drinks'},
      {'word': 'ぎゅうにゅう', 'translation': 'Milk', 'pronunciation': 'gyoo-nyoo', 'language': 'Japanese', 'category': 'Food & Drinks'},
      {'word': 'ごはん', 'translation': 'Rice/Meal', 'pronunciation': 'goh-hahn', 'language': 'Japanese', 'category': 'Food & Drinks'},
      {'word': 'さかな', 'translation': 'Fish', 'pronunciation': 'sah-kah-nah', 'language': 'Japanese', 'category': 'Food & Drinks'},

      // === KOREAN ===
      // Greetings
      {'word': '안녕하세요', 'translation': 'Hello', 'pronunciation': 'ahn-nyung-hah-seh-yoh', 'language': 'Korean', 'category': 'Greetings'},
      {'word': '감사합니다', 'translation': 'Thank you', 'pronunciation': 'kahm-sah-hahm-nee-dah', 'language': 'Korean', 'category': 'Greetings'},
      {'word': '안녕히 가세요', 'translation': 'Goodbye', 'pronunciation': 'ahn-nyung-hee gah-seh-yoh', 'language': 'Korean', 'category': 'Greetings'},
      {'word': '네', 'translation': 'Yes', 'pronunciation': 'neh', 'language': 'Korean', 'category': 'Greetings'},
      {'word': '아니요', 'translation': 'No', 'pronunciation': 'ah-nee-yoh', 'language': 'Korean', 'category': 'Greetings'},
      // Numbers
      {'word': '일', 'translation': 'One', 'pronunciation': 'eel', 'language': 'Korean', 'category': 'Numbers'},
      {'word': '이', 'translation': 'Two', 'pronunciation': 'ee', 'language': 'Korean', 'category': 'Numbers'},
      {'word': '삼', 'translation': 'Three', 'pronunciation': 'sahm', 'language': 'Korean', 'category': 'Numbers'},
      {'word': '십', 'translation': 'Ten', 'pronunciation': 'ship', 'language': 'Korean', 'category': 'Numbers'},
      {'word': '백', 'translation': 'One hundred', 'pronunciation': 'bek', 'language': 'Korean', 'category': 'Numbers'},
      // Colors
      {'word': '빨간색', 'translation': 'Red', 'pronunciation': 'ppal-gahn-sek', 'language': 'Korean', 'category': 'Colors'},
      {'word': '파란색', 'translation': 'Blue', 'pronunciation': 'pah-rahn-sek', 'language': 'Korean', 'category': 'Colors'},
      {'word': '초록색', 'translation': 'Green', 'pronunciation': 'choh-rok-sek', 'language': 'Korean', 'category': 'Colors'},
      {'word': '노란색', 'translation': 'Yellow', 'pronunciation': 'noh-rahn-sek', 'language': 'Korean', 'category': 'Colors'},
      {'word': '검은색', 'translation': 'Black', 'pronunciation': 'guh-mun-sek', 'language': 'Korean', 'category': 'Colors'},
      // Food
      {'word': '물', 'translation': 'Water', 'pronunciation': 'mool', 'language': 'Korean', 'category': 'Food & Drinks'},
      {'word': '빵', 'translation': 'Bread', 'pronunciation': 'ppang', 'language': 'Korean', 'category': 'Food & Drinks'},
      {'word': '우유', 'translation': 'Milk', 'pronunciation': 'oo-yoo', 'language': 'Korean', 'category': 'Food & Drinks'},
      {'word': '밥', 'translation': 'Rice', 'pronunciation': 'bap', 'language': 'Korean', 'category': 'Food & Drinks'},
      {'word': '김치', 'translation': 'Kimchi', 'pronunciation': 'keem-chee', 'language': 'Korean', 'category': 'Food & Drinks'},
    ];
    for (var l in sampleLessons) {
      await db.insert('lessons', l);
    }
  }

  // === WORKOUTS ===
  Future<int> insertWorkout(Workout workout) async {
    final db = await database;
    return await db.insert('workouts', workout.toMap());
  }

  Future<List<Workout>> getWorkouts({DateTime? date}) async {
    final db = await database;
    if (date != null) {
      final dateStr = date.toIso8601String().split('T')[0];
      final maps = await db.query('workouts', where: 'date = ?', whereArgs: [dateStr], orderBy: 'id DESC');
      return maps.map((m) => Workout.fromMap(m)).toList();
    }
    final maps = await db.query('workouts', orderBy: 'date DESC, id DESC');
    return maps.map((m) => Workout.fromMap(m)).toList();
  }

  Future<List<Workout>> getWorkoutsBetween(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];
    final maps = await db.query('workouts', where: 'date BETWEEN ? AND ?', whereArgs: [startStr, endStr], orderBy: 'date ASC');
    return maps.map((m) => Workout.fromMap(m)).toList();
  }

  Future<int> deleteWorkout(int id) async {
    final db = await database;
    return await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  // === FLASHCARDS ===
  Future<int> insertFlashcard(Flashcard card) async {
    final db = await database;
    return await db.insert('flashcards', card.toMap());
  }

  Future<List<Flashcard>> getFlashcards() async {
    final db = await database;
    final maps = await db.query('flashcards', orderBy: 'createdAt DESC');
    return maps.map((m) => Flashcard.fromMap(m)).toList();
  }

  Future<int> updateFlashcard(Flashcard card) async {
    final db = await database;
    return await db.update('flashcards', card.toMap(), where: 'id = ?', whereArgs: [card.id]);
  }

  Future<int> deleteFlashcard(int id) async {
    final db = await database;
    return await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }

  // === LESSONS ===
  Future<int> insertLesson(Lesson lesson) async {
    final db = await database;
    return await db.insert('lessons', lesson.toMap());
  }

  Future<List<Lesson>> getLessons({String? language, String? category}) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;
    if (language != null && category != null) {
      where = 'language = ? AND category = ?';
      whereArgs = [language, category];
    } else if (language != null) {
      where = 'language = ?';
      whereArgs = [language];
    } else if (category != null) {
      where = 'category = ?';
      whereArgs = [category];
    }
    final maps = await db.query('lessons', where: where, whereArgs: whereArgs, orderBy: 'id ASC');
    return maps.map((m) => Lesson.fromMap(m)).toList();
  }

  Future<int> deleteLesson(int id) async {
    final db = await database;
    return await db.delete('lessons', where: 'id = ?', whereArgs: [id]);
  }

  // === QUIZ RESULTS ===
  Future<int> insertQuizResult(QuizResult result) async {
    final db = await database;
    return await db.insert('quiz_results', result.toMap());
  }

  Future<List<QuizResult>> getQuizResults({String? language}) async {
    final db = await database;
    if (language != null) {
      final maps = await db.query('quiz_results', where: 'language = ?', whereArgs: [language], orderBy: 'date DESC');
      return maps.map((m) => QuizResult.fromMap(m)).toList();
    }
    final maps = await db.query('quiz_results', orderBy: 'date DESC');
    return maps.map((m) => QuizResult.fromMap(m)).toList();
  }

  Future<Map<String, double>> getLanguageProgress(String language) async {
    final db = await database;
    final results = await db.query('quiz_results', where: 'language = ?', whereArgs: [language]);
    if (results.isEmpty) return {};
    final map = <String, List<int>>{};
    for (var r in results) {
      final cat = r['category'] as String;
      map.putIfAbsent(cat, () => [0, 0]);
      map[cat]![0] += r['score'] as int;
      map[cat]![1] += r['total'] as int;
    }
    return map.map((k, v) => MapEntry(k, v[0] / v[1] * 100));
  }
}
