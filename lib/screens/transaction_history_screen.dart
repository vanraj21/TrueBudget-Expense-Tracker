import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../themes/app_theme.dart';
import '../utils/currency_utils.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedPeriod = 'All';

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currency = userProvider.user?.currency ?? 'INR';
    final symbol = getCurrencySymbol(currency);

    List<Transaction> transactions;
    if (_selectedPeriod == 'All') {
      transactions = transactionProvider.transactions;
    } else if (_selectedPeriod == 'This Month') {
      transactions =
          transactionProvider.getTransactionsByMonth(DateTime.now());
    } else if (_selectedPeriod == 'Last Month') {
      final lastMonth = DateTime(DateTime.now().year, DateTime.now().month - 1);
      transactions = transactionProvider.getTransactionsByMonth(lastMonth);
    } else {
      transactions = transactionProvider.transactions
          .where((t) => t.date.year == DateTime.now().year)
          .toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.textSecondary,
        ),
        title: Text(
          'Transaction History',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'This Month', 'Last Month', 'This Year']
                    .map((period) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FilterChip(
                            label: Text(period),
                            selected: _selectedPeriod == period,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedPeriod = period);
                              }
                            },
                            selectedColor: AppTheme.accent.withOpacity(0.3),
                            checkmarkColor: AppTheme.accent,
                            labelStyle: GoogleFonts.dmSans(
                              color: _selectedPeriod == period
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary,
                            ),
                            backgroundColor: AppTheme.darkCard,
                            side: BorderSide(
                              color: _selectedPeriod == period
                                  ? AppTheme.accent
                                  : AppTheme.darkBorder,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      return _buildTransactionItem(t, symbol);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction, String symbol) {
    final isIncome = transaction.type == TransactionType.income;
    final category = CategoryData.getCategoryById(transaction.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isIncome ? AppTheme.accent : AppTheme.error)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category?.icon ?? Icons.category_rounded,
              color: isIncome ? AppTheme.accent : AppTheme.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(transaction.date),
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}$symbol${transaction.amount.toStringAsFixed(0)}',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isIncome ? AppTheme.accent : AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
