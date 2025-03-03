import 'package:a_terminal/l10n/output/l10n.dart';
import 'package:a_terminal/logic.dart';
import 'package:a_terminal/pages/scaffold/page.dart';
import 'package:a_terminal/router/router.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:toastification/toastification.dart';

class App extends StatelessWidget {
  const App({super.key, required this.defaultPath});

  final String defaultPath;

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MultiProvider(
        providers: [
          Provider(
            create: (context) => AppLogic(context, defaultPath),
            dispose: (context, logic) => logic.dispose(),
            lazy: false,
          ),
          Provider(
            create: (context) => AppRouteLogic(context),
            dispose: (context, logic) => logic.dispose(),
            lazy: false,
          ),
        ],
        builder: (context, _) {
          final logic = context.read<AppLogic>();
          final isWideScreen = MediaQuery.sizeOf(context).width >= 768.0;
          logic.updateScreenState(isWideScreen);

          return ListenableBuilder(
            listenable: logic.settings.listenable,
            builder: (context, child) {
              return SystemThemeBuilder(
                builder: (context, systemAccent) {
                  return MaterialApp(
                    onGenerateTitle: (context) => 'appTitle'.tr(context),
                    themeMode: logic.settings.themeMode,
                    theme: ThemeData.from(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: logic.settings.useDynamicColor
                            ? systemAccent.accent
                            : logic.settings.fallBackColor,
                        brightness: Brightness.light,
                      ),
                      useMaterial3: true,
                    ),
                    darkTheme: ThemeData.from(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: logic.settings.useDynamicColor
                            ? systemAccent.accent
                            : logic.settings.fallBackColor,
                        brightness: Brightness.dark,
                      ),
                      useMaterial3: true,
                    ),
                    debugShowCheckedModeBanner: false,
                    supportedLocales: AppL10n.supportedLocales,
                    localizationsDelegates: AppL10n.localizationsDelegates,
                    home: child,
                  );
                },
              );
            },
            child: const ScaffoldPage(),
          );
        },
      ),
    );
  }
}
