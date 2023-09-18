import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/screen_routes.dart';
import 'injection_container.dart' as injection_container;


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  injection_container.init();
  runApp(const MyApp());
}

const double kMargin = 16.0;
const double kPageContentWidth = 600;
const double kIconSize = 22.0;

final navigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter with Mysql',
      debugShowCheckedModeBanner: false,
      initialRoute: ScreenRoutes.loading, /// Check this file to see how the App starts: lib/features/loading/screens/loading_screen.dart
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'RedHatDisplay',
      ),
      routes: screenRoutes,
      navigatorKey: navigatorKey,
    );
  }
}
