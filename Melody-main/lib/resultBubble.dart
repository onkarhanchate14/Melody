import 'package:flutter/material.dart';
import 'playaudio.dart';

class ResultBubble extends StatefulWidget {
  final imgpath;
  final title;
  final singer;
  final url;
  ResultBubble(
      {@required this.imgpath,
      @required this.title,
      this.singer = " ",
      this.url});
  @override
  _ResultBubbleState createState() => _ResultBubbleState();
}

class _ResultBubbleState extends State<ResultBubble> {
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return YellowBird(
                imgPath: widget.imgpath,
                tit: widget.title,
                url: widget.url,
                singer: widget.singer,
              );
            },
          ),
        );
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
