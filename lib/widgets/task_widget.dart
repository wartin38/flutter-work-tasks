import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workos/constants/my_colors.dart';
import 'package:workos/inner_screens/task_details.dart';
import 'package:workos/services/global_methods.dart';

class TaskWidget extends StatefulWidget {
  final String taskTitle;
  final String taskDescription;
  final String taskId;
  final String uploadedBy;
  final bool isDone;

  const TaskWidget(
      {required this.taskTitle,
      required this.taskDescription,
      required this.taskId,
      required this.uploadedBy,
      required this.isDone});

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailsScreen(
                taskID: widget.taskId,
                uploadedBy: widget.uploadedBy,
              ),
            ),
          );
        },
        onLongPress: _deleteDialog,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
              border: Border(
            right: BorderSide(width: 1),
          )),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: Image.network(widget.isDone
                ? 'https://image.flaticon.com/icons/png/128/390/390973.png'
                : 'https://image.flaticon.com/icons/png/512/2919/2919780.png'),
          ),
        ),
        title: Text(
          widget.taskTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: MyColors.darkBlue,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.linear_scale_outlined,
              color: Colors.blue.shade800,
            ),
            Text(
              widget.taskDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }

  _deleteDialog() {
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(actions: [
            TextButton(
                onPressed: () async {
                  try {
                    if (widget.uploadedBy == _uid) {
                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(widget.taskId)
                          .delete();
                      await Fluttertoast.showToast(
                          msg: "Tarea borrada",
                          toastLength: Toast.LENGTH_LONG,
                          // gravity: ToastGravity.CENTER,
                          // timeInSecForIosWeb: 1,
                          backgroundColor: Colors.deepOrange,
                          // textColor: Colors.white,
                          fontSize: 18.0);
                      Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
                    } else {
                      GlobalMethod.showErrorDialog(
                          error: 'No puedes borrar esta tarea', ctx: ctx);
                    }
                  } catch (error) {
                    GlobalMethod.showErrorDialog(
                        error: 'La tarea NO se borró', ctx: context);
                  } finally {}
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    Text(
                      'Borrar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                )),
          ]);
        });
  }
}
