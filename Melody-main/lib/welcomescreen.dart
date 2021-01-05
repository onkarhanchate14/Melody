import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melody/resultBubble.dart';
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'horiList.dart';
import 'songbubble.dart';
import 'textfield.dart';
import 'shared.dart';
import 'songList.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:melody/albumList.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'Welcome';
  final List FinalTreandingSongs;
  WelcomeScreen({@required this.FinalTreandingSongs});
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final Map<String, HighlightedWord> _highlights = {
    'flutter': HighlightedWord(
      onTap: () => print('flutter'),
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  TextEditingController nameController = TextEditingController();
  bool _saving = false;
  List fff;
  int index = 0;
  String query;
  bool showBackButton = false;
  String finalURL;

  void getFinalUrl(no_id) async {
    finalURL =
        'https://sklktecdnems05.cdnsrv.jio.com/jiosaavn.cdn.jio.com/$no_id';
    setState(() {
      _saving = false;
      showSpinner = false;
      showBackButton = true;
      nameController.clear();
    });
  }

  void getNO(en_id) async {
    var noURL =
        'https://www.jiosaavn.com/api.php?__call=song.generateAuthToken&url=$en_id&bitrate=128&api_version=4&_format=json&ctx=wap6dot0&_marker=0';
    try {
      var response = await http.get(noURL);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        var no_id = jsonResponse['auth_url'];
        int ind = no_id.indexOf('?');
        no_id = no_id.substring(27, ind);

        print(no_id);
        getFinalUrl(no_id);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print(e);
    }
  }

  void getID(token) async {
    var tokenURL =
        'https://www.jiosaavn.com/api.php?__call=webapi.get&token=$token&type=song&includeMetaTags=0&ctx=wap6dot0&api_version=4&_format=json&_marker=0';
    try {
      var response = await http.get(tokenURL);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        var en_id =
            jsonResponse['songs'][0]['more_info']['encrypted_media_url'];

        print('$en_id');
        en_id = en_id.replaceAll('+', '%2B');
        en_id = en_id.replaceAll('/', '%2F');
        print('$en_id');
        getNO(en_id);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print(e);
    }
  }

  String imgUrl;
  String imgIconUrl;
  String titlee;

  void getToken() async {
    var queryURL =
        'https://www.jiosaavn.com/api.php?__call=autocomplete.get&query=$query&_format=json&_marker=0&ctx=wap6dot0';

    try {
      var response = await http.get(queryURL);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var image = jsonResponse['songs']['data'][0]['image'];
        imgIconUrl = image;
        image = image.replaceAll('50x50', '500x500');
        imgUrl = image;
        var title = jsonResponse['songs']['data'][0]['title'];
        titlee = title;
        var fulltoken = jsonResponse['songs']['data'][0]['url'];
        int l = fulltoken.length;
        var token = fulltoken.substring(l - 11, l);
        print('token: $token');
        print('$image');
        print('$title');
        getID(token);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print(e);
    }
  }

  List songTitles = [];
  //------------------------------------------------------------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    getShared();
  }

  //------------------------------------------------------------------------------------------------------------------------------
  List songDesc = [];

  List<List> finalRecentSongs = [];
  getShared() async {
    // AlbumList albumList = AlbumList();
    // albumList.getToken('1iZ7Gi0bi1Y_');
    MySharedPreferences mySharedPreferences = MySharedPreferences.instance;
    songTitles = await mySharedPreferences.getListData('rname');
    if (songTitles != null) {
      for (var i = 0; i < songTitles.length; i++) {
        songDesc = await mySharedPreferences.getListData(songTitles[i]);
        finalRecentSongs.add(songDesc);
      }
      setState(() {});
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) async {
          //====================================================================
          if (val == 'notListening') {
            if (_text != null &&
                _text != 'Press the button and start speaking') {
              setState(() {
                showSpinner = true;
                startTimer();
                if (fff != null) {
                  fff.clear();
                }
              });

              fff = await SongList().getToken(_text);
              setState(() {
                showSpinner = false;
                finalURL = fff[0][4];
                showBackButton = true;
                _isListening = false;
              });
            }
            //==================================================================
            setState(() {
              _isListening = false;
            });
          }
          return print('onStatus: $val');
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  List<List> abc;

  void startTimer() {
    Timer(Duration(seconds: 12), () {
      setState(() {
        showSpinner = false;
      });
    });
  }

  String msg = "Go Search for your favourite Songs!";
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _saving,
      child: WillPopScope(
        onWillPop: () async => showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    backgroundColor: Color(0xFF30314D),
                    title: Text(
                      'Are you sure you want to quit?',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    actions: <Widget>[
                      RaisedButton(
                          child: Text('Yes'),
                          onPressed: () => Navigator.of(context).pop(true)),
                      RaisedButton(
                          child: Text('No'),
                          onPressed: () => Navigator.of(context).pop(false)),
                    ])),
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Color(0xff24263f),
                  title: Center(
                    child: Text(
                      "Melody ♫♫",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
                backgroundColor: Color(0xFF24263D),
                body: Padding(
                    padding: EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              // Icon(Icons.keyboard_backspace),
                              showBackButton == true
                                  ? IconButton(
                                      onPressed: () {
                                        finalRecentSongs = [];
                                        getShared();
                                        setState(() {
                                          nameController.clear();
                                          finalURL = null;
                                          showBackButton = false;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.keyboard_backspace,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.home,
                                        color: Colors.white,
                                      ),
                                    ),
                              TextFieldContainer(
                                child: TextField(
                                  controller: nameController,
                                  onChanged: (value) {
                                    query = value;
                                  },
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.search,
                                      color: Colors.black,
                                    ),
                                    hintText: "Search for Song",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 7,
                              ),
                              Container(
                                height: 45,
                                width: 45,
                                child: FittedBox(
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.white,
                                    onPressed: _listen,
                                    child: Icon(
                                      _isListening ? Icons.mic : Icons.mic_none,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          _text == null
                              ? SizedBox(
                                  height: 1,
                                )
                              : Text(
                                  _text,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    showSpinner = true;
                                    startTimer();
                                    if (fff != null) {
                                      fff.clear();
                                    }
                                  });
                                  fff = await SongList().getToken(query);
                                  setState(() {
                                    showSpinner = false;
                                    finalURL = fff[0][4];
                                    showBackButton = true;
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF30314D),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    'SEARCH',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          finalURL == null
                              ? Text(
                                  "Favourite Songs",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                )
                              : SizedBox(
                                  width: 1,
                                ),
                          SizedBox(
                            height: 7,
                          ),
                          finalURL == null
                              ? finalRecentSongs.length == 0
                                  ? SizedBox(
                                      width: 1,
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            prefs.remove('rname');
                                            setState(() {
                                              finalRecentSongs = [];
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white70,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Text(
                                              "Clear Recent",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                              : SizedBox(
                                  width: 1,
                                ),
                          SizedBox(
                            height: 7,
                          ),
                          finalURL == null
                              ? finalRecentSongs.length == 0
                                  ? Text(
                                      "Add Some Songs!",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    )
                                  : Container(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: SizedBox(
                                              height: 180.0,
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount:
                                                      finalRecentSongs.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Row(
                                                      children: <Widget>[
                                                        HoriList(
                                                          imgpath:
                                                              finalRecentSongs[
                                                                  index][1],
                                                          title:
                                                              finalRecentSongs[
                                                                  index][0],
                                                          url: finalRecentSongs[
                                                              index][2],
                                                          singer:
                                                              finalRecentSongs[
                                                                  index][3],
                                                        ),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                              : SizedBox(
                                  width: 5,
                                ),
                          SizedBox(height: 50),
                          finalURL == null
                              ? Text(
                                  "Recently Trending",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                )
                              : SizedBox(
                                  width: 1,
                                ),
                          SizedBox(
                            height: 8,
                          ),
                          finalURL == null
                              ? widget.FinalTreandingSongs == null
                                  ? Container(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : Container(
                                      child: ListView.builder(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24),
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: <Widget>[
                                              SongBubble(
                                                imgpath: widget.FinalTreandingSongs[
                                                            index][1] ==
                                                        null
                                                    ? " "
                                                    : widget.FinalTreandingSongs[
                                                        index][1],
                                                title: widget.FinalTreandingSongs[
                                                            index][0] ==
                                                        null
                                                    ? " "
                                                    : widget.FinalTreandingSongs[
                                                        index][0],
                                                encurl: widget.FinalTreandingSongs[
                                                            index][3] ==
                                                        null
                                                    ? " "
                                                    : widget.FinalTreandingSongs[
                                                        index][3],
                                                singer: widget.FinalTreandingSongs[
                                                            index][2] ==
                                                        null
                                                    ? " "
                                                    : widget.FinalTreandingSongs[
                                                        index][2],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              )
                                            ],
                                          );
                                        },
                                        itemCount:
                                            widget.FinalTreandingSongs.length,
                                      ),
                                    )
                              : Container(
                                  child: ListView.builder(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24),
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: <Widget>[
                                          ResultBubble(
                                            imgpath: fff[index][1] == null
                                                ? " "
                                                : fff[index][1],
                                            title: fff[index][0] == null
                                                ? " "
                                                : fff[index][0],
                                            url: fff[index][4] == null
                                                ? " "
                                                : fff[index][4],
                                            singer: fff[index][3] == null
                                                ? " "
                                                : fff[index][3],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          )
                                        ],
                                      );
                                    },
                                    itemCount: fff.length,
                                  ),
                                ),
                        ],
                      ),
                    ))),
          ),
        ),
      ),
    );
  }
}
