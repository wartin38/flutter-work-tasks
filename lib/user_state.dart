import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workos/screens/auth/login.dart';
import 'package:workos/screens/tasks_screen.dart';

class UserState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.data == null) {
            print('El usuario no ha iniciado sesión');
            return Login();
          } else if (userSnapshot.hasData) {
            print('Usuario con sesión ya iniciada');
            return TasksScreen();
          } else if (userSnapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Ha ocurrido un error'),
              ),
            );
          } else if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            body: Center(
              child: Text('Ocurrió un error'),
            ),
          );
        });
  }
}
