import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:workos/constants/my_colors.dart';
import 'package:workos/services/global_methods.dart';
import 'package:workos/widgets/comments_widget.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String uploadedBy;
  final String taskID;

  const TaskDetailsScreen({required this.uploadedBy, required this.taskID});

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  var _contentStyle = TextStyle(
      color: MyColors.darkBlue, fontSize: 13, fontWeight: FontWeight.normal);
  var _titleStyle = TextStyle(
      color: MyColors.darkBlue, fontSize: 20, fontWeight: FontWeight.bold);
  TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;
  // Usuario que publicó la tarea:
  String? authorName;
  String? authorPosition;
  String? userImageUrl;
  String? taskCategory;
  String? taskTitle;
  String? taskDescription;
  bool? _isDone;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? deadlineDate;
  bool isDeadlineAvailable = false;

  // Usuario que hace el comentario:
  FirebaseAuth? _auth = FirebaseAuth.instance;
  String? commenterId;
  String? commenterName;
  String? commenterImage;

  @override
  void initState() {
    getTaskData();
    super.initState();
  }

  void getTaskData() async {
    // Usuario que creo la tarea
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();
    if (userDoc == null) {
      return;
    } else {
      setState(() {
        authorName = userDoc.get('name');
        authorPosition = userDoc.get('positionInCompany');
        userImageUrl = userDoc.get('userImage');
      });
    }
    // Usuario que hace el comentario
    User? user = _auth!.currentUser;
    final _commenterUid = user!.uid;
    final DocumentSnapshot commenterDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_commenterUid)
        .get();
    if (userDoc == null) {
      return;
    } else {
      setState(() {
        commenterId = commenterDoc.get('id');
        commenterName = commenterDoc.get('name');
        commenterImage = commenterDoc.get('userImage');
      });
    }
    final DocumentSnapshot taskDatabase = await FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.taskID)
        .get();
    if (taskDatabase == null) {
      return;
    } else {
      setState(() {
        taskTitle = taskDatabase.get('taskTitle');
        taskDescription = taskDatabase.get('taskDescription');
        _isDone = taskDatabase.get('isDone');
        postedDateTimeStamp = taskDatabase.get('createdAt');
        deadlineDateTimeStamp = taskDatabase.get('deadlineDateTimeStamp');
        deadlineDate = taskDatabase.get('deadlineDate');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.day}-${postDate.month}-${postDate.year}';
      });

      var date = deadlineDateTimeStamp!.toDate();
      isDeadlineAvailable = date.isAfter(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Atras',
            style: TextStyle(
              color: MyColors.darkBlue,
              fontSize: 23,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Text(
              taskTitle == null ? 'Título de la Tarea' : taskTitle!,
              style: TextStyle(
                  color: MyColors.darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Subido por ',
                            style: TextStyle(
                                color: MyColors.darkBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Spacer(),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 3,
                                color: Colors.blue.shade700,
                              ),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(
                                    userImageUrl == null
                                        ? 'https://image.flaticon.com/icons/png/512/1071/1071066.png'
                                        : userImageUrl!,
                                  ),
                                  fit: BoxFit.fill),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName == null ? '' : authorName!,
                                style: _contentStyle,
                              ),
                              Text(
                                authorPosition == null ? '' : authorPosition!,
                                style: _contentStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                      dividerWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subido el:',
                            style: _titleStyle,
                          ),
                          Text(
                            postedDate == null ? '' : postedDate!,
                            style: TextStyle(
                                color: MyColors.darkBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fecha límite:',
                            style: _titleStyle,
                          ),
                          Text(
                            deadlineDate == null ? '' : deadlineDate!,
                            style: TextStyle(
                                color: MyColors.darkBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          isDeadlineAvailable
                              ? 'La fecha límite no ha sido alcanzada'
                              : 'La fecha límite ha pasado',
                          style: TextStyle(
                              color: isDeadlineAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 15),
                        ),
                      ),
                      dividerWidget(),
                      Text(
                        'Estado de la tarea:',
                        style: _titleStyle,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              if (commenterId == widget.uploadedBy) {
                                try {
                                  FirebaseFirestore.instance
                                      .collection('tasks')
                                      .doc(widget.taskID)
                                      .update({'isDone': true});
                                } catch (error) {
                                  GlobalMethod.showErrorDialog(
                                      error: 'Esta acción no se pudo ejecutar',
                                      ctx: context);
                                }
                              } else {
                                GlobalMethod.showErrorDialog(
                                    error:
                                        'No estás autorizado para cambiar el status',
                                    ctx: context);
                              }
                              getTaskData();
                            },
                            child: Text(
                              'Completada',
                              style: TextStyle(
                                  color: MyColors.darkBlue,
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Opacity(
                            opacity: _isDone == true ? 1 : 0,
                            child: Icon(
                              Icons.check_box,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          TextButton(
                            onPressed: () {
                              if (commenterId == widget.uploadedBy) {
                                try {
                                  FirebaseFirestore.instance
                                      .collection('tasks')
                                      .doc(widget.taskID)
                                      .update({'isDone': false});
                                } catch (error) {
                                  GlobalMethod.showErrorDialog(
                                      error: 'Esta acción no se pudo ejecutar',
                                      ctx: context);
                                }
                              } else {
                                GlobalMethod.showErrorDialog(
                                    error:
                                        'No estás autorizado para cambiar el status',
                                    ctx: context);
                              }
                              getTaskData();
                            },
                            child: Text(
                              'No Completada',
                              style: TextStyle(
                                  color: MyColors.darkBlue,
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Opacity(
                            opacity: _isDone == false ? 1 : 0,
                            child: Icon(
                              Icons.check_box,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      dividerWidget(),
                      Text(
                        'Descripción de la Tarea:',
                        style: _titleStyle,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        taskDescription == null ? '' : taskDescription!,
                        style: _contentStyle,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      AnimatedSwitcher(
                        duration: Duration(
                          milliseconds: 500,
                        ),
                        child: _isCommenting
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: TextField(
                                      controller: _commentController,
                                      style:
                                          TextStyle(color: MyColors.darkBlue),
                                      maxLength: 200,
                                      keyboardType: TextInputType.text,
                                      maxLines: 6,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: MaterialButton(
                                            onPressed: () async {
                                              if (_commentController
                                                      .text.length <
                                                  1) {
                                                GlobalMethod.showErrorDialog(
                                                    error:
                                                        'El comentario no puede estar vacío',
                                                    ctx: context);
                                              } else {
                                                // ****** HERE ****************
                                                final _generatedId =
                                                    Uuid().v4();
                                                await FirebaseFirestore.instance
                                                    .collection('tasks')
                                                    .doc(widget.taskID)
                                                    .update({
                                                  'taskComments':
                                                      FieldValue.arrayUnion([
                                                    {
                                                      'userId': commenterId,
                                                      'commentId': _generatedId,
                                                      'name': commenterName,
                                                      'userImageUrl':
                                                          commenterImage,
                                                      'commentBody':
                                                          _commentController
                                                              .text,
                                                      'time': Timestamp.now(),
                                                    }
                                                  ])
                                                });
                                                await Fluttertoast.showToast(
                                                    msg:
                                                        "Tu comentario ha sido agregado",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    // gravity: ToastGravity.CENTER,
                                                    // timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.deepOrange,
                                                    // textColor: Colors.white,
                                                    fontSize: 18.0);
                                                _commentController.clear();
                                              }
                                              setState(() {
                                                _isCommenting = !_isCommenting;
                                              });
                                            },
                                            color: Colors.blue.shade700,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Text(
                                              'Publicar',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _isCommenting = !_isCommenting;
                                            });
                                          },
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      _isCommenting = !_isCommenting;
                                    });
                                  },
                                  color: Colors.blue.shade700,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    child: Text(
                                      'Agrega un comentario',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('tasks')
                              .doc(widget.taskID)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.data == null) {
                              return Center(
                                child:
                                    Text('No hay comentarios para esta tarea'),
                              );
                            }
                            return ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return CommentWidget(
                                    commentId: snapshot.data!['taskComments']
                                        [index]['commentId'],
                                    commenterId: snapshot.data!['taskComments']
                                        [index]['userId'],
                                    commentBody: snapshot.data!['taskComments']
                                        [index]['commentBody'],
                                    commenterImageUrl:
                                        snapshot.data!['taskComments'][index]
                                            ['userImageUrl'],
                                    commenterName: snapshot
                                        .data!['taskComments'][index]['name'],
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    thickness: 1,
                                  );
                                },
                                itemCount:
                                    snapshot.data!['taskComments'].length);
                          })
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dividerWidget() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
