import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../themes/app_theme.dart';

class PinAuthScreen extends StatefulWidget {
  const PinAuthScreen({super.key});

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> {
  final _pinController = TextEditingController();
  bool _showPin = false;
  int _failedAttempts = 0;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_pinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter 4-digit PIN'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.authenticateWithPin(_pinController.text);

    if (!success) {
      setState(() => _failedAttempts++);
      if (_failedAttempts >= 3) {
        _showTooManyAttemptsDialog();
      }
    }
  }

  void _showTooManyAttemptsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: Text(
          'Too Many Failed Attempts',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'You have entered the wrong PIN too many times. Please try again later.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _failedAttempts = 0);
            },
            child: Text(
              'OK',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        color: AppTheme.darkBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildAppIcon(),
                const SizedBox(height: 40),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.dmSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your PIN to access your financial data',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                _buildPinInput(),
                const SizedBox(height: 24),
                if (provider.errorMessage != null) ...[
                  _buildErrorMessage(),
                  const SizedBox(height: 24),
                ],
                _buildBiometricOption(),
                const SizedBox(height: 40),
                _buildLoginButton(),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 120,
      height: 120,
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
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppTheme.success.withOpacity(0.4),
            blurRadius: 36,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 102,
          height: 102,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: 54,
            color: AppTheme.success,
          ),
        ),
      ),
    );
  }

  Widget _buildPinInput() {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: provider.errorMessage != null 
                  ? AppTheme.error.withOpacity(0.5)
                  : AppTheme.darkBorder,
              width: provider.errorMessage != null ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: !_showPin,
            maxLength: 4,
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: 12,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '••••',
              hintStyle: GoogleFonts.dmSans(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTertiary,
                letterSpacing: 12,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              counterText: '',
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.lock_rounded,
                  color: provider.errorMessage != null 
                      ? AppTheme.error 
                      : AppTheme.textSecondary,
                  size: 24,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _showPin ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () => setState(() => _showPin = !_showPin),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            onSubmitted: (_) => _authenticate(),
            onChanged: (value) {
              if (provider.errorMessage != null) {
                provider.clearError();
              }
              if (value.length == 4) {
                _authenticate();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage() {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        if (provider.errorMessage == null) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.error.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppTheme.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  provider.errorMessage!,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.error,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBiometricOption() {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        if (!provider.biometricAvailable) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final success = await provider.authenticateWithBiometrics(
                  'Use your biometric to login',
                );
                if (!success && provider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage!),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fingerprint_rounded,
                    color: AppTheme.accent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Use Biometric',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: provider.isLoading ? null : _authenticate,
              child: Center(
                child: provider.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textWhite),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Unlocking...',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textWhite,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login_rounded,
                            color: AppTheme.textWhite,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Unlock',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textWhite,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
