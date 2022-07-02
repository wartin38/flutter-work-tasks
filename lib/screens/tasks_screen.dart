import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workos/constants/category_list.dart';
import 'package:workos/constants/my_colors.dart';
import 'package:workos/widgets/drawer_widget.dart';
import 'package:workos/widgets/task_widget.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        // Forma alternativa de colocar el ícono:
        // leading: Builder(
        //   builder: (ctx) {
        //     return IconButton(
        //       icon: Icon(
        //         Icons.menu,
        //         color: Colors.black,
        //       ),
        //       onPressed: () {
        //         Scaffold.of(ctx).openDrawer();
        //       },
        //     );
        //   },
        // ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Tareas',
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _showTaskCategoriesDialog(size: size);
              },
              icon: Icon(Icons.filter_list_outlined, color: Colors.black))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TaskWidget(
                      taskTitle: snapshot.data!.docs[index]['taskTitle'],
                      taskDescription: snapshot.data!.docs[index]
                          ['taskDescription'],
                      taskId: snapshot.data!.docs[index]['taskId'],
                      uploadedBy: snapshot.data!.docs[index]['uploadedBy'],
                      isDone: snapshot.data!.docs[index]['isDone'],
                    );
                  });
            } else {
              return Center(
                child: Text('No hay ninguna tarea registrada'),
              );
            }
          }
          return Center(
              child: Text(
            'Algo salió mal',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ));
        },
      ),
    );
  }

  _showTaskCategoriesDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'Categoria de la Tarea',
              style: TextStyle(fontSize: 20, color: Colors.blue.shade800),
            ),
            content: Container(
                width: size.width * 0.9,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: Categories.tasksList.length,
                    itemBuilder: (ctxx, index) {
                      return InkWell(
                        onTap: () {
                          print(
                              'tasksList[index], ${Categories.tasksList[index]}');
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.blue.shade200,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                Categories.tasksList[index],
                                style: TextStyle(
                                    color: MyColors.darkBlue,
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
            actions: [
              TextButton(
                onPressed: () {
                  // ignore: unnecessary_statements
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: Text('Cerrar'),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Cancelar filtro'),
              ),
            ],
          );
        });
  }
}
