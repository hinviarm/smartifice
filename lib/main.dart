import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:crypt/crypt.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'VideoScreen.dart';
import 'Login.dart';

var videoList = [
  {
    'name': 'bee',
    'media_url':
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'thumb_url':
        'https://as2.ftcdn.net/v2/jpg/01/21/70/41/1000_F_121704191_qk8PTFa5liXCqJloSH4AkXK1e8tjumha.jpg'
  },
  {
    'name': 'BigBuckBunny',
    'media_url':
        'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'thumb_url':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Big_Buck_Bunny_-_forest.jpg/640px-Big_Buck_Bunny_-_forest.jpg'
  },
  {
    'name': 'ElephantsDream',
    'media_url':
        'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'thumb_url':
        'https://upload.wikimedia.org/wikipedia/commons/0/0c/ElephantsDreamPoster.jpg'
  },
  {
    'name': 'ForBiggerBlazes',
    'media_url':
        'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'thumb_url':
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg'
  },
  {
    'name': 'ForBiggerEscapes',
    'media_url':
        'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'thumb_url':
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg'
  }
];
void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _url = 'https://www.avousdejouer.eu';
  bool passwordVisible = true;
  String? id = '';
  String? MDP = '';
  bool sess = false;
  bool connect = false;

  void session() async {
    //User u = User.fromJson(await SessionManager().get("user"));
    id = await SessionManager().get("name");
    MDP = await SessionManager().get("password");
    debugPrint('id ${id}');
    debugPrint('MDP ${MDP}');
    if (!(id == null && MDP == null)) {
      var urlString =
          'http://149.202.45.36:8001/identification?Email=${id}';
      var url = Uri.parse(urlString);
      var reponse = await http.get(url);
      if (reponse.statusCode == 200) {
        var wordShow = convert.jsonDecode(reponse.body);
        final h = Crypt(wordShow);
        if (h.match(MDP!)) {
          sess = true;
        }
      }
    }
  }

  @override
  void initState() {
    session();
    testConnection();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void testConnection() async {
    var urlString =
        'http://149.202.45.36:8001/miseAJour?Email=armand.hinvi@gmail.com';
    var url = Uri.parse(urlString);
    var reponse = await http.get(url);
    if (reponse.statusCode == 200) {
      setState(() {
        connect = true;
      });
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    session();
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                title: Text('Smartifice'),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text('A Vous De Jouer', style: TextStyle(fontSize: 18.0, color: Colors.white)),
                    onPressed: _launchURL,
                  ),
                  //IconButton(icon: Icon(Icons.more_vert, color: Colors.white), onPressed: (){})
                ]
            ),
            body: Stack(children: <Widget>[
              ListView(
                children: videoList
                    .map((e) => GestureDetector(
                  onTap: () => {
                    testConnection(),
                    if (connect == false)
                      {
                        Alert(
                          context: context,
                          type: AlertType.info,
                          title: "Problème de connection",
                          desc: "Contactez l'administrateur au +33695278959.",
                          buttons: [
                            DialogButton(
                              child: Text(
                                "Retour",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () => Navigator.pop(context),
                              color: Color.fromRGBO(0, 179, 134, 1.0),
                              radius: BorderRadius.circular(0.0),
                            ),
                          ],
                        ).show()
                      }
                    else
                      {
                        session(),
                        if (sess)
                          {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VideoScreen(
                                        name: e['name']!,
                                        mediaUrl: e['media_url']!,sess:(value)=> setState((){
                                      debugPrint('-------------------Value vaut : ${value.toString()}');
                                      if(value.toString() == 'true'){
                                        debugPrint('----------------Victoire---------------');
                                        sess = true;
                                      } else {
                                        sess = false;
                                      }
                                    }))))
                          }
                        else
                          {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen(
                                        name: e['name']!,
                                        mediaUrl: e['media_url']!, sess:(value)=> setState((){
                                      if(value.toString() == 'true'){
                                        sess = true;
                                      } else {
                                        sess = false;
                                      }
                                    }))))
                          }
                      }
                  },
                  child: Image.network(e['thumb_url']!),
                ))
                    .toList(),
              ),
            ]
            )
        )
    );
  }

  _launchURL() async {
    var _uri = Uri.parse(_url);
    if (await canLaunchUrl(_uri)) {
      await launchUrl(_uri);
    } else {
      throw 'Could not launch $_url';
    }
  }
}