import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workos/constants/my_colors.dart';
import 'package:workos/inner_screens/profile.dart';
import 'package:workos/inner_screens/upload_task.dart';
import 'package:workos/screens/all_workers.dart';
import 'package:workos/screens/tasks_screen.dart';

import '../user_state.dart';

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.cyan),
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Image.network(
                      'https://image.flaticon.com/icons/png/512/2924/2924763.png'),
                ),
                SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: Text(
                    'Administrador de Tareas',
                    style: TextStyle(
                      color: MyColors.darkBlue,
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          _listTile(
              fct: () {
                _navigateToAllTaskScreen(context);
              },
              icon: Icons.task_outlined,
              label: 'Todas las Tareas'),
          _listTile(
              fct: () {
                _navigateToProfileScreen(context);
              },
              icon: Icons.settings_outlined,
              label: 'Mi Cuenta'),
          _listTile(
              fct: () {
                _navigateToAllWorkersScreen(context);
              },
              icon: Icons.workspaces_outlined,
              label: 'Trabajadores Registrados'),
          _listTile(
              fct: () {
                _navigateToAddTaskScreen(context);
              },
              icon: Icons.add_task,
              label: 'Agregar Tarea'),
          Divider(
            thickness: 1,
          ),
          _listTile(
              fct: () {
                _logout(context);
              },
              icon: Icons.logout,
              label: 'Cerrar Sesión'),
        ],
      ),
    );
  }

  void _navigateToProfileScreen(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    final String uid = user!.uid;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userID: uid,
        ),
      ),
    );
  }

  void _navigateToAllWorkersScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AllWorkersScreen(),
      ),
    );
  }

  void _navigateToAllTaskScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TasksScreen(),
      ),
    );
  }

  void _navigateToAddTaskScreen(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadTask()),
    );
  }

  void _logout(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    // ícono de logout
                    'https://image.flaticon.com/icons/png/512/992/992511.png',
                    height: 20,
                    width: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
            content: Text(
              '¿Quieres cerrar tu sesión?',
              style: TextStyle(
                  color: MyColors.darkBlue,
                  fontSize: 20,
                  fontStyle: FontStyle.italic),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // ignore: unnecessary_statements
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  _auth.signOut();
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserState(),
                    ),
                  );
                },
                child: Text('Si'),
              ),
            ],
          );
        });
  }

  Widget _listTile(
      {required Function fct, required IconData icon, required String label}) {
    return ListTile(
      onTap: () {
        fct();
      },
      leading: Icon(
        icon,
        color: MyColors.darkBlue,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: MyColors.darkBlue,
          fontSize: 20,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
