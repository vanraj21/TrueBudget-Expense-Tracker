import '../models/transaction.dart';
import '../models/category.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Monthly Analytics
  MonthlyAnalytics getMonthlyAnalytics(List<Transaction> transactions, DateTime month) {
    final monthTransactions = transactions.where((t) =>
      t.date.year == month.year && t.date.month == month.month
    ).toList();

    final income = monthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenses = monthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = income - expenses;

    // Category breakdown
    final categoryBreakdown = <String, double>{};
    for (final transaction in monthTransactions) {
      if (transaction.type == TransactionType.expense) {
        categoryBreakdown[transaction.category] = 
            (categoryBreakdown[transaction.category] ?? 0) + transaction.amount;
      }
    }

    // Daily spending trend
    final dailySpending = <DateTime, double>{};
    for (final transaction in monthTransactions) {
      if (transaction.type == TransactionType.expense) {
        final day = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
        dailySpending[day] = (dailySpending[day] ?? 0) + transaction.amount;
      }
    }

    return MonthlyAnalytics(
      month: month,
      totalIncome: income,
      totalExpenses: expenses,
      balance: balance,
      categoryBreakdown: categoryBreakdown,
      dailySpending: dailySpending,
      transactionCount: monthTransactions.length,
    );
  }

  // Yearly Analytics
  YearlyAnalytics getYearlyAnalytics(List<Transaction> transactions, int year) {
    final yearTransactions = transactions.where((t) => t.date.year == year).toList();

    final monthlyData = <int, MonthlyAnalytics>{};
    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = getMonthlyAnalytics(transactions, DateTime(year, month));
    }

    final totalIncome = yearTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpenses = yearTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Top spending categories
    final categoryTotals = <String, double>{};
    for (final transaction in yearTransactions) {
      if (transaction.type == TransactionType.expense) {
        categoryTotals[transaction.category] = 
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    final topCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return YearlyAnalytics(
      year: year,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      balance: totalIncome - totalExpenses,
      monthlyData: monthlyData,
      topSpendingCategories: topCategories.take(5).toList(),
      transactionCount: yearTransactions.length,
    );
  }

  // Spending Insights
  List<SpendingInsight> generateSpendingInsights(List<Transaction> transactions) {
    final insights = <SpendingInsight>[];
    final now = DateTime.now();

    // Current month analytics
    final currentMonth = getMonthlyAnalytics(transactions, DateTime(now.year, now.month));
    
    // Previous month for comparison
    final previousMonth = getMonthlyAnalytics(transactions, DateTime(now.year, now.month - 1));

    // Spending increased compared to last month
    if (currentMonth.totalExpenses > previousMonth.totalExpenses) {
      final increase = currentMonth.totalExpenses - previousMonth.totalExpenses;
      final percentage = (increase / previousMonth.totalExpenses) * 100;
      
      insights.add(SpendingInsight(
        type: InsightType.spendingIncrease,
        title: 'Spending Increased',
        description: 'Your spending increased by ${percentage.toStringAsFixed(1)}% compared to last month',
        amount: increase,
        severity: percentage > 20 ? InsightSeverity.high : InsightSeverity.medium,
      ));
    }

    // Low savings rate
    if (currentMonth.totalIncome > 0) {
      final savingsRate = (currentMonth.balance / currentMonth.totalIncome) * 100;
      if (savingsRate < 10) {
        insights.add(SpendingInsight(
          type: InsightType.lowSavings,
          title: 'Low Savings Rate',
          description: 'Your savings rate is only ${savingsRate.toStringAsFixed(1)}%. Consider reducing expenses.',
          amount: currentMonth.balance,
          severity: savingsRate < 5 ? InsightSeverity.high : InsightSeverity.medium,
        ));
      }
    }

    // High spending in a category
    for (final entry in currentMonth.categoryBreakdown.entries) {
      if (entry.value > currentMonth.totalExpenses * 0.3) {
        final category = CategoryData.getCategoryById(entry.key);
        insights.add(SpendingInsight(
          type: InsightType.highCategorySpending,
          title: 'High ${category?.name ?? entry.key} Spending',
          description: '${category?.name ?? entry.key} accounts for ${((entry.value / currentMonth.totalExpenses) * 100).toStringAsFixed(1)}% of your expenses',
          amount: entry.value,
          severity: InsightSeverity.medium,
        ));
      }
    }

    // No transactions in last 7 days
    final recentTransactions = transactions.where((t) =>
      t.date.isAfter(now.subtract(const Duration(days: 7)))
    ).toList();

    if (recentTransactions.isEmpty) {
      insights.add(SpendingInsight(
        type: InsightType.noRecentActivity,
        title: 'No Recent Activity',
        description: 'You haven\'t recorded any transactions in the last 7 days',
        amount: 0,
        severity: InsightSeverity.low,
      ));
    }

    return insights;
  }

  // Financial Health Score
  FinancialHealthScore calculateHealthScore(List<Transaction> transactions) {
    final now = DateTime.now();
    final currentMonth = getMonthlyAnalytics(transactions, DateTime(now.year, now.month));
    
    double score = 0;
    final factors = <String, double>{};

    // Income consistency (40% of score)
    final monthlyIncomes = <double>[];
    for (int i = 0; i < 3; i++) {
      final month = DateTime(now.year, now.month - i);
      final analytics = getMonthlyAnalytics(transactions, month);
      if (analytics.totalIncome > 0) {
        monthlyIncomes.add(analytics.totalIncome.toDouble());
      }
    }

    if (monthlyIncomes.length >= 2) {
      final variance = _calculateVariance(monthlyIncomes);
      final consistencyScore = _varianceToScore(variance);
      score += consistencyScore * 0.4;
      factors['Income Consistency'] = consistencyScore;
    }

    // Savings rate (30% of score)
    if (currentMonth.totalIncome > 0) {
      final savingsRate = (currentMonth.balance / currentMonth.totalIncome);
      final savingsScore = (savingsRate * 100).clamp(0.0, 100.0).toDouble();
      score += savingsScore * 0.3;
      factors['Savings Rate'] = savingsScore;
    }

    // Spending diversity (20% of score)
    final categoryCount = currentMonth.categoryBreakdown.keys.length;
    final diversityScore = (categoryCount / 8 * 100).clamp(0.0, 100.0).toDouble();
    score += diversityScore * 0.2;
    factors['Spending Diversity'] = diversityScore;

    // Transaction frequency (10% of score)
    final frequencyScore = (currentMonth.transactionCount / 30 * 100).clamp(0.0, 100.0).toDouble();
    score += frequencyScore * 0.1;
    factors['Transaction Frequency'] = frequencyScore;

    return FinancialHealthScore(
      overallScore: score.clamp(0, 100),
      factors: factors,
      grade: _scoreToGrade(score),
    );
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / values.length;
    return variance;
  }

  double _varianceToScore(double variance) {
    // Lower variance = higher score
    if (variance < 10000) return 100;
    if (variance < 50000) return 80;
    if (variance < 100000) return 60;
    if (variance < 500000) return 40;
    return 20;
  }

  String _scoreToGrade(double score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }
}

// Data Models
class MonthlyAnalytics {
  final DateTime month;
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final Map<String, double> categoryBreakdown;
  final Map<DateTime, double> dailySpending;
  final int transactionCount;

  MonthlyAnalytics({
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.categoryBreakdown,
    required this.dailySpending,
    required this.transactionCount,
  });
}

class YearlyAnalytics {
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final Map<int, MonthlyAnalytics> monthlyData;
  final List<MapEntry<String, double>> topSpendingCategories;
  final int transactionCount;

  YearlyAnalytics({
    required this.year,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.monthlyData,
    required this.topSpendingCategories,
    required this.transactionCount,
  });
}

class SpendingInsight {
  final InsightType type;
  final String title;
  final String description;
  final double amount;
  final InsightSeverity severity;

  SpendingInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.amount,
    required this.severity,
  });
}

enum InsightType {
  spendingIncrease,
  lowSavings,
  highCategorySpending,
  noRecentActivity,
  budgetExceeded,
}

enum InsightSeverity {
  low,
  medium,
  high,
}

class FinancialHealthScore {
  final double overallScore;
  final Map<String, double> factors;
  final String grade;

  FinancialHealthScore({
    required this.overallScore,
    required this.factors,
    required this.grade,
  });
}
