import 'dart:async';
import 'package:flutter/material.dart';
import 'package:melody/welcomescreen.dart';
import 'package:melody/shared.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  bool showAlert = false;

  List FinalTreandingSongs1 = [];
  getData() async {
    TrendingSongs trendingSongs = TrendingSongs();
    FinalTreandingSongs1 = await trendingSongs.getTrendingSongs();
    if (FinalTreandingSongs1 != null) {
      startTimer();
    } else {
      showAlert = true;
      setState(() {});
    }
  }

  void startTimer() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return WelcomeScreen(
          FinalTreandingSongs: FinalTreandingSongs1,
        );
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Center(
            child: Text(
              "Melody",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: showAlert == true
            ? AlertDialog(
                title: Text('Network Error'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Please check your Internet connection!'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Retry'),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoadingScreen();
                          },
                        ),
                      );
                    },
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Image.asset(
                        "images/smok.gif",
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.25,
                    ),
                    Flexible(
                      child: Image.asset(
                        "images/gifs.gif",
                        height: size.height * 0.07,
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.0115,
                    ),
                    Text(
                      "Loading...",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
