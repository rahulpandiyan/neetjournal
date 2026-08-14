import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared chrome for the login / signup screens: brand header on a soft
/// gradient, then the form content in a scrollable column.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.35),
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0, 0.42, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The Google "G" icon from the SVG drawable.
class GoogleG extends StatelessWidget {
  const GoogleG({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    // Use black for light mode (white button), white for dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : const Color(0xFF1F2937);

    return SvgPicture.asset(
      'assets/svg/google_logo.svg',
      width: size,
      height: size,
      color: iconColor,
    );
  }
}

/// Modern bento-style Google sign-in button with skeletonism design.
/// Clean card, soft shadows, and sleek typography.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Google',
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2A2D27)
              : const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF3D4237).withValues(alpha: 0.8)
                : const Color(0xFFE8EBE6),
            width: 1,
          ),
          boxShadow: [
            // Soft inner highlight
            BoxShadow(
              color: Colors.white.withValues(alpha: isDark ? 0.02 : 0.9),
              offset: const Offset(-2, -2),
              blurRadius: 8,
            ),
            // Soft outer shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              offset: const Offset(2, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF4285F4),
                ),
              )
            else
              const GoogleG(size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: 'DMSans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
