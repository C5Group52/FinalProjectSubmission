import 'package:flutter/cupertino.dart'
    show CupertinoLocalizations, DefaultCupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'l10n/app_localizations.dart';

/// Flutter's own `DefaultMaterialLocalizations.delegate` hard-codes
/// `isSupported` to English only (`languageCode == 'en'`), so it never
/// actually kicks in as a fallback for a locale like Somali that Flutter
/// doesn't ship translations for. This wrapper always says yes and always
/// loads the English content regardless of the requested locale — it's
/// only used for locales none of the real Global*Localizations support.
class _AnyLocaleMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _AnyLocaleMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      DefaultMaterialLocalizations.load(locale);

  @override
  bool shouldReload(_AnyLocaleMaterialLocalizationsDelegate old) => false;
}

/// Same problem, same fix, for Cupertino widgets (e.g. text field toolbars).
class _AnyLocaleCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _AnyLocaleCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(_AnyLocaleCupertinoLocalizationsDelegate old) => false;
}

class SomTalentApp extends ConsumerWidget {
  const SomTalentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      title: 'SomTalent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: Locale(settings.language),
      // Flutter's SDK-bundled Material/Widgets/Cupertino translations don't
      // cover Somali. Forcing `locale` directly (rather than letting
      // MaterialApp resolve it against supportedLocales) skips its usual
      // fallback, so without these delegates every framework widget that
      // needs e.g. MaterialLocalizations (AppBar, NavigationBar) crashes
      // with "No MaterialLocalizations found" once `so` is selected. They're
      // listed after the Global ones so real translations still win for
      // languages Flutter does ship (English).
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        const _AnyLocaleMaterialLocalizationsDelegate(),
        DefaultWidgetsLocalizations.delegate,
        const _AnyLocaleCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}