import 'package:flutter/material.dart';
import 'package:smart_home/apis/dio.dart';
import 'package:smart_home/routes.dart';

void main() {
  configureDio();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
              color: Colors.blue,
              titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              iconTheme: IconThemeData(color: Colors.white))),
      routes: getPages(context),
      initialRoute: '/',
    );
  }
}
