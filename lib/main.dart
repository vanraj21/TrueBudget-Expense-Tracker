import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'themes/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/user_provider.dart';
import 'providers/upcoming_payment_provider.dart';
import 'providers/saving_plan_provider.dart';
import 'providers/auth_provider.dart';
import 'services/database_service.dart';
import 'services/encryption_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pin_auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.initialize();
  await EncryptionService().initialize();

  runApp(const TrueBudgetApp());
}

class TrueBudgetApp extends StatelessWidget {
  const TrueBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UpcomingPaymentProvider()),
        ChangeNotifierProvider(create: (_) => SavingPlanProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'TrueBudget',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // Default to dark theme for premium Smarta-style UI
            home: const AuthWrapper(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/welcome': (context) => const WelcomeScreen(),
              '/pin_auth': (context) => const PinAuthScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // If still loading, show a loading screen
        if (authProvider.isLoading) {
          return Scaffold(
            backgroundColor: AppTheme.darkBackground,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.success,
                          AppTheme.success.withOpacity(0.8),
                          AppTheme.primary.withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 36,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'TrueBudget',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                  ),
                ],
              ),
            ),
          );
        }

        // If user has PIN set, show PIN authentication screen
        if (authProvider.hasPin && !authProvider.isAuthenticated) {
          return const PinAuthScreen();
        }

        // If no PIN set, show welcome screen for first-time setup
        if (!authProvider.hasPin) {
          return const WelcomeScreen();
        }

        // If authenticated, show home screen
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        // Default to welcome screen
        return const WelcomeScreen();
      },
    );
  }
}
