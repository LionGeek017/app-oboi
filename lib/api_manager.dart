import 'package:smart_oboi/wallpaper_page.dart';
import 'package:http/http.dart' as http;

// запрос к серверу и проверка результата
class APIManager {
  Future<dynamic> getQuery(getUrl, catId, wallPage) async {
    var responseJson;
    Map<String, dynamic> params = {};

    if(catId > 0) {
      params["category_id"] = "$catId";
    }

    if(wallPage > 1) {
      params["page"] = "$wallPage";
    }

    params["loc"] = loc;

    // временный параметр
    params["version_code"] = "3";

    var endUrl = '/api/v1/database.get' + getUrl;
    //print(params);
    // url api
    final uri = Uri.https(siteUrl, endUrl).replace(queryParameters: params);
    // заголовки
    //print(uri);
    final headers = {
      'Accept':'application/json'
    };
    // асинхронный get запрос к серверу
    final response = await http.get(uri, headers: headers);
    responseJson = _response(response);
    //print('Получили ответ');
    return responseJson;
  }
  // проверяем результат
  dynamic _response(http.Response response) {
    return response;
    if(response.statusCode == 200) {
      //return json.decode(response.body.toString());
      return response;
    } else {
      // нужно дописать обработку разных ответов
      //print('test');
      return false;
    }
  }
}