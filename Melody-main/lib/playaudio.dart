import 'package:chewie_audio/chewie_audio.dart';
import 'package:chewie_audio/src/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'shared.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';

class YellowBird extends StatefulWidget {
  YellowBird(
      {@required this.url,
      @required this.imgPath,
      @required this.tit,
      this.singer});

  final String url;
  final String imgPath;
  final String tit;
  final singer;

  @override
  _YellowBirdState createState() => _YellowBirdState();
}

class _YellowBirdState extends State<YellowBird>
    with SingleTickerProviderStateMixin {
  int valueHolder = 20;
  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  VideoPlayerController _videoPlayerController2;
  ChewieAudioController _chewieAudioController;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 25000),
      upperBound: pi * 2,
    );
    animationController.forward();
    animationController.addListener(() {
      setState(() {
        if (animationController.status == AnimationStatus.completed) {
          animationController.repeat();
        }
      });
    });

    _videoPlayerController1 = VideoPlayerController.network('${widget.url}');
    _videoPlayerController2 = VideoPlayerController.network('${widget.url}');
    _chewieAudioController = ChewieAudioController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieAudioController.dispose();
    animationController.dispose();
    super.dispose();
  }

  List<String> songNames = [];
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: Align(
          alignment: Alignment(0.9, 0.9),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () async {
              Fluttertoast.showToast(
                msg: "Added to Favourite",
                toastLength: Toast.LENGTH_SHORT,
                textColor: Colors.black,
                fontSize: 16,
                backgroundColor: Colors.grey[200],
              );

              MySharedPreferences mySharedPreferences =
                  MySharedPreferences.instance;
              songNames = await mySharedPreferences.getListData('rname');
              if (songNames == null) {
                await mySharedPreferences
                    .setListData('rname', ['${widget.tit}']);
              } else {
                songNames.add('${widget.tit}');
                await mySharedPreferences.setListData('rname', songNames);
              }
              await mySharedPreferences.setListData('${widget.tit}',
                  [widget.tit, widget.imgPath, widget.url, widget.singer]);
            },
            child: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
          ),
        ),
        backgroundColor: Color(0xFF24263D),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    //color: Colors.white, //background color of box
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 20.0, // soften the shadow
                      spreadRadius: 5.0, //extend the shadow
                      offset: Offset(
                        15.0, // Move to right 10  horizontally
                        15.0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.red],
                  ),
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(40)),
                ),
                height: 500,

                child: Column(
                  children: <Widget>[
                    SizedBox(height: 60),
                    Center(
                      child: AnimatedBuilder(
                        builder: (BuildContext context, Widget _widget) {
                          return new Transform.rotate(
                            angle: animationController.value,
                            child: _widget,
                          );
                        },
                        animation: animationController,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 5,
                                  color: Colors.black26,
                                  offset: Offset(1, 3))
                            ],
                            border: Border.all(color: Colors.black87, width: 3),
                            borderRadius:
                                BorderRadius.all(Radius.circular(156.0)),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(10),
                            width: 190.0,
                            height: 190.0,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage("${widget.imgPath}")),
                            ), //boxdeco
                          ), //cont
                        ),
                      ), //cont
                    ),
                    SizedBox(
                      height: 70,
                    ),
                    ChewieAudio(
                      controller: _chewieAudioController,
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      child: Container(
                        padding: EdgeInsets.all(
                          10.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Download Now!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () async {
                        final status = await Permission.storage.request();

                        if (status.isGranted) {
                          final externalDir =
                              await getExternalStorageDirectory();

                          final id = await FlutterDownloader.enqueue(
                            url: widget.url,
                            savedDir: externalDir.path,
                            fileName: widget.tit + ".mp3",
                            showNotification: true,
                            openFileFromNotification: true,
                          ).then(
                            (value) => Fluttertoast.showToast(
                              msg: "Started Download!",
                              toastLength: Toast.LENGTH_SHORT,
                              textColor: Colors.black,
                              fontSize: 16,
                              backgroundColor: Colors.grey[200],
                            ),
                          );
                        } else {
                          print("hello");
                        }
                      },
                    ),
                    Center(
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent[400],
                          borderRadius: BorderRadius.all(Radius.circular(150)),
                        ),
                      ), //cont
                    ),
                  ],
                ), //column
              ), //cont
              SizedBox(height: 55),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  // padding:EdgeInsets.symmetric(horizontal:20),
                  child: Text(
                    '${widget.tit}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ), //padd
              ),
              SizedBox(
                height: 15,
              ), //cont
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  // padding:EdgeInsets.symmetric(horizontal:20),
                  child: Text(
                    '${widget.singer}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white60),
                  ),
                ), //padd
              ), //cont
              SizedBox(height: 30),
//
            ], //col wid
          ),
        ), //col
      ),
    ); //scaff
  }
}
