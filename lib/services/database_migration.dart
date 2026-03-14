import 'package:sqflite/sqflite.dart' as sqflite;

class DatabaseMigration {
  final int version;
  final String description;
  final Future<void> Function(sqflite.Database db) migrate;

  DatabaseMigration({
    required this.version,
    required this.description,
    required this.migrate,
  });
}

class DatabaseMigrator {
  static const int currentVersion = 1;
  
  static List<DatabaseMigration> get migrations => [
    DatabaseMigration(
      version: 1,
      description: 'Initial database setup',
      migrate: (db) async {
        await _createVersion1Tables(db);
      },
    ),

  ];

  static Future<void> runMigrations(sqflite.Database db, int fromVersion, int toVersion) async {
    for (final migration in migrations) {
      if (migration.version > fromVersion && migration.version <= toVersion) {
        print('Running migration ${migration.version}: ${migration.description}');
        await migration.migrate(db);
        print('Migration ${migration.version} completed');
      }
    }
  }

  static Future<void> _createVersion1Tables(sqflite.Database db) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        icon TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        avatar_url TEXT,
        currency TEXT NOT NULL DEFAULT 'INR',
        is_dark_mode INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_transaction_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_transaction_type ON transactions(type)');
    await db.execute('CREATE INDEX idx_transaction_category ON transactions(category)');
  }

 
}
