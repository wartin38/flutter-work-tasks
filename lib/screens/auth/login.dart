import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:workos/screens/auth/register.dart';
import 'package:workos/screens/auth/forget_pass.dart';
import 'package:workos/services/global_methods.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late TextEditingController _emailTextController =
      TextEditingController(text: '');
  late TextEditingController _passTextController =
      TextEditingController(text: '');
  bool _obscureText = true;
  final _loginFormKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _animationController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });
    _animationController.forward();
    super.initState();
  }

  void _submitFormOnLogin() async {
    final isValid = _loginFormKey.currentState!.validate();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.signInWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _passTextController.text.trim());
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
        CachedNetworkImage(
          // imageUrl: 'https://picsum.photos/id/766/1440/?blur=9',
          imageUrl: 'https://picsum.photos/id/983/1440/?blur=4',
          placeholder: (context, url) => Image.asset(
            'assets/images/background2.jpg',
            fit: BoxFit.fill,
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: FractionalOffset(_animation.value, 0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: ListView(
            children: [
              SizedBox(
                height: size.height * 0.05,
              ),
              Text(
                'Task-Master',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Ingresar',
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
                      text: '¿No tienes una cuenta?',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    TextSpan(text: '     '),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignUp())),
                      text: 'Regístrate',
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
                height: 40,
              ),
              Form(
                key: _loginFormKey,
                child: Column(
                  children: [
                    TextFormField(
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
                      obscureText: _obscureText,
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passTextController,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Por favor ingresa un password válido';
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
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgetPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Olvidé mi password',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        decoration: TextDecoration.underline,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              MaterialButton(
                onPressed: _submitFormOnLogin,
                color: Colors.blue.shade900,
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ingresar',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Icons.login,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
