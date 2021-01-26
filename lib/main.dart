import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dog/sounds.dart';
import 'package:dog/headshots.dart';
import 'package:flutter/services.dart';

const MAX_COUNT = 15;
var newTitle = "No Name's";
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soundboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.indigoAccent,
      ),
      home: MyHomePage(title: ""),
      //home: new _LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// class _LoginScreen extends StatelessWidget {
// @override
// Widget build(BuildContext context) {
// return new Scaffold(
// appBar: new AppBar(
// title: new Text("Login"),
// ),
// body: new Checkbox(
// value: false,
// onChanged: (bool newValue) {
// Navigator.push(
// context,
// new MaterialPageRoute(
// builder: (context) => MyHomePage;
// );
// }));
// }
//

class _MyHomePageState extends State<MyHomePage> {
  final List _theSounds = MySounds().sounds;
  final List _theHeadshots = MyHeadshots().headshots;
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  String _title;

  AudioCache audioCache;
  AudioPlayer audioPlayer;
  int indexIsPlaying;

  @override
  initState() {
    super.initState();
    initSounds();
    _title = "BFF Soundboard";
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  int _count = MyHeadshots().headshots.length;
  int _numOfSounds = MySounds().sounds.length;

  @override
  Widget build(BuildContext context) {
    //button covers
    return new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(_title),
        ),
        body: new Container(
          child: GridView.builder(
              //Credit to cookmscott(Github) - segments taken from OwenWilson tutorial
              shrinkWrap: false,
              itemCount: _count,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemBuilder: (BuildContext context, int index) => GestureDetector(
                    child: Container(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 900),
                        curve: Curves.bounceOut,
                        margin: EdgeInsets.all(6),
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
                            image: new AssetImage(_theHeadshots[index % 11]),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: new BorderRadius.circular(100),
                          border: new Border.all(
                              color: indexIsPlaying == index
                                  ? Colors.red
                                  : Colors.transparent,
                              width: 2.0,
                              style: BorderStyle.solid),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              offset: Offset(0, 10.0),
                              blurRadius: 10.0,
                            )
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          playSound(_theSounds[index % _numOfSounds]);
                          indexIsPlaying = index;
                        });
                      }
                    },
                  )),
        ),
        //Bottom used for adding/removing buttons and stopping sounds
        bottomNavigationBar: Container(
          //padding: const EdgeInsets.all(5.0),
          child: BottomAppBar(
            elevation: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.stop_circle_outlined),
                  onPressed: () {
                    stopSound(_theSounds);
                    HapticFeedback.lightImpact();
                  },
                  enableFeedback: true,
                ),
                //for future update - allowing to record to soundboard
                //plug-in not available currently
                // IconButton(
                // icon: Icon(Icons.fiber_manual_record),
                // onPressed: null,
                // color: Colors.red,
                // ),
                //add to # of buttons
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => {
                    decrementCount(),
                    HapticFeedback.lightImpact(),
                  },
                ),
                //take away from # of buttons
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => {
                    increaseCount(),
                    HapticFeedback.lightImpact(),
                  },
                ),
                //login popup - not necessary in future update
                IconButton(
                    icon: Icon(Icons.login),
                    onPressed: () {
                      //calls login function/handler
                      _login();
                      HapticFeedback.lightImpact();
                    })
              ],
            ),
            color: Colors.green,
          ),
        ));
  }

//Function used to increase number of buttons available
  void increaseCount() {
    if (_count < MAX_COUNT)
      setState(() {
        _count++;
      });
    else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Maximum Sounds Met"),
              content: new Text("Limit has been met please delete some!"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

//Function used to decrease number of buttons available
  void decrementCount() {
    if (_count > 1) {
      setState(() {
        _count--;
      });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Minimum Sounds Met"),
              content: new Text(
                  "Cannot have an empty SoundBoard - Please add more!\n"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

//create sounds to be played
  void initSounds() async {
    //create audioPlayer with constructor
    audioPlayer = AudioPlayer();
    //create an audio cache that will use audioplayer
    audioCache = AudioCache(fixedPlayer: audioPlayer);
    //load all sounds in folder to cache to be played
    audioCache.loadAll(_theSounds);
  }

//plays available sounds
  void playSound(aSound) async {
    var fileName = aSound;
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      audioPlayer.stop();
    }
    audioPlayer = await audioCache.play(fileName);
  }

//stops sound
  void stopSound(aSound) {
    audioPlayer.stop();
  }

  void loginHandle(user, pass) {
    //testcase -> impliment using database for storage next
    if (user == "Ethan" && pass == "Chambers") {
      showDialog(
          context: context,
          //display content for 3 seconds
          builder: (BuildContext context) {
            Future.delayed(Duration(seconds: 3), () {
              Navigator.of(context).pop(true);
            });
            //displays content text window
            return AlertDialog(
              content: new Text("Welcome " + user + "!"),
            );
          });
    }
    else {
      showDialog(
          context: context,
           //display content for 3 seconds
          builder: (BuildContext context) {
            Future.delayed(Duration(seconds: 1), () {
              Navigator.of(context).pop();
            });
            //Returns popup displaying username submitted
            return AlertDialog(
                content: new Text("Welcome " + user + "!"),
            );
          });
    }
    setState(() {
        _title = user + "'s Soundbaord";
    });
  }

  void _login() {
    //-----possible future update-----
    // final emailField = TextField(
    //     obscureText: false,
    //     decoration: InputDecoration(
    //         contentPadding: EdgeInsets.fromLTRB(10.5, 10.5, 10.5, 10.5),
    //         hintText: "Email",
    //         border:
    //             OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))));
    // final passwordField = TextField(
    //     obscureText: false,
    //     decoration: InputDecoration(
    //         contentPadding: EdgeInsets.fromLTRB(10.5, 10.5, 10.5, 10.5),
    //         hintText: "Email",
    //         border:
    //             OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))));
    // final loginButton = Material(
    //   elevation: 5.0,
    //   borderRadius: BorderRadius.circular(10.0),
    //   color: Color(0xff01A0C7),
    //   child: MaterialButton(
    //     minWidth: MediaQuery.of(context).size.width,
    //     padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
    //     onPressed: () {},
    //     child: Text("Login", textAlign: TextAlign.center),
    //   ),
    // );
    //-----END-----
    final _formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              //overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close),
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration:
                              InputDecoration(helperText: "Enter Username"),
                          controller: loginController,
                        ),
                      ),
                      Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                      decoration:
                      InputDecoration(helperText: 'Enter Password'),
                      controller: passwordController,
                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                            child: Text("Submit"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              loginHandle(loginController.text,
                                  passwordController.text);
                            }),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }
}
