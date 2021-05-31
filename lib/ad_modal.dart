import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_oboi/wallpaper_page.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_manager.dart';

adModal(context) {

  APIManager apiManager = new APIManager();
  apiManager.getQuery('AdModal', 0, 0).then((response) {
      final responseJson = json.decode(response.body.toString());

      if(responseJson['success'] == true) {
        final data = responseJson['data'];

        return showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  data['title_' + loc],
                  style: TextStyle(
                      fontSize: 17
                  ),
                ),
                content: SingleChildScrollView(
                  child: data['img'] != null ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          width: 200,
                          height: 200,
                          child: Stack(
                            children: [
                              Center(
                                child: CircularProgressIndicator(),
                              ),
                              Container(
                                width: 200,
                                height: 200,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: new FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: data['img'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Text(
                          data['description_' + loc]
                      )
                    ],
                  ) : Text(
                      data['description_' + loc]
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                      child: Text(
                        "Позже",
                        style: TextStyle(
                            color: Colors.black54
                        ),
                      ),
                      onPressed: (){
                        Navigator.of(context).pop(); // Return value
                      }
                  ),
                  ElevatedButton(
                      child: Text("Установить"),
                      onPressed: (){
                        final String go = data['url'];
                        launch(go);
                        Navigator.of(context).pop(); // Return value
                      }
                  ),
                ],
                actionsPadding: EdgeInsets.only(top: 0, right: 15, bottom: 10, left: 15),
              );
            }
        );
      } else {
        print('Ничего нет');
      }

  }).catchError((onError) {
    print(onError);
  });
}
