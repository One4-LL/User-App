import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: IntroScreen(),
    );
  }
}

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}


class _IntroScreenState extends State<IntroScreen> {

List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "Local Store shopping",
        description: "Seamless experience at local shops! No more language issues now!",
        pathImage: "assets/Images/3.jpg",
        backgroundColor: const Color(0xfff5a623),
      ),
    );
    slides.add(
      new Slide(
        title: "Super Markets",
        description: "Super Market bills all in one place and shopping made super easy",
        pathImage: "assets/Images/4.jpg",
        backgroundColor: const Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        title: "Travel seamlessly",
        description: "Language is no longer a barrier to seamless travel",
        pathImage: "assets/Images/2.jpg",
        backgroundColor: const Color(0xff9932CC),
      ),
    );
  }

  void onDonePress() {
    // TODO: go to next screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
          VoiceHome(),    
      )
    );
  }

  void onSkipPress() {
    // TODO: go to next screen
  }


  @override
 Widget build(BuildContext context) {
    return Scaffold(
      body:IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
      onSkipPress: this.onSkipPress,
    ),);
    }
}

class VoiceHome1 extends StatefulWidget {
  @override
  _VoiceHome1State createState() => _VoiceHome1State();
}

class _VoiceHome1State extends State<VoiceHome1> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Text("hi"),
    );
  }
}

final databaseReference = Firestore.instance;
var refans = new Map();

class VoiceHome extends StatefulWidget {

  @override
  _VoiceHomeState createState() => _VoiceHomeState();
}

class _VoiceHomeState extends State<VoiceHome> {
  SpeechRecognition _speechRecognition;
  String status;
  
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";
  final db = Firestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    takePermission();
    initSpeechRecognizer();
  }
  takePermission() async {
    Map<Permission, PermissionState> permission = await PermissionsPlugin
    .requestPermissions([
        Permission.RECORD_AUDIO,
    ]);
  }
  void initSpeechRecognizer(){
    _speechRecognition = SpeechRecognition();
    _speechRecognition.setAvailabilityHandler((bool result)=>setState(()=>

        _isAvailable = result,
    ));

    _speechRecognition.setRecognitionStartedHandler(()=>setState(()=>
    _isListening = true
    
    ));

    _speechRecognition.setRecognitionResultHandler((String speech)=>setState(()=>resultText = speech));
    _speechRecognition.setRecognitionCompleteHandler(()=>setState(()=>_isListening = false));


    _speechRecognition.activate().then(
      (result) => setState(()=>_isAvailable = result),
    );
  }

  void createRecord(ans2) async {
   DocumentReference ref = await databaseReference.collection("Orders")
      .add({
        'userOrder': ans2
      });
  print(ref.documentID);
}

  void doTask(){
    debugPrint(resultText);
    var ans = resultText.split("and");
    var ans2 = new Map();
    for(var i=0;i<ans.length;i++){
        var temp = ans[i];
        var temp2 = temp.split("of");
        ans2[(temp2[1]).trim()] = temp2[0].trim();
    }
    print(ans2);
    refans = ans2;
    createRecord(ans2);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
        backgroundColor: const Color(0xff203152),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                   'Please speak up your order by clicking on the mic button and speak up your order separated by an "and" between 2 orders and an "of" between two quantities ',
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 2.0,
            color: Colors.white
            
          ),
),
              ),
              SizedBox(height: 20.0,),            
                      Row(
            
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                FloatingActionButton(
                  mini: true,
                  splashColor: Colors.blue,
                  heroTag: 'btn1',
                  child: Icon(Icons.cancel),
                  backgroundColor: Colors.deepOrange,
                  onPressed: () {
                    if(_isListening){
                      _speechRecognition.cancel().then((result)=>setState((){
                        _isListening = result;
                        resultText = "";
                      }));
                    }
                  },
                ),
                FloatingActionButton(
                  heroTag: 'btn2',
                  child: Icon(Icons.mic),
                  backgroundColor: Colors.pink,
                  onPressed: (){
                    if(_isAvailable && !_isListening){
                      _speechRecognition.listen(locale: "hi_IN").then((result){
                          
                        });
                    }
                  },
                ),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'btn3',
                  child: Icon(Icons.stop),
                  backgroundColor: Colors.deepPurple,
                  onPressed:  (){
                    doTask();
                    if(_isListening){
                      _speechRecognition.stop().then(
                        (result) => setState((){
                          _isListening = result;
                          
                          }),
                      );
                    }
                  },
                ),
              ],),
              SizedBox(height: 100,),
              Container(
                width: MediaQuery.of(context).size.width*0.8,
                decoration: BoxDecoration(
                  color: Colors.cyanAccent[100],
                  borderRadius: BorderRadius.circular(6.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 12.0,
                ),
                child: Text(resultText,
                style: TextStyle(fontSize: 24.0),),
              ),
              SizedBox(height: 200.0),
              RaisedButton(child: Text("Save order and Pay"),
                onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context)=> Details(data:refans)
                      )
                    );
                },
                color: Colors.blue,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(100, 10, 100, 10),
                splashColor: Colors.green,
              )
            ],
          ),
          
        ),
    );
  }
}





class Details extends StatelessWidget {
  final Map data;
    Details({
      Key key,
      @required this.data,
    });  


  @override
  Widget build(BuildContext context) {
    return Text(data.toString());
  }
}


