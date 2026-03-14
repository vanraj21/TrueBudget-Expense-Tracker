import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/upcoming_payment.dart';
import '../models/saving_plan.dart';
import 'encryption_service.dart';

class DatabaseService {
  static sqflite.Database? _database;
  static const String _dbName = 'true_budget.db';
  static const int _dbVersion = 2;
  static EncryptionService? _encryptionService;

  // Table names
  static const String transactionsTable = 'transactions';
  static const String usersTable = 'users';
  static const String upcomingPaymentsTable = 'upcoming_payments';
  static const String savingPlansTable = 'saving_plans';

  // Transaction columns
  static const String colTransactionId = 'id';
  static const String colTransactionTitle = 'title';
  static const String colTransactionAmount = 'amount';
  static const String colTransactionType = 'type';
  static const String colTransactionCategory = 'category';
  static const String colTransactionDate = 'date';
  static const String colTransactionNote = 'note';
  static const String colTransactionIcon = 'icon';
  static const String colTransactionCreatedAt = 'created_at';
  static const String colTransactionUpdatedAt = 'updated_at';

  // User columns
  static const String colUserId = 'id';
  static const String colUserName = 'name';
  static const String colUserEmail = 'email';
  static const String colUserAvatarUrl = 'avatar_url';
  static const String colUserCurrency = 'currency';
  static const String colUserIsDarkMode = 'is_dark_mode';
  static const String colUserCreatedAt = 'created_at';
  static const String colUserUpdatedAt = 'updated_at';

  // Upcoming payment columns
  static const String colUpcomingId = 'id';
  static const String colUpcomingTitle = 'title';
  static const String colUpcomingAmount = 'amount';
  static const String colUpcomingDueDate = 'due_date';
  static const String colUpcomingIconName = 'icon_name';
  static const String colUpcomingColorValue = 'color_value';

  // Saving plan columns
  static const String colSavingId = 'id';
  static const String colSavingTitle = 'title';
  static const String colSavingTargetAmount = 'target_amount';
  static const String colSavingCurrentAmount = 'current_amount';
  static const String colSavingIconName = 'icon_name';

  // Helper methods
  static Future<EncryptionService> getEncryptionService() async {
    if (_encryptionService == null) {
      _encryptionService = EncryptionService();
      await _encryptionService!.initialize();
    }
    return _encryptionService!;
  }

  static Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<sqflite.Database> _initDatabase() async {
    final path = join(await sqflite.getDatabasesPath(), _dbName);
    return await sqflite.openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(sqflite.Database db, int version) async {
    await _createVersion1Tables(db);
    if (version >= 2) {
      await _createVersion2Tables(db);
    }
  }

  static Future<void> _onUpgrade(sqflite.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createVersion2Tables(db);
    }
  }

