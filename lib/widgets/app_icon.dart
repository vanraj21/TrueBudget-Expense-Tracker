import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class AppIcon extends StatelessWidget {
  final double size;
  final bool showBackground;

  const AppIcon({
    super.key,
    this.size = 64.0,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBackground
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.success,
                  AppTheme.success.withOpacity(0.8),
                  AppTheme.primary.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(size * 0.22),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.success.withOpacity(0.4),
                  blurRadius: size * 0.3,
                  offset: Offset(0, size * 0.1),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: size * 0.2,
                  offset: Offset(0, size * 0.05),
                ),
              ],
            )
          : null,
      child: Center(
        child: Container(
          width: size * 0.85,
          height: size * 0.85,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(size * 0.18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: size * 0.1,
                offset: Offset(0, size * 0.02),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background gradient circle
              Positioned(
                top: size * 0.05,
                left: size * 0.05,
                child: Container(
                  width: size * 0.75,
                  height: size * 0.75,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 0.8,
                      colors: [
                        AppTheme.success.withOpacity(0.1),
                        AppTheme.success.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(size * 0.15),
                  ),
                ),
              ),
              // Main wallet icon
              Center(
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: size * 0.45,
                  color: AppTheme.success,
                ),
              ),
              // Small accent detail
              Positioned(
                bottom: size * 0.08,
                right: size * 0.08,
                child: Container(
                  width: size * 0.15,
                  height: size * 0.15,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.accent,
                        AppTheme.accent.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(size * 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.3),
                        blurRadius: size * 0.05,
                        offset: Offset(0, size * 0.02),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SimpleAppIcon extends StatelessWidget {
  final double size;

  const SimpleAppIcon({
    super.key,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.success,
            AppTheme.success.withOpacity(0.8),
            AppTheme.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.success.withOpacity(0.3),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.account_balance_wallet_rounded,
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
}

class MinimalAppIcon extends StatelessWidget {
  final double size;
  final Color? backgroundColor;

  const MinimalAppIcon({
    super.key,
    this.size = 24.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.success,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Center(
        child: Icon(
          Icons.account_balance_wallet_rounded,
          size: size * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }
}
