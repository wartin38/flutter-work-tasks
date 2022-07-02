import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workos/constants/my_colors.dart';
import 'package:workos/user_state.dart';
import 'package:workos/widgets/drawer_widget.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;

  const ProfileScreen({required this.userID});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _titleTextStyle = TextStyle(
      fontSize: 22, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold);
  var _contentTextStyle = TextStyle(
      color: MyColors.darkBlue,
      fontSize: 18,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold);

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  bool _isLoading = false;
  String phoneNumber = "";
  String email = "";
  String name = "";
  String job = "";
  String imageUrl = "";
  String joinedAt = " ";
  bool _isSameUser = false;

  void getUserData() async {
    try {
      _isLoading = true;
      // Las variables declaradas fuera de la clase state
      // se deben ponder como widget:
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();
      if (userDoc == null) {
        return;
      } else {
        setState(() {
          email = userDoc.get('email');
          name = userDoc.get('name');
          job = userDoc.get('positionInCompany');
          phoneNumber = userDoc.get('phoneNumber');
          imageUrl = userDoc.get('userImage');
          Timestamp joinedAtTimestamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimestamp.toDate();
          joinedAt = '${joinedDate.day}-${joinedDate.month}-${joinedDate.year}';
        });
        User? user = _auth.currentUser;
        final _uid = user!.uid;
        setState(() {
          _isSameUser = _uid == widget.userID;
        });
      }
    } catch (err) {} finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Stack(
                  alignment: const Alignment(0, -1.4),
                  children: [
                    Card(
                      margin: EdgeInsets.all(30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 100,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                name,
                                style: _titleTextStyle,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                '$job desde el: $joinedAt',
                                style: _contentTextStyle,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Información de contacto',
                              style: _titleTextStyle,
                            ),
                            SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: userInfo(title: 'Email:', content: email),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: userInfo(
                                  title: 'Teléfono:', content: phoneNumber),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _isSameUser
                                ? Container()
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _contactMethod(
                                          color: Colors.green,
                                          fct: () {
                                            _openWhatsAppChat();
                                          },
                                          icon: FontAwesome.whatsapp),
                                      _contactMethod(
                                          color: Colors.red,
                                          fct: () {
                                            _mailTo();
                                          },
                                          icon: Icons.mail_outline),
                                      _contactMethod(
                                          color: Colors.purple,
                                          fct: () {
                                            _callPhoneNumber();
                                          },
                                          icon: Icons.call_outlined),
                                    ],
                                  ),
                            SizedBox(
                              height: 25,
                            ),
                            _isSameUser
                                ? Container()
                                : Divider(
                                    thickness: 1,
                                  ),
                            SizedBox(
                              height: 25,
                            ),
                            !_isSameUser
                                ? Container()
                                : Center(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 30),
                                      child: MaterialButton(
                                        onPressed: () {
                                          _logout(context);
                                        },
                                        color: Colors.blue.shade800,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.logout,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                'Cerrar Sesión',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.36,
                          height: size.height * 0.36,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 3,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            image: DecorationImage(
                                image: NetworkImage(imageUrl == null
                                    ? 'https://image.flaticon.com/icons/png/512/1071/1071066.png'
                                    : imageUrl),
                                fit: BoxFit.contain),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _openWhatsAppChat() async {
    var url = 'https://wa.me/+52$phoneNumber?text=Hola $name';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Error de whats');
      throw 'Ocurrió un error en whats';
    }
  }

  void _mailTo() async {
    var mailUrl = 'mailto:$email';
    if (await canLaunch(mailUrl)) {
      await launch(mailUrl);
    } else {
      print('Error al enviar el email');
      throw 'Ocurrió un error en email';
    }
  }

  void _callPhoneNumber() async {
    var phoneUrl = 'tel://$phoneNumber';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      print('Error al llamar');
      throw 'Ocurrió un error al llamar';
    }
  }

  _contactMethod(
      {required Color color, required Function fct, required IconData icon}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 23,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: () {
            fct();
          },
        ),
      ),
    );
  }

  Widget userInfo({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: _titleTextStyle,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            content,
            style: _contentTextStyle,
          ),
        ),
      ],
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
}
