import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/card_info.dart';
import '../models/user.dart';
import '../../presentation/widgets/business_card/card_background.dart';

/// Database helper class for managing SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static const String defaultUserId = 'local-anon';

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

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Safety: ensure user and user_cards tables and card userId column exist even if upgrade missed.
    await _ensureUserTable(db);
    await _ensureUserCardTable(db);
    await _ensureCardUserId(db);

    return db;
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        themeMode TEXT DEFAULT 'system',
        language TEXT DEFAULT 'en',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        organization TEXT NOT NULL,
        jobTitle TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        location TEXT NOT NULL,
        about TEXT NOT NULL,
        website TEXT NOT NULL,
        logoText TEXT,
        category TEXT,
        background TEXT,
        fontColor TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

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
        userId TEXT NOT NULL DEFAULT '$defaultUserId',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  /// Handle schema migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          fullName TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          passwordHash TEXT NOT NULL,
          themeMode TEXT DEFAULT 'system',
          language TEXT DEFAULT 'en',
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_cards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL UNIQUE,
          name TEXT NOT NULL,
          organization TEXT NOT NULL,
          jobTitle TEXT NOT NULL,
          email TEXT NOT NULL,
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

      final columns = await db.rawQuery('PRAGMA table_info(cards);');
      final hasUserId = columns.any((col) => col['name'] == 'userId');
      if (!hasUserId) {
        await db.execute("ALTER TABLE cards ADD COLUMN userId TEXT NOT NULL DEFAULT '$defaultUserId'");
      }
      
      // Add theme and language columns to existing users table
      final userColumns = await db.rawQuery('PRAGMA table_info(users);');
      final hasTheme = userColumns.any((col) => col['name'] == 'themeMode');
      final hasLanguage = userColumns.any((col) => col['name'] == 'language');
      if (!hasTheme) {
        await db.execute("ALTER TABLE users ADD COLUMN themeMode TEXT DEFAULT 'system'");
      }
      if (!hasLanguage) {
        await db.execute("ALTER TABLE users ADD COLUMN language TEXT DEFAULT 'en'");
      }
    }
  }

  Future<void> _ensureUserTable(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(users);');
    if (columns.isEmpty) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          fullName TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          passwordHash TEXT NOT NULL,
          themeMode TEXT DEFAULT 'system',
          language TEXT DEFAULT 'en',
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
    } else {
      // Ensure theme and language columns exist
      final hasTheme = columns.any((col) => col['name'] == 'themeMode');
      final hasLanguage = columns.any((col) => col['name'] == 'language');
      if (!hasTheme) {
        await db.execute("ALTER TABLE users ADD COLUMN themeMode TEXT DEFAULT 'system'");
      }
      if (!hasLanguage) {
        await db.execute("ALTER TABLE users ADD COLUMN language TEXT DEFAULT 'en'");
      }
    }
  }

  Future<void> _ensureCardUserId(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(cards);');
    final hasUserId = columns.any((col) => col['name'] == 'userId');
    if (!hasUserId) {
      await db.execute("ALTER TABLE cards ADD COLUMN userId TEXT NOT NULL DEFAULT '$defaultUserId'");
    }
  }

  Future<void> _ensureUserCardTable(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(user_cards);');
    if (columns.isEmpty) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_cards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL UNIQUE,
          name TEXT NOT NULL,
          organization TEXT NOT NULL,
          jobTitle TEXT NOT NULL,
          email TEXT NOT NULL,
          phone TEXT NOT NULL,
          location TEXT NOT NULL,
          about TEXT NOT NULL,
          website TEXT NOT NULL,
          logoText TEXT,
          category TEXT,
          background TEXT,
          fontColor TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
    } else {
      // Add fontColor column if missing
      final hasFontColor = columns.any((col) => col['name'] == 'fontColor');
      if (!hasFontColor) {
        await db.execute('ALTER TABLE user_cards ADD COLUMN fontColor TEXT');
      }
    }
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
        'userId': defaultUserId,
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
        'userId': defaultUserId,
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
        'userId': defaultUserId,
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
        'userId': defaultUserId,
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
      case 'purpleblue':
        return CardBackground.purpleBlue;
      case 'orangepink':
        return CardBackground.orangePink;
      case 'sunset':
        return CardBackground.sunset;
      case 'primarysolid':
        return CardBackground.primarySolid;
      case 'secondarysolid':
        return CardBackground.secondarySolid;
      case 'darksolid':
        return CardBackground.darkSolid;
      case 'bluesolid':
        return CardBackground.blueSolid;
      case 'defaultgradient':
      default:
        return CardBackground.defaultGradient;
    }
  }

  /// Convert CardBackground enum to string
  static String? _backgroundToString(CardBackground? background) {
    if (background == null) return null;

    // Asset-based backgrounds
    final asset = background.assetPath;
    if (asset != null) {
      if (asset.contains('Gold.png')) return 'gold';
      if (asset.contains('Green.png')) return 'green';
      if (asset.contains('Grey.png')) return 'grey';
      if (asset.contains('Purple.png')) return 'purple';
      if (asset.contains('Rectangle.png')) return 'blue';
      if (asset.contains('gold_silver.jpg')) return 'goldSilver';
    }

    // Gradient-based backgrounds
    final grad = background.gradient;
    if (grad != null) {
      if (_sameColors(grad.colors, CardBackground.defaultGradient.gradient!.colors)) {
        return 'defaultGradient';
      }
      if (_sameColors(grad.colors, CardBackground.purpleBlue.gradient!.colors)) {
        return 'purpleBlue';
      }
      if (_sameColors(grad.colors, CardBackground.orangePink.gradient!.colors)) {
        return 'orangePink';
      }
      if (_sameColors(grad.colors, CardBackground.greenBlue.gradient!.colors)) {
        return 'greenBlue';
      }
      if (_sameColors(grad.colors, CardBackground.sunset.gradient!.colors)) {
        return 'sunset';
      }
    }

    // Solid color backgrounds
    final color = background.color;
    if (color != null) {
      if (color.value == CardBackground.primarySolid.color!.value) return 'primarySolid';
      if (color.value == CardBackground.secondarySolid.color!.value) return 'secondarySolid';
      if (color.value == CardBackground.darkSolid.color!.value) return 'darkSolid';
      if (color.value == CardBackground.blueSolid.color!.value) return 'blueSolid';
    }

    // Fallback
    return 'defaultGradient';
  }

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].value != b[i].value) return false;
    }
    return true;
  }

  /// Convert hex string to Color
  static Color? _stringToColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final hexColor = hex.replaceFirst('#', '');
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// Convert Color to hex string
  static String? _colorToString(Color? color) {
    if (color == null) return null;
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  /// Get all cards
  Future<List<CardInfo>> getAllCards({String userId = defaultUserId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return CardInfo(
        id: maps[i]['id'] as int?,
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
        userId: maps[i]['userId'] ?? defaultUserId,
      );
    });
  }

  /// Get card by email (using email as unique identifier)
  Future<CardInfo?> getCardById(int id, {String userId = defaultUserId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );

    if (maps.isEmpty) return null;

    return CardInfo(
      id: maps[0]['id'] as int?,
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
      userId: maps[0]['userId'] ?? defaultUserId,
    );
  }

  /// Insert a new card
  Future<int> insertCard(CardInfo card, {String userId = defaultUserId}) async {
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
      'userId': userId,
      'createdAt': now,
      'updatedAt': now,
    };

    return await db.insert('cards', cardMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Update an existing card
  Future<int> updateCard(CardInfo card, {String userId = defaultUserId}) async {
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

    if (card.id == null) {
      throw ArgumentError('Card id is required for update');
    }

    return await db.update(
      'cards',
      cardMap,
      where: 'id = ? AND userId = ?',
      whereArgs: [card.id, userId],
    );
  }

  /// Delete a card by email
  Future<int> deleteCard(int id, {String userId = defaultUserId}) async {
    final db = await database;
    return await db.delete(
      'cards',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  /// Search cards by query
  Future<List<CardInfo>> searchCards(String query, {String userId = defaultUserId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'userId = ? AND (name LIKE ? OR organization LIKE ? OR jobTitle LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return CardInfo(
        id: maps[i]['id'] as int?,
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
        userId: maps[i]['userId'] ?? defaultUserId,
      );
    });
  }

  /// Get cards by category
  Future<List<CardInfo>> getCardsByCategory(String category, {String userId = defaultUserId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'userId = ? AND category = ?',
      whereArgs: [userId, category],
      orderBy: 'createdAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return CardInfo(
        id: maps[i]['id'] as int?,
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
        userId: maps[i]['userId'] ?? defaultUserId,
      );
    });
  }

  // User helpers
  Future<void> insertUser(User user) async {
    final db = await database;
    await _ensureUserTable(db);
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    await _ensureUserTable(db);
    // Use LEFT JOIN to get user with card data
    final result = await db.rawQuery('''
      SELECT 
        u.id, u.fullName, u.email, u.passwordHash, u.createdAt, u.updatedAt,
        u.themeMode, u.language,
        uc.name as cardName, uc.organization as cardOrganization,
        uc.jobTitle as cardJobTitle, uc.email as cardEmail,
        uc.phone as cardPhone, uc.location as cardLocation,
        uc.about as cardAbout, uc.website as cardWebsite,
        uc.logoText as cardLogoText, uc.category as cardCategory,
        uc.background as cardBackground, uc.fontColor as cardFontColor
      FROM users u
      LEFT JOIN user_cards uc ON u.id = uc.userId
      WHERE u.email = ?
    ''', [email]);
    
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<User?> getUserByCredentials({required String email, required String passwordHash}) async {
    debugPrint('🔍 getUserByCredentials: querying for $email');
    final db = await database;
    await _ensureUserTable(db);
    // Use LEFT JOIN to get user with card data
    final result = await db.rawQuery('''
      SELECT 
        u.id, u.fullName, u.email, u.passwordHash, u.createdAt, u.updatedAt,
        u.themeMode, u.language,
        uc.name as cardName, uc.organization as cardOrganization,
        uc.jobTitle as cardJobTitle, uc.email as cardEmail,
        uc.phone as cardPhone, uc.location as cardLocation,
        uc.about as cardAbout, uc.website as cardWebsite,
        uc.logoText as cardLogoText, uc.category as cardCategory,
        uc.background as cardBackground, uc.fontColor as cardFontColor
      FROM users u
      LEFT JOIN user_cards uc ON u.id = uc.userId
      WHERE u.email = ? AND u.passwordHash = ?
    ''', [email, passwordHash]);
    debugPrint('🔍 Query result count: ${result.length}');
    if (result.isNotEmpty) {
      debugPrint('🔍 Query result cardName: ${result.first['cardName']}, cardBackground: ${result.first['cardBackground']}');
    }
    
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  /// Update user preferences (theme and language)
  Future<void> updateUserPreferences({
    required String userId,
    String? themeMode,
    String? language,
  }) async {
    final db = await database;
    await _ensureUserTable(db);
    
    final Map<String, dynamic> updates = {};
    if (themeMode != null) updates['themeMode'] = themeMode;
    if (language != null) updates['language'] = language;
    updates['updatedAt'] = DateTime.now().toIso8601String();
    
    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Profile card helpers (user_cards table)
  Future<CardInfo?> getUserCard({String userId = defaultUserId}) async {
    final db = await database;
    await _ensureUserCardTable(db);
    debugPrint('🔍 getUserCard: fetching card for userId=$userId');
    final maps = await db.query(
      'user_cards',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );

    debugPrint('🔍 getUserCard: query returned ${maps.length} rows');
    if (maps.isEmpty) return null;

    final row = maps.first;
    debugPrint('🔍 getUserCard: row background=${row['background']}, fontColor=${row['fontColor']}');
    return CardInfo(
      id: row['id'] as int?,
      name: row['name'] as String? ?? '',
      organization: row['organization'] as String? ?? '',
      jobTitle: row['jobTitle'] as String? ?? '',
      email: row['email'] as String? ?? '',
      phone: row['phone'] as String? ?? '',
      location: row['location'] as String? ?? '',
      about: row['about'] as String? ?? '',
      website: row['website'] as String? ?? '',
      logoText: row['logoText'] as String?,
      category: row['category'] as String?,
      background: _stringToBackground(row['background'] as String?),
      userId: (row['userId'] as String?) ?? defaultUserId,
      fontColor: _stringToColor(row['fontColor'] as String?),
    );
  }

  Future<int> upsertUserCard(CardInfo card, {String userId = defaultUserId}) async {
    debugPrint('💾 upsertUserCard called: name=${card.name}, bg=${card.background}, fontColor=${card.fontColor}');
    final db = await database;
    await _ensureUserCardTable(db);
    final now = DateTime.now().toIso8601String();

    // Preserve createdAt if a profile card already exists for this user.
    String createdAt = now;
    final existing = await db.query(
      'user_cards',
      columns: ['createdAt'],
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (existing.isNotEmpty && existing.first['createdAt'] is String) {
      createdAt = existing.first['createdAt'] as String;
    }

    final cardMap = {
      'userId': userId,
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
      'fontColor': _colorToString(card.fontColor),
      'createdAt': createdAt,
      'updatedAt': now,
    };
    debugPrint('💾 Storing in DB: background=${cardMap['background']}, fontColor=${cardMap['fontColor']}');

    // REPLACE allows upsert by unique userId constraint.
    return await db.insert(
      'user_cards',
      cardMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
