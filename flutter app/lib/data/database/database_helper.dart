import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/card_info.dart';
import '../../presentation/widgets/business_card/card_background.dart';

/// Database helper class for managing SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Get database instance (singleton)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      // Initialize FFI
      sqfliteFfiInit();
      // Set the database factory
      databaseFactory = databaseFactoryFfi;
    }
    
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cardly.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        organization TEXT NOT NULL,
        jobTitle TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        location TEXT NOT NULL,
        about TEXT NOT NULL,
        website TEXT NOT NULL,
        logoText TEXT,
        category TEXT,
        background TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  /// Insert sample data for initial setup
  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    final sampleCards = [
      {
        'name': 'Imed Bouchrika',
        'organization': 'ENSIA',
        'jobTitle': 'SWE Professor',
        'email': 'imed.bouchrika@ensia.edu.dz',
        'phone': '0557317584',
        'location': 'Sidi Abdellah - Algiers',
        'about': 'Professor Bouchrika has been actively involved in launching start-ups.',
        'website': 'www.ensia.edu.dz',
        'category': 'School',
        'background': 'purple',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'name': 'Karim Lounis',
        'organization': 'ENSIA',
        'jobTitle': 'ITE Professor',
        'email': 'karim.lounis@ensia.edu.dz',
        'phone': '0661234567',
        'location': 'Sidi Abdellah - Algiers',
        'about': 'Experienced IT professor specializing in software engineering.',
        'website': 'www.ensia.edu.dz',
        'category': 'School',
        'background': 'gold',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'name': 'Ahmed Fruits',
        'organization': 'Sidi Abdellah Market',
        'jobTitle': 'Fruits Vendor',
        'email': 'ahmed.fruits@market.dz',
        'phone': '0771234567',
        'location': 'Sidi Abdellah Market',
        'about': 'Fresh fruits daily.',
        'website': '',
        'category': 'Stores',
        'background': 'greenBlue',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'name': 'Said Vegetables',
        'organization': 'Sidi Abdellah Market',
        'jobTitle': 'Vegetables Vendor',
        'email': 'said.veg@market.dz',
        'phone': '0781234567',
        'location': 'Sidi Abdellah Market',
        'about': 'Fresh vegetables and organic produce.',
        'website': '',
        'category': 'Stores',
        'background': 'grey',
        'createdAt': now,
        'updatedAt': now,
      },
    ];

    for (var card in sampleCards) {
      await db.insert('cards', card);
    }
  }

  /// Convert background string to CardBackground enum
  static CardBackground? _stringToBackground(String? backgroundStr) {
    if (backgroundStr == null) return null;
    
    switch (backgroundStr.toLowerCase()) {
      case 'purple':
        return CardBackground.purple;
      case 'gold':
        return CardBackground.gold;
      case 'greenblue':
        return CardBackground.greenBlue;
      case 'grey':
        return CardBackground.grey;
      case 'blue':
        return CardBackground.blue;
      case 'green':
        return CardBackground.green;
      case 'goldsilver':
        return CardBackground.goldSilver;
      default:
        return CardBackground.defaultGradient;
    }
  }

  /// Convert CardBackground enum to string
  static String? _backgroundToString(CardBackground? background) {
    if (background == null) return null;
    
    if (background == CardBackground.purple) return 'purple';
    if (background == CardBackground.gold) return 'gold';
    if (background == CardBackground.greenBlue) return 'greenBlue';
    if (background == CardBackground.grey) return 'grey';
    if (background == CardBackground.blue) return 'blue';
    if (background == CardBackground.green) return 'green';
    if (background == CardBackground.goldSilver) return 'goldSilver';
    return 'defaultGradient';
  }

  /// Get all cards
  Future<List<CardInfo>> getAllCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cards', orderBy: 'createdAt DESC');
    
    return List.generate(maps.length, (i) {
      return CardInfo(
        name: maps[i]['name'],
        organization: maps[i]['organization'],
        jobTitle: maps[i]['jobTitle'],
        email: maps[i]['email'],
        phone: maps[i]['phone'],
        location: maps[i]['location'],
        about: maps[i]['about'],
        website: maps[i]['website'],
        logoText: maps[i]['logoText'],
        category: maps[i]['category'],
        background: _stringToBackground(maps[i]['background']),
      );
    });
  }

  /// Get card by email (using email as unique identifier)
  Future<CardInfo?> getCardByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;

    return CardInfo(
      name: maps[0]['name'],
      organization: maps[0]['organization'],
      jobTitle: maps[0]['jobTitle'],
      email: maps[0]['email'],
      phone: maps[0]['phone'],
      location: maps[0]['location'],
      about: maps[0]['about'],
      website: maps[0]['website'],
      logoText: maps[0]['logoText'],
      category: maps[0]['category'],
      background: _stringToBackground(maps[0]['background']),
    );
  }

  /// Insert a new card
  Future<int> insertCard(CardInfo card) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final cardMap = {
      'name': card.name,
      'organization': card.organization,
      'jobTitle': card.jobTitle,
      'email': card.email,
      'phone': card.phone,
      'location': card.location,
      'about': card.about,
      'website': card.website,
      'logoText': card.logoText,
      'category': card.category ?? 'Uncategorized',
      'background': _backgroundToString(card.background),
      'createdAt': now,
      'updatedAt': now,
    };

    return await db.insert('cards', cardMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Update an existing card
  Future<int> updateCard(CardInfo card) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final cardMap = {
      'name': card.name,
      'organization': card.organization,
      'jobTitle': card.jobTitle,
      'email': card.email,
      'phone': card.phone,
      'location': card.location,
      'about': card.about,
      'website': card.website,
      'logoText': card.logoText,
      'category': card.category ?? 'Uncategorized',
      'background': _backgroundToString(card.background),
      'updatedAt': now,
    };

    return await db.update(
      'cards',
      cardMap,
      where: 'email = ?',
      whereArgs: [card.email],
    );
  }

  /// Delete a card by email
  Future<int> deleteCard(String email) async {
    final db = await database;
    return await db.delete(
      'cards',
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  /// Search cards by query
  Future<List<CardInfo>> searchCards(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'name LIKE ? OR organization LIKE ? OR jobTitle LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return CardInfo(
        name: maps[i]['name'],
        organization: maps[i]['organization'],
        jobTitle: maps[i]['jobTitle'],
        email: maps[i]['email'],
        phone: maps[i]['phone'],
        location: maps[i]['location'],
        about: maps[i]['about'],
        website: maps[i]['website'],
        logoText: maps[i]['logoText'],
        category: maps[i]['category'],
        background: _stringToBackground(maps[i]['background']),
      );
    });
  }

  /// Get cards by category
  Future<List<CardInfo>> getCardsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return CardInfo(
        name: maps[i]['name'],
        organization: maps[i]['organization'],
        jobTitle: maps[i]['jobTitle'],
        email: maps[i]['email'],
        phone: maps[i]['phone'],
        location: maps[i]['location'],
        about: maps[i]['about'],
        website: maps[i]['website'],
        logoText: maps[i]['logoText'],
        category: maps[i]['category'],
        background: _stringToBackground(maps[i]['background']),
      );
    });
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
