import 'package:flutter/material.dart';
import 'package:meeter/screens/authUiCOmponents/confirmEmail.dart';
import 'package:meeter/screens/authUiCOmponents/forgotPassword.dart';

import 'package:meeter/screens/events_page.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'screens/home_page.dart';
import 'screens/authUI.dart';
import 'screens/meet_screen.dart';
import 'utils/authStatusNotifier.dart';
import 'utils/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Vx.setPathUrlStrategy();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool isLightTheme = prefs.getBool('isLightTheme') ?? false;

  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(isLightTheme: isLightTheme),
    child: AppStart(),
  ));
}

class AppStart extends StatelessWidget {
  const AppStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStatusNotifier()),
        ChangeNotifierProvider(create: (_) => AppStateNotifier()),
      ],
      child: MyApp(
        themeProvider: themeProvider,
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final ThemeProvider themeProvider;

  const MyApp({Key? key, required this.themeProvider}) : super(key: key);
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigator = VxNavigator(
    notFoundPage: (uri, params) => MaterialPage(
      key: ValueKey('not-found-page'),
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Page ${uri.path} not found'),
          ),
        ),
      ),
    ),
    routes: {
      '/': (uri, params) => MaterialPage(child: MyHomePage(title: 'Meeter')),
      '/forgot-password': (uri, params) =>
          MaterialPage(child: ForgotPassword()),
      '/confirm-email': (uri, params) => MaterialPage(child: ConfirmEmail()),
      '/schedule': (uri, params) => MaterialPage(child: EventPage()),
      '/signup': (uri, params) => MaterialPage(
              child: SignInSignUpFlow(
            inDialogMode: true,
          )),
      '/meet': (uri, params) => MaterialPage(
            child: Meeting(
              id: uri.queryParameters['id'] ?? params['id'],
              subject: uri.queryParameters['sub'] ?? params['sub'],
            ),
          )
    },
  );
  @override
  void initState() {
    AuthStatusNotifier();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: widget.themeProvider.themeData(),
      title: 'Meeter',
      routerDelegate: navigator,
      routeInformationParser: VxInformationParser(),
    );
  }
}
