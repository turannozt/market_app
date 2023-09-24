import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:market/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Intl.defaultLocale = 'tr_TR';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     
        // Türkçe dil desteğini ekleyin
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', ''), // Türkçe dilini ekleyin
          // Diğer dilleri de ekleyebilirsiniz
          // const Locale('en', ''), // İngilizce dilini ekleyin
        ],
        debugShowCheckedModeBanner: false,
        title: 'Market App',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.indigo,
        ),
        home: const HomeScreen());
  }
}
