import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workos/user_state.dart';
// import 'package:workos/screens/tasks_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text('La aplicación se está iniciando...'),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text('Ha ocurrido un error'),
              ),
            ),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter workos',
          theme: ThemeData(
            scaffoldBackgroundColor: Color(0xFFEDE7DC),
            primarySwatch: Colors.blue,
          ),
          home: UserState(),
        );
      },
    );
  }
}
