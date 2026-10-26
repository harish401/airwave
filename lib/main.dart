import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize libmpv / media_kit for hardware video decoding & custom headers
  MediaKit.ensureInitialized();

  // System chrome status bar & navigation styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Check onboarding state
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_completed') ?? false;

  runApp(
    ProviderScope(
      child: AirwaveApp(showOnboarding: !onboardingDone),
    ),
  );
}

class AirwaveApp extends ConsumerWidget {
  final bool showOnboarding;

  const AirwaveApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = AppRouter.createRouter(showOnboarding: showOnboarding);

    return MaterialApp.router(
      title: 'Airwave',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
