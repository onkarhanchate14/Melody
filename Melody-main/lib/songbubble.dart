import 'package:flutter/material.dart';
import 'playaudio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SongBubble extends StatefulWidget {
  final imgpath;
  final title;
  final singer;
  final encurl;
  SongBubble(
      {@required this.imgpath,
      @required this.title,
      this.singer = " ",
      this.encurl});
  @override
  _SongBubbleState createState() => _SongBubbleState();
}

class _SongBubbleState extends State<SongBubble> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    short1();
    short2();
  }

  String Sname;
  String Tname;
  void short1() {
    if (widget.singer.length > 19) {
      Sname = widget.singer.substring(0, 19);
    } else {
      Sname = widget.singer;
    }
  }

  void short2() {
    if (widget.title.length > 17) {
      Tname = widget.title.substring(0, 14) + "..";
    } else {
      Tname = widget.title;
    }
  }

  void getFinalUrl(no_id) async {
    finalUrl =
        'https://sklktecdnems05.cdnsrv.jio.com/jiosaavn.cdn.jio.com/$no_id';
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

  String finalUrl;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        if (widget.encurl != null) {
          await getNO(widget.encurl);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return YellowBird(
                  imgPath: widget.imgpath,
                  tit: widget.title,
                  url: finalUrl,
                  singer: widget.singer,
                );
              },
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF30314D),
        ),
        height: 100,
        width: size.width * 0.9,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Container(
                margin: EdgeInsets.all(5),
                width: 70.0,
                height: 70.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                      image: NetworkImage(widget.imgpath),
                    ))),
            SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Text(
                    "${Tname}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    //softWrap: true,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Flexible(
                  child: Text(
                    "${Sname}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    //softWrap: true,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
