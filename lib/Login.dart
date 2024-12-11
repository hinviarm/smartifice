import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:crypt/crypt.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_login/flutter_login.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'VideoScreen.dart';
import 'PaySampleApp.dart';

class LoginScreen extends StatefulWidget {
  final String name, mediaUrl;
  final dynamic Function(bool) sess;
  LoginScreen(
      {required this.name,
      required this.mediaUrl,
      required this.sess,
      Key? key})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Duration get loginTime => Duration(milliseconds: 2250);
  String id = '';
  String mDP = '';
  bool connect = false;
  bool insert = false;
  bool sess = false;
  bool mailOK = false;

  @override
  void initState() {
    recSession();
    if (id != '' && mDP != '') {
      sessionConnect(id, mDP);
    }
    super.initState();
  }

  void recSession() async {
    id = await SessionManager().get("name");
    mDP = await SessionManager().get("password");
  }

  void insertion(String name, String password) async {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => PaySampleApp(
            name: widget.name,
            mediaUrl: widget.mediaUrl,
            sess: sess as dynamic)));
    var urlStringPost = 'http://149.202.45.36:8001/insertion';
    var urlPost = Uri.parse(urlStringPost);
    await http.post(
      urlPost,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(<String, String>{
        'Email': name,
        'MDP': password,
      }),
    );
  }

  void sessionConnect(String name, String password) async {
    debugPrint('id ${name}');
    debugPrint('MDP ${password}');
    var urlString = 'http://149.202.45.36:8001/identification?Email=${name}';
    var url = Uri.parse(urlString);
    var reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      setState(() {
        connect = true;
        var wordShow = convert.jsonDecode(reponse.body);
        final h = Crypt(wordShow);
        if (h.match(password)) {
          sess = true;
        }
      });
      if (sess) {
        var sessionManager = SessionManager();
        await sessionManager.set("name", name);
        await sessionManager.set("password", password);
        await sessionManager.set("user", User(name: name, password: password));
      }
    }
    debugPrint('connect = $connect');
    debugPrint('sess = $sess');
  }

  void session(String name, String password) async {
    await SessionManager().destroy();
    var sessionManager = SessionManager();
    await sessionManager.set("name", name);
    await sessionManager.set("password", password);
    await sessionManager.set("user", User(name: name, password: password));
    var urlString = 'http://149.202.45.36:8001/identification?Email=${name}';
    var url = Uri.parse(urlString);
    var reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      setState(() {
        connect = true;
        var wordShow = convert.jsonDecode(reponse.body);
        final h = Crypt(wordShow);
        if (h.match(password)) {
          sess = true;
        }
      });
    }
  }

  Future<String?> _authUser(LoginData data) {
    final c1 = Crypt.sha256(data.password);
    debugPrint('Name: ${data.name}, Password: ${c1.toString()}');
    return Future.delayed(loginTime).then((_) {
      sessionConnect(data.name, data.password);
      if (!connect) {
        return 'Identifiants ou Mot de passe incorrect';
      } else if (!sess) {
        var re = RegExp(r"^.*[a-zA-Z]+.*");
        if (re.hasMatch(data.password)) {
          final c1 = Crypt.sha256(data.password);
          insertion(data.name, c1.toString());
          session(data.name, data.password);
        } else {
          Alert(
            context: context,
            type: AlertType.error,
            title: "Mot de Passe erroné",
            desc: "Votre mot de passe doit contenir au moins une lettre.",
            buttons: [
              DialogButton(
                child: Text(
                  "Retour",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.pop(context),
                width: 120,
              )
            ],
          ).show();
        }
      }
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    var re = RegExp(r"^.*[a-zA-Z]+.*");
    if (re.hasMatch(data.password!)) {
      final c1 = Crypt.sha256(data.password!);
      insertion(data.name!, c1.toString());
      session(data.name!, data.password!);
    } else {
      Alert(
        context: context,
        type: AlertType.error,
        title: "Mot de Passe erroné",
        desc: "Votre mot de passe doit contenir au moins une lettre.",
        buttons: [
          DialogButton(
            child: Text(
              "Retour",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    }
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  void emailing(String name) async {
    var urlString = 'http://149.202.45.36:8001/miseAJour?Email=${name}';
    var url = Uri.parse(urlString);
    var reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      connect = true;
      var wordShow = convert.jsonDecode(reponse.body);
      if (wordShow.toString().contains('true')) {
        final Email email = Email(
          body: "L'utilisateur $name a oublié son mot de passe ",
          subject: 'Mot de passe oublié',
          recipients: ['armand.hinvi@gmail.com', 'warloque@gmail.com'],
          isHTML: false,
        );
        await FlutterEmailSender.send(email);
        mailOK = true;
      }
    }
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');
    emailing(name);
    return Future.delayed(loginTime).then((_) {
      if (!mailOK) {
        return 'User not exists';
      }
      //emailing(name);
      return 'Bonjour';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/fond.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: FlutterLogin(
            title: 'A Vous De Jouer',
            logo: AssetImage('assets/images/logo.png'),
            onLogin: _authUser,
            onSignup: _signupUser,
            theme: LoginTheme(
              pageColorLight: Colors.transparent,
              pageColorDark: Colors.transparent,
            ),
            onSubmitAnimationCompleted: () {
              if (sess) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => VideoScreen(
                      name: widget.name,
                      mediaUrl: widget.mediaUrl,
                      sess: sess as dynamic),
                ));
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => LoginScreen(
                      name: widget.name,
                      mediaUrl: widget.mediaUrl,
                      sess: sess as dynamic),
                ));
              }
            },
            onRecoverPassword: _recoverPassword,
          ),
        ),
      ),
    );
  }
}

class User {
  final String? name;
  final String? password;

  User({this.name, this.password});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> user = Map<String, dynamic>();
    user["name"] = name;
    user["password"] = password;
    return user;
  }
}
