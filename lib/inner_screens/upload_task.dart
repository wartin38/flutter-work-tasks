import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:workos/constants/category_list.dart';
import 'package:workos/constants/my_colors.dart';
import 'package:workos/services/global_methods.dart';
import 'package:workos/widgets/drawer_widget.dart';

class UploadTask extends StatefulWidget {
  @override
  _UploadTaskState createState() => _UploadTaskState();
}

class _UploadTaskState extends State<UploadTask> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _taskCategoryController =
      TextEditingController(text: 'Presiona aquí para seleccionar');
  TextEditingController _taskTitleController = TextEditingController();
  TextEditingController _taskDescriptionController = TextEditingController();
  TextEditingController _deadlineDateController =
      TextEditingController(text: 'Presiona para seleccionar una fecha');
  final _formKey = GlobalKey<FormState>();
  DateTime? datePicked;
  Timestamp? deadlineDateTimeStamp;
  bool _isLoading = false;

  @override
  void dispose() {
    _taskCategoryController.dispose();
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    _deadlineDateController.dispose();
    super.dispose();
  }

  void _uploadTask() async {
    final taskID = Uuid().v4();
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      if (_deadlineDateController.text ==
              'Presiona para seleccionar una fecha' ||
          _taskCategoryController.text == 'Presiona aquí para seleccionar') {
        GlobalMethod.showErrorDialog(
            error: 'Por favor completa todos campos', ctx: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('tasks').doc(taskID).set({
          'taskId': taskID,
          'uploadedBy': _uid,
          'taskTitle': _taskTitleController.text,
          'taskDescription': _taskDescriptionController.text,
          'deadlineDate': _deadlineDateController.text,
          'deadlineDateTimeStamp': deadlineDateTimeStamp,
          'taskCategory': _taskCategoryController.text,
          'taskComments': [],
          'isDone': false,
          'createdAt': Timestamp.now(),
        });
        await Fluttertoast.showToast(
            msg: "Tarea registrada existosamente",
            toastLength: Toast.LENGTH_LONG,
            // gravity: ToastGravity.CENTER,
            // timeInSecForIosWeb: 1,
            backgroundColor: Colors.deepOrange,
            // textColor: Colors.white,
            fontSize: 18.0);
        _taskTitleController.clear();
        _taskDescriptionController.clear();
        setState(() {
          _taskCategoryController.text = 'Presiona aquí para seleccionar';
          _deadlineDateController.text = 'Presiona para seleccionar una fecha';
        });
      } catch (error) {} finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('No es válida');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: MyColors.darkBlue),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(7),
        child: Card(
          child: SingleChildScrollView(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Todos los campos son requeridos',
                      style: TextStyle(
                        color: MyColors.darkBlue,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categoría
                        _textTitle(label: 'Categoría de la tarea*'),
                        _textFormField(
                            valueKey: 'TaskCategory',
                            controller: _taskCategoryController,
                            enabled: false,
                            fct: () {
                              _showTaskCategoriesDialog(size: size);
                            },
                            maxLength: 100),
                        // Título
                        _textTitle(label: 'Título de la tarea*'),
                        _textFormField(
                            valueKey: 'TaskTitle',
                            controller: _taskTitleController,
                            enabled: true,
                            fct: () {},
                            maxLength: 100),
                        // Descripción
                        _textTitle(label: 'Descripción de la tarea*'),
                        _textFormField(
                            valueKey: 'TaskDescription',
                            controller: _taskDescriptionController,
                            enabled: true,
                            fct: () {},
                            maxLength: 500),
                        // Fecha límite de entrega
                        _textTitle(label: 'Fecha límite de entrega*'),
                        _textFormField(
                            valueKey: 'TaskDeadline',
                            controller: _deadlineDateController,
                            enabled: false,
                            fct: () {
                              _pickDateDialog();
                            },
                            maxLength: 100),
                      ],
                    ),
                  ),
                ),

                // Botón
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : MaterialButton(
                            onPressed: _uploadTask,
                            color: Colors.blue.shade800,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Agregar Tarea',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Icon(
                                    Icons.upload,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFormField({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Falta el valor de este campo';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          // initialValue: 'Algún valor',
          style: TextStyle(
              color: MyColors.darkBlue,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
          maxLines: valueKey == 'TaskDescription' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
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
                          setState(() {
                            _taskCategoryController.text =
                                Categories.tasksList[index];
                          });
                          Navigator.pop(context);
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
                child: Text('Cancelar'),
              ),
            ],
          );
        });
  }

  void _pickDateDialog() async {
    datePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        Duration(days: 0),
      ),
      lastDate: DateTime(2100),
    );

    if (datePicked != null) {
      setState(() {
        // _deadlineDateController.text = datePicked!.year.toString();
        _deadlineDateController.text =
            '${datePicked!.day}-${datePicked!.month}-${datePicked!.year}';
        deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(
            datePicked!.microsecondsSinceEpoch);
      });
    }
  }

  Widget _textTitle({required String label}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.blue[800],
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
