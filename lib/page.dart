import 'package:a_terminal/l10n/output/l10n.dart';
import 'package:a_terminal/logic.dart';
import 'package:a_terminal/models/setting.dart';
import 'package:a_terminal/pages/scaffold/page.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:toastification/toastification.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: ChangeNotifierProvider(
        create: (context) => AppLogic(context: context),
        lazy: true,
        builder: (context, _) {
          final logic = context.read<AppLogic>();
          return FutureBuilder(
            future: logic.init(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                throw Exception(snapshot.error);
              }
              return ValueListenableBuilder(
                valueListenable: logic.currentSetting,
                builder: (context, setting, child) {
                  return SystemThemeBuilder(
                    builder: (context, systemAccent) {
                      return MaterialApp(
                        onGenerateTitle: (context) => 'appTitle'.tr(context),
                        themeMode: setting.themeMode,
                        theme: ThemeData(
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: _switchColor(setting)
                                ? systemAccent.accent
                                : setting.accentColor,
                            brightness: Brightness.light,
                          ),
                          fontFamily: GoogleFonts.notoSansSc().fontFamily,
                          useMaterial3: true,
                        ),
                        darkTheme: ThemeData(
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: _switchColor(setting)
                                ? systemAccent.accent
                                : setting.accentColor,
                            brightness: Brightness.dark,
                          ),
                          fontFamily: GoogleFonts.notoSansSc().fontFamily,
                          useMaterial3: true,
                        ),
                        debugShowCheckedModeBanner: false,
                        supportedLocales: AppL10n.supportedLocales,
                        localizationsDelegates: AppL10n.localizationsDelegates,
                        localeResolutionCallback: (locale, supportedLocales) {
                          if (!supportedLocales.contains(locale)) {
                            return const Locale('en', 'US');
                          }
                          return locale;
                        },
                        home: child,
                      );
                    },
                  );
                },
                child: const ScaffoldPage(),
              );
            },
          );
        },
      ),
    );
  }

  bool _switchColor(SettingModel setting) =>
      defaultTargetPlatform.supportsAccentColor && setting.useSystemAccent;
}
