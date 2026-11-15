import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_template.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const MyApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppTemplate _template = kDaftarTemplate.first;
  String? _pinTersimpan;
  bool _sudahTerbuka = false;
  bool _loadingAwal = true;

  @override
  void initState() {
    super.initState();
    _muatPreferensiAwal();
  }

  Future<void> _muatPreferensiAwal() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTpl = prefs.getString('selected_template_id');
    final oldDark = prefs.getBool('is_dark_mode');
    final pin = prefs.getString('app_pin');

    AppTemplate terpilih;
    if (savedTpl != null) {
      terpilih = cariTemplateById(savedTpl);
    } else if (oldDark == false) {
      terpilih = cariTemplateById('pearl_alabaster');
    } else {
      terpilih = kDaftarTemplate.first;
    }

    setState(() {
      _template = terpilih;
      _pinTersimpan = (pin != null && pin.length == 4) ? pin : null;
      _sudahTerbuka = _pinTersimpan == null;
      _loadingAwal = false;
    });
  }

  Future<void> _pilihTemplate(AppTemplate baru) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _template = baru;
    });
    await prefs.setString('selected_template_id', baru.id);
  }

  Future<void> _ubahPin(String? pinBaru) async {
    final prefs = await SharedPreferences.getInstance();
    if (pinBaru == null || pinBaru.length != 4) {
      await prefs.remove('app_pin');
      setState(() {
        _pinTersimpan = null;
        _sudahTerbuka = true;
      });
    } else {
      await prefs.setString('app_pin', pinBaru);
      setState(() {
        _pinTersimpan = pinBaru;
        _sudahTerbuka = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _template;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DompetKu',
      scrollBehavior: const AppScrollBehavior(),
      themeAnimationDuration: const Duration(milliseconds: 380),
      themeAnimationCurve: Curves.easeOutCubic,
      themeMode: t.isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: t.bgColor,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: const ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: t.primaryColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: t.bgColor,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: const ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: t.primaryColor,
          brightness: Brightness.dark,
        ),
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: _loadingAwal
            ? const Scaffold(
                key: ValueKey('loading'),
                body: Center(child: CircularProgressIndicator()),
              )
            : (!_sudahTerbuka && _pinTersimpan != null)
                ? PinLockScreen(
                    key: const ValueKey('pin_screen'),
                    pinBenar: _pinTersimpan!,
                    template: t,
                    onBerhasil: () => setState(() => _sudahTerbuka = true),
                  )
                : MainShell(
                    key: const ValueKey('main_shell'),
                    template: t,
                    onPilihTemplate: _pilihTemplate,
                    pinAktif: _pinTersimpan != null,
                    onUbahPin: _ubahPin,
                  ),
      ),
    );
  }
}
