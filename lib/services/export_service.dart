import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction.dart';
import '../models/user.dart';

class ExportService {
  static Future<void> exportToCsv(List<Transaction> transactions) async {
    final buffer = StringBuffer();
    buffer.writeln('Date,Title,Type,Category,Amount,Note');

    for (final t in transactions) {
      buffer.writeln(
        '${DateFormat('yyyy-MM-dd').format(t.date)},'
        '"${t.title.replaceAll('"', '""')}",'
        '${t.type.toString().split('.').last},'
        '"${t.category}",'
        '${t.amount},'
        '"${(t.note ?? '').replaceAll('"', '""')}"',
      );
    }

    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/truebudget_export_$timestamp.csv');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'TrueBudget Transaction Export',
      text: 'My transaction export from TrueBudget',
    );
  }

  static Future<void> exportToPdf(List<Transaction> transactions, User? user) async {
    final pdf = pw.Document();
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TrueBudget Financial Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Generated: $timestamp',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    width: 60,
                    height: 60,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green,
                      borderRadius: pw.BorderRadius.circular(15),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        '📱',
                        style: pw.TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // User Info
              if (user != null) ...[
                pw.Container(
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'User: ${user.name}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Email: ${user.email}'),
                      pw.Text('Currency: ${user.currency}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],
              
              // Summary
              _buildSummarySection(transactions),
              pw.SizedBox(height: 20),
              
              // Transactions Table
              pw.Text(
                'Transaction History',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              _buildTransactionsTable(transactions),
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final fileTimestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/truebudget_report_$fileTimestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'TrueBudget Financial Report',
      text: 'My financial report from TrueBudget',
    );
  }

  static pw.Widget _buildSummarySection(List<Transaction> transactions) {
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final balance = income - expenses;

    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Financial Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Column(
                children: [
                  pw.Text(
                    'Income',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.green,
                    ),
                  ),
                  pw.Text(
                    '₹${income.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    'Expenses',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.red,
                    ),
                  ),
                  pw.Text(
                    '₹${expenses.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    'Balance',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: balance >= 0 ? PdfColors.blue : PdfColors.red,
                    ),
                  ),
                  pw.Text(
                    '₹${balance.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: balance >= 0 ? PdfColors.blue : PdfColors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionsTable(List<Transaction> transactions) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: pw.FixedColumnWidth(80),  // Date
        1: pw.FlexColumnWidth(2),   // Title
        2: pw.FixedColumnWidth(60), // Type
        3: pw.FlexColumnWidth(1.5), // Category
        4: pw.FixedColumnWidth(80), // Amount
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Title', isHeader: true),
            _buildTableCell('Type', isHeader: true),
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
          ],
        ),
        // Data rows
        ...transactions.map((transaction) => pw.TableRow(
          children: [
            _buildTableCell(DateFormat('dd/MM/yyyy').format(transaction.date)),
            _buildTableCell(transaction.title),
            _buildTableCell(transaction.type.toString().split('.').last),
            _buildTableCell(transaction.category),
            _buildTableCell(
              '₹${transaction.amount.toStringAsFixed(2)}',
              textColor: transaction.type == TransactionType.income 
                  ? PdfColors.green 
                  : PdfColors.red,
            ),
          ],
        )).toList(),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? textColor}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 12 : 10,
          color: textColor ?? PdfColors.black,
        ),
      ),
    );
  }

  static Future<void> exportMonthlyReport(List<Transaction> transactions, User? user, DateTime month) async {
    final monthTransactions = transactions.where((t) =>
      t.date.year == month.year && t.date.month == month.month
    ).toList();

    await exportToPdf(monthTransactions, user);
  }

  static Future<void> exportYearlyReport(List<Transaction> transactions, User? user, int year) async {
    final yearTransactions = transactions.where((t) => t.date.year == year).toList();

    await exportToPdf(yearTransactions, user);
  }
}
