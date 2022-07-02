import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:workos/constants/jobs_list.dart';
import 'package:workos/constants/my_colors.dart';
import 'package:workos/services/global_methods.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
// with TickerProviderStateMixin {
  // late AnimationController _animationController;
  // late Animation<double> _animation;
  late TextEditingController _nameTextController =
      TextEditingController(text: '');
  late TextEditingController _emailTextController =
      TextEditingController(text: '');
  late TextEditingController _passTextController =
      TextEditingController(text: '');
  late TextEditingController _confirmPassTextController =
      TextEditingController(text: '');
  late TextEditingController _positionCPTextController =
      TextEditingController(text: '');
  late TextEditingController _phoneNumberController =
      TextEditingController(text: '');

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passFocusNode = FocusNode();
  FocusNode _confirmPassFocusNode = FocusNode();
  FocusNode _positionCPFocusNode = FocusNode();
  FocusNode _phoneNumberFocusNode = FocusNode();

  bool _obscureText = true;
  bool _anotherObscureText = true;
  final _signUpFormKey = GlobalKey<FormState>();
  File? imageFile;
  XFile? _pickedFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? imageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    // _animationController.dispose();
    _nameTextController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _confirmPassTextController.dispose();
    _positionCPTextController.dispose();
    _phoneNumberController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _confirmPassFocusNode.dispose();
    _positionCPFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  // @override
  // void initState() {
  //   _animationController =
  //       AnimationController(vsync: this, duration: Duration(seconds: 20));
  //   _animation =
  //       CurvedAnimation(parent: _animationController, curve: Curves.linear)
  //         ..addListener(() {
  //           setState(() {});
  //         })
  //         ..addStatusListener((animationStatus) {
  //           if (animationStatus == AnimationStatus.completed) {
  //             _animationController.reset();
  //             _animationController.forward();
  //           }
  //         });
  //   _animationController.forward();
  //   super.initState();
  // }

  void _submitFormOnSignUp() async {
    final isValid = _signUpFormKey.currentState!.validate();
    if (isValid) {
      if (imageFile == null) {
        GlobalMethod.showErrorDialog(
            error: 'Por favor selecciona una imagen', ctx: context);
        return;
      }
      if (_passTextController.text != _confirmPassTextController.text) {
        GlobalMethod.showErrorDialog(
            error: 'Los passwords no coinciden. Verifícalos por favor',
            ctx: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.createUserWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _passTextController.text.trim());
        final User? user = _auth.currentUser;
        final _uid = user!.uid;
        final ref = FirebaseStorage.instance
            .ref()
            .child('userImages')
            .child(_uid + 'jpg');
        await ref.putFile(imageFile!);
        imageUrl = await ref.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(_uid).set({
          'id': _uid,
          'name': _nameTextController.text,
          'email': _emailTextController.text,
          'userImage': imageUrl,
          'phoneNumber': _phoneNumberController.text,
          'positionInCompany': _positionCPTextController.text,
          'createdAt': Timestamp.now(),
        });
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (errorr) {
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(error: errorr.toString(), ctx: context);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        // backgroundColor: Colors.blue,
        body: Stack(
      children: [
        // CachedNetworkImage(
        //   // imageUrl: 'https://picsum.photos/id/766/1440/?blur=9',
        //   imageUrl: 'https://picsum.photos/id/983/1440/?blur=4',
        //   placeholder: (context, url) => Image.asset(
        //     'assets/images/background2.jpg',
        //     fit: BoxFit.fill,
        //   ),
        //   errorWidget: (context, url, error) => Icon(Icons.error),
        //   width: double.infinity,
        //   height: double.infinity,
        //   fit: BoxFit.cover,
        //   alignment: FractionalOffset(_animation.value, 0),
        // ),
        Image.asset(
          'assets/images/cubes.gif',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill,
        ),
        Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: ListView(children: [
              SizedBox(
                height: size.height * 0.05,
              ),
              Text(
                'Registro',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Ya tengo una cuenta',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    TextSpan(text: '     '),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.canPop(context)
                            ? Navigator.pop(context)
                            : null,
                      text: 'Ingresar',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Form(
                key: _signUpFormKey,
                child: Column(
                  children: [
                    // Name
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_emailFocusNode),
                            keyboardType: TextInputType.name,
                            controller: _nameTextController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Falta completar este campo';
                              } else {
                                return null;
                              }
                            },
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Nombre',
                              hintStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: size.width * 0.24,
                                height: size.width * 0.24,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: imageFile == null
                                      ? Image.network(
                                          'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png',
                                          fit: BoxFit.fill,
                                        )
                                      : Image.file(
                                          imageFile!,
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () {
                                  _showImageDialog();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      imageFile == null
                                          ? Icons.add_a_photo
                                          : Icons.edit_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    // Email
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(_passFocusNode),
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailTextController,
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Ingresa una dirección de correo electrónico válida';
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    // Password
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(_confirmPassFocusNode),
                      focusNode: _passFocusNode,
                      obscureText: _obscureText,
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passTextController,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Debe ser de al menos 7 caracteres, números o letras';
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black,
                          ),
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    // Confirm password
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(_phoneNumberFocusNode),
                      focusNode: _confirmPassFocusNode,
                      obscureText: _anotherObscureText,
                      keyboardType: TextInputType.visiblePassword,
                      controller: _confirmPassTextController,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Debe ser de al menos 7 caracteres, números o letras';
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _anotherObscureText = !_anotherObscureText;
                            });
                          },
                          child: Icon(
                            _anotherObscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black,
                          ),
                        ),
                        hintText: 'Repite tu Password',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    // Teléfono
                    TextFormField(
                      focusNode: _phoneNumberFocusNode,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(_positionCPFocusNode),
                      keyboardType: TextInputType.phone,
                      controller: _phoneNumberController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Falta completar este campo";
                        } else {
                          return null;
                        }
                      },
                      onChanged: (v) {
                        // print(' Phone number ${_phoneNumberController.text}');
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Número de Teléfono',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    // Position in the company
                    GestureDetector(
                      onTap: () {
                        _showTaskCategoriesDialog(size: size);
                      },
                      child: TextFormField(
                        enabled: false,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: () => _submitFormOnSignUp,
                        focusNode: _positionCPFocusNode,
                        keyboardType: TextInputType.name,
                        controller: _positionCPTextController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Falta completar este campo';
                          } else {
                            return null;
                          }
                        },
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Función o cargo',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              _isLoading
                  ? Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : MaterialButton(
                      onPressed: _submitFormOnSignUp,
                      color: Colors.blue.shade900,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Registrarme',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              SizedBox(
                                width: 8,
                              ),
                              Icon(
                                Icons.person_add,
                                color: Colors.white,
                              )
                            ],
                          )))
            ]))
      ],
    ));
  }

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Por favor selecciona una opción'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    await _getFromCamera();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera,
                          color: Colors.cyan,
                        ),
                      ),
                      Text(
                        'Cámara',
                        style: TextStyle(color: Colors.cyan),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await _getFromGallery();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.cyan,
                        ),
                      ),
                      Text(
                        'Galería',
                        style: TextStyle(color: Colors.cyan),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _pickedFile = response.file;
      });
    } else {
      GlobalMethod.showErrorDialog(
          error: response.exception!.code, ctx: context);
    }
  }

  Future<void> _getFromGallery() async {
    _pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      // maxHeight: 480,
      // maxWidth: 480,
      imageQuality: 15,
    );
    await retrieveLostData();
    // setState(() {
    //   imageFile = File(pickedFile!.path);
    // });
    await _cropImage(_pickedFile!.path);
    Navigator.canPop(context) ? Navigator.pop(context) : null;
  }

  Future<void> _getFromCamera() async {
    _pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      // maxHeight: 480,
      // maxWidth: 480,
      imageQuality: 15,
    );
    await retrieveLostData();

    // setState(() {
    //   imageFile = File(pickedFile!.path);
    // });
    await _cropImage(_pickedFile!.path);

    Navigator.canPop(context) ? Navigator.pop(context) : null;
  }

  Future<void> _cropImage(filePath) async {
    File? croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        // maxHeight: 480,
        // maxWidth: 480,
        compressQuality: 15);
    if (croppedImage != null) {
      setState(() {
        imageFile = croppedImage;
      });
    }
  }

  void _showTaskCategoriesDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'Selecciona tu puesto',
              style: TextStyle(fontSize: 20, color: Colors.blue.shade800),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Jobs.jobsList.length,
                  itemBuilder: (ctxx, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _positionCPTextController.text = Jobs.jobsList[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.blue.shade200,
                          ),
                          // SizedBox(width: 10,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Jobs.jobsList[index],
                              style: TextStyle(
                                  color: MyColors.darkBlue,
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            ),
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
}