  static Future<void> _createVersion1Tables(sqflite.Database db) async {
    await db.execute('''
      CREATE TABLE $transactionsTable (
        $colTransactionId TEXT PRIMARY KEY,
        $colTransactionTitle TEXT NOT NULL,
        $colTransactionAmount REAL NOT NULL,
        $colTransactionType TEXT NOT NULL,
        $colTransactionCategory TEXT NOT NULL,
        $colTransactionDate TEXT NOT NULL,
        $colTransactionNote TEXT,
        $colTransactionIcon TEXT,
        $colTransactionCreatedAt TEXT NOT NULL,
        $colTransactionUpdatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $usersTable (
        $colUserId TEXT PRIMARY KEY,
        $colUserName TEXT NOT NULL,
        $colUserEmail TEXT NOT NULL,
        $colUserAvatarUrl TEXT,
        $colUserCurrency TEXT NOT NULL DEFAULT 'INR',
        $colUserIsDarkMode INTEGER NOT NULL DEFAULT 0,
        $colUserCreatedAt TEXT NOT NULL,
        $colUserUpdatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_transaction_date ON $transactionsTable($colTransactionDate)');
    await db.execute('CREATE INDEX idx_transaction_type ON $transactionsTable($colTransactionType)');
    await db.execute('CREATE INDEX idx_transaction_category ON $transactionsTable($colTransactionCategory)');
  }

  static Future<void> _createVersion2Tables(sqflite.Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $upcomingPaymentsTable (
        $colUpcomingId TEXT PRIMARY KEY,
        $colUpcomingTitle TEXT NOT NULL,
        $colUpcomingAmount REAL NOT NULL,
        $colUpcomingDueDate TEXT NOT NULL,
        $colUpcomingIconName TEXT NOT NULL DEFAULT 'receipt_long_rounded',
        $colUpcomingColorValue INTEGER NOT NULL DEFAULT 4283215696
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $savingPlansTable (
        $colSavingId TEXT PRIMARY KEY,
        $colSavingTitle TEXT NOT NULL,
        $colSavingTargetAmount REAL NOT NULL,
        $colSavingCurrentAmount REAL NOT NULL DEFAULT 0,
        $colSavingIconName TEXT NOT NULL DEFAULT 'savings_rounded'
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_upcoming_due ON $upcomingPaymentsTable($colUpcomingDueDate)');
  }

  static Future<void> initialize() async {
    try {
      print('Initializing database...');
      await database;
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }


  // ============ User operations ============
  static Future<User?> getCurrentUser() async {
    final db = await database;
    final maps = await db.query(usersTable, limit: 1);
    if (maps.isEmpty) return null;
    final m = maps[0];
    return User(
      id: m[colUserId] as String,
      name: m[colUserName] as String,
      email: m[colUserEmail] as String,
      avatarUrl: m[colUserAvatarUrl] as String?,
      currency: (m[colUserCurrency] as String?) ?? 'INR',
      isDarkMode: (m[colUserIsDarkMode] ?? 0) == 1,
    );
  }

  static Future<void> saveUser(User user) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.insert(usersTable, {
      colUserId: user.id,
      colUserName: user.name,
      colUserEmail: user.email,
      colUserAvatarUrl: user.avatarUrl,
      colUserCurrency: user.currency,
      colUserIsDarkMode: user.isDarkMode ? 1 : 0,
      colUserCreatedAt: now,
      colUserUpdatedAt: now,
    }, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  // ============ Transaction operations ============
  static Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query(transactionsTable, orderBy: '$colTransactionDate DESC');
    
    final List<Transaction> transactions = [];
    for (final m in maps) {
      transactions.add(await _mapToTransaction(m));
    }
    return transactions;
  }

  static Future<Transaction> _mapToTransaction(Map<String, dynamic> m) async {
    final encryptionService = await getEncryptionService();
    
    return Transaction(
      id: m[colTransactionId] as String,
      title: encryptionService.decryptSensitiveField(m[colTransactionTitle] as String? ?? ''),
      amount: encryptionService.decryptFinancialAmount(m[colTransactionAmount] as String? ?? '0'),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == m[colTransactionType],
      ),
      category: m[colTransactionCategory] as String,
      date: DateTime.parse(m[colTransactionDate] as String),
      note: encryptionService.decryptTransactionNote(m[colTransactionNote] as String? ?? ''),
      icon: m[colTransactionIcon] as String?,
    );
  }

  static Future<void> addTransaction(Transaction transaction) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      final encryptionService = await getEncryptionService();
      
      print('Database: Adding transaction ${transaction.id}');
      
      await db.insert(transactionsTable, {
        colTransactionId: transaction.id,
        colTransactionTitle: encryptionService.encryptSensitiveField(transaction.title),
        colTransactionAmount: encryptionService.encryptFinancialAmount(transaction.amount),
        colTransactionType: transaction.type.toString().split('.').last,
        colTransactionCategory: transaction.category,
        colTransactionDate: transaction.date.toIso8601String(),
        colTransactionNote: encryptionService.encryptTransactionNote(transaction.note),
        colTransactionIcon: transaction.icon,
        colTransactionCreatedAt: now,
        colTransactionUpdatedAt: now,
      }, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
      
      print('Database: Transaction inserted successfully');
    } catch (e) {
      print('Database error adding transaction: $e');
      rethrow;
    }
  }

  static Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(transactionsTable, where: '$colTransactionId = ?', whereArgs: [id]);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final encryptionService = await getEncryptionService();
    
    await db.update(transactionsTable, {
      colTransactionTitle: encryptionService.encryptSensitiveField(transaction.title),
      colTransactionAmount: encryptionService.encryptFinancialAmount(transaction.amount),
      colTransactionType: transaction.type.toString().split('.').last,
      colTransactionCategory: transaction.category,
      colTransactionDate: transaction.date.toIso8601String(),
      colTransactionNote: encryptionService.encryptTransactionNote(transaction.note),
      colTransactionIcon: transaction.icon,
      colTransactionUpdatedAt: now,
    }, where: '$colTransactionId = ?', whereArgs: [transaction.id]);
  }

  static Future<List<Transaction>> getTransactionsByMonth(DateTime month) async {
    final db = await database;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final maps = await db.query(transactionsTable,
        where: '$colTransactionDate BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: '$colTransactionDate DESC');
    
    final List<Transaction> transactions = [];
    for (final m in maps) {
      transactions.add(await _mapToTransaction(m));
    }
    return transactions;
  }

  static Future<double> getTotalIncome() async {
    final db = await database;
    final r = await db.rawQuery('SELECT SUM($colTransactionAmount) as total FROM $transactionsTable WHERE $colTransactionType = ?', ['income']);
    return (r.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  static Future<double> getTotalExpense() async {
    final db = await database;
    final r = await db.rawQuery('SELECT SUM($colTransactionAmount) as total FROM $transactionsTable WHERE $colTransactionType = ?', ['expense']);
    return (r.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  static Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();
    return income - expense;
  }

  // ============ Upcoming Payment operations ============
  static Future<List<UpcomingPayment>> getAllUpcomingPayments() async {
    final db = await database;
    final maps = await db.query(upcomingPaymentsTable, orderBy: colUpcomingDueDate);
    return maps.map((m) => UpcomingPayment.fromJson({
          'id': m[colUpcomingId] as String,
          'title': m[colUpcomingTitle] as String,
          'amount': m[colUpcomingAmount],
          'due_date': m[colUpcomingDueDate] as String,
          'icon_name': m[colUpcomingIconName] as String?,
          'color_value': m[colUpcomingColorValue],
        })).toList();
  }

  static Future<void> addUpcomingPayment(UpcomingPayment payment) async {
    final db = await database;
    await db.insert(upcomingPaymentsTable, payment.toJson(), conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  static Future<void> deleteUpcomingPayment(String id) async {
    final db = await database;
    await db.delete(upcomingPaymentsTable, where: '$colUpcomingId = ?', whereArgs: [id]);
  }

  // ============ Saving Plan operations ============
  static Future<List<SavingPlan>> getAllSavingPlans() async {
    final db = await database;
    final maps = await db.query(savingPlansTable);
    return maps.map((m) => SavingPlan(
          id: m[colSavingId] as String,
          title: m[colSavingTitle] as String,
          targetAmount: (m[colSavingTargetAmount] as num).toDouble(),
          currentAmount: (m[colSavingCurrentAmount] as num).toDouble(),
          iconName: (m[colSavingIconName] as String?) ?? 'savings_rounded',
        )).toList();
  }

  static Future<void> addSavingPlan(SavingPlan plan) async {
    final db = await database;
    await db.insert(savingPlansTable, plan.toJson(), conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  static Future<void> updateSavingPlan(SavingPlan plan) async {
    final db = await database;
    await db.update(savingPlansTable, {
      colSavingTitle: plan.title,
      colSavingTargetAmount: plan.targetAmount,
      colSavingCurrentAmount: plan.currentAmount,
      colSavingIconName: plan.iconName,
    }, where: '$colSavingId = ?', whereArgs: [plan.id]);
  }

  static Future<void> deleteSavingPlan(String id) async {
    final db = await database;
    await db.delete(savingPlansTable, where: '$colSavingId = ?', whereArgs: [id]);
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
