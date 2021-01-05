import 'package:http/http.dart' as http;
import 'dart:convert';

class AlbumList {
  String imgUrl;
  String imgIconUrl;
  String titlee;
  var image;

  List SongDetails = [];
  List Tokens = [];
  void getToken(token) async {
    var queryURL =
        'https://www.jiosaavn.com/api.php?__call=webapi.get&token=$token&type=artist&p=&n_song=10&n_album=14&sub_type=&category=&sort_order=&includeMetaTags=0&ctx=wap6dot0&api_version=4&_format=json&_marker=0';

    try {
      var response = await http.get(queryURL);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        for (int i = 0; i < 9; i++) {
          image = jsonResponse['topSongs'][i]['image'];

          //call others function

          imgIconUrl = image;
          image = image.replaceAll('150x150', '500x500');
          imgUrl = image;
          var title = jsonResponse['topSongs'][i]['title'];
          titlee = title;
          var fulltoken =
              jsonResponse['topSongs'][i]['more_info']['encrypted_media_url'];
          fulltoken = fulltoken.replaceAll('+', '%2B');
          fulltoken = fulltoken.replaceAll('/', '%2F');

          SongDetails.add(['$titlee', '$imgUrl', '$fulltoken']);
        }

        print(SongDetails);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print(e);
    }
  }
}
