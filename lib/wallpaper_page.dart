import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:smart_oboi/ad_modal.dart';
//import 'package:flutter_native_admob/flutter_native_admob.dart';
//import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:smart_oboi/wallpaper_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_manager.dart';
import 'category_card.dart';

String
siteUrl = 'smartoboi.com',
    loc;
List<Locale> userLocales = ui.window.locales;
//var titleApp = {"ru" : "Умные обои", "en" : "Smart wallpaper"};
var
titleApp = {"ru" : "SmartOboi", "en" : "SmartOboi"},
    titleDrawer = {"ru" : "Категории обоев", "en" : "Wallpaper categories"},
    contentApp = {
      "ru" : {
        "all" : "Все обои",
        "title" : "Обои ",
        "wZero" : "Здесь пока ничего нет",
        "again" : "Проверить еще раз",
        "loadingStart" : "Загружаем обои...",
        "wDownload" : "Обои успешно загружены",
        "wInstall" : "Обои успешно установлены",
        "errorApp" : "Ошибка! Перезапустите приложение",
      },
      "en" : {
        "all" : "All wallpaper",
        "title" : "Wallpaper ",
        "wZero" : "No wallpaper",
        "again" : "Again",
        "loadingStart" : "Loading wallpaper...",
        "wDownload" : "Wallpaper uploaded successfully",
        "wInstall" : "Wallpaper installed successfully",
        "errorApp" : "Error! Restart the application",
      }
    },
    categoriesJson,
    wallpaperJson,
    wallpaperJsonData,
    wallpaperJsonDataOnly,
    wallpaperPage = 0,
    nextPage = 0;

int
categoryId = 0,
    wallpaperLastPage,
    categoryActiveIndex = -1;

bool loadingPage = false;
bool adModalShow = false;

// список категорий
class WallpaperPage extends StatefulWidget {
  @override
  WallpaperPageState createState() {
    return new WallpaperPageState();
  }
}

class WallpaperPageState extends State<WallpaperPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(!adModalShow) {
      Timer(Duration(seconds: 30), () {
        setState(() {
          adModalShow = true;
        });
        adModal(context);
      });
    }
  }

  void restartApp() {
    setState(() {
      categoriesJson = null;
      categoryActiveIndex = -1;
      wallpaperJson = null;
      wallpaperJsonData = null;
      wallpaperJsonDataOnly = null;
      wallpaperPage = 0;
      categoryId = 0;
      wallpaperLastPage = 0;
    });
  }

  // обновляем переменные и перезапускаем контент
  void updateCategories(responseJson) {
    setState(() {
      categoriesJson = responseJson;
    });
  }

  // Получаем категории
  void getCategories() {
    APIManager apiManager = new APIManager();
    apiManager.getQuery('Categories', 0, 0).then((response) {
      final responseJson = json.decode(response.body.toString());
      updateCategories(responseJson);
      //print(responseJson);
    }).catchError((onError) {
      print(onError);
      //print("Ошибка категорий");
    });
  }

  ListView listView() {
    final categoryData = categoriesJson['data'];
    final count = categoryData.length;
    //var heightList = count * (heightRow + 40);
    //String hL = '$heightList';

    List<Widget> listTitle = <Widget>[];
    listTitle.add(
        DrawerHeader(
          child: Center(
            child: Text(
              titleDrawer[loc],
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
              ),
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.amber[900],
          ),
        )
    );

    listTitle.add(
      ListTile(
        title: CategoryCard(index: 0, title: contentApp[loc]["all"], categoryId: 0, imgUrl: 'assets/images/ok.png', all: true),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          setState(() {
            categoryActiveIndex = -1;
            categoryId = 0;
            wallpaperPage = 0;
            wallpaperJson = null;
            wallpaperJsonDataOnly = null;
          });
          Navigator.pop(context);
        },
      ),
    );

    listTitle.add(Divider(color: Colors.grey));

    for(int i = 0; i < count; i++) {
      var dataIndex = categoryData[i];

      //if(dataIndex['active'] > 0) {
      listTitle.add(
          ListTile(
            title: CategoryCard(index: i, title: dataIndex["title_" + loc], categoryId: dataIndex["id"], imgUrl: dataIndex["img"]),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              setState(() {
                categoryActiveIndex = i;
                categoryId = dataIndex["id"];
                wallpaperPage = 0;
                wallpaperJson = null;
                wallpaperJsonDataOnly = null;
              });
              Navigator.pop(context);
            },
          )
      );
      //}
    }

    return ListView(
        padding: EdgeInsets.zero,
        children: listTitle
    );
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        launch('https://play.google.com/store/apps/details?id=app.cashback.service.backmoney');
        break;

      case 1:
        launch('https://' + siteUrl);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // записываем в переменную язык, по которому показываем название категорий и картинок
    loc = locationGet();

    // если категорий нету, получаем их
    if(categoriesJson == null) {
      getCategories();
    }

    //print(categoriesJson);

    return Scaffold(
        appBar: AppBar(
          title: Text(categoryActiveIndex < 0 ? titleApp[loc] : contentApp[loc]["title"] + categoriesJson['data'][categoryActiveIndex]['title_' + loc]),
          backgroundColor: Colors.yellow[900],
          actions: [
            PopupMenuButton<int>(
              onSelected: (item) => onSelected(context, item),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Text('Проверить обновления'),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Text('Сайт SmartOboi'),
                )
              ],
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            //WallpaperPage();
            restartApp();
          },
          child: Center(
            child: WallpaperList(),
          ),
        ),
        drawer: categoriesJson != null
            ? Drawer(
            child: listView()
        )
            : null
    );
  }

}

// Список обоев
class WallpaperList extends StatefulWidget {
  @override
  WallpaperListState createState() {
    return new WallpaperListState();
  }
}

class WallpaperListState extends State<WallpaperList> {

  //final nativeAdController = NativeAdmobController();
  //final adUnitId = "ca-app-pub-3940256099942544/2247696110";

  // final NativeAd myNative = NativeAd(
  //   adUnitId: 'ca-app-pub-3940256099942544/2247696110',  // тестовый код
  //   //adUnitId: 'ca-app-pub-8726494808516661/9999681660',
  //   factoryId: '2407177641',
  //   request: AdRequest(),
  //   listener: AdListener(),
  // );

  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-3940256099942544/6300978111', // тестовый банер
    //adUnitId: 'ca-app-pub-8726494808516661/9677180244',
    size: AdSize.banner,
    request: AdRequest(),
    listener: AdListener(),
  );

  ScrollController _controller;
  @override
  void initState() {
    myBanner.load();

    _controller = ScrollController();
    _controller.addListener(() async {
      if(_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
        if(wallpaperPage + 1 <= wallpaperLastPage) {

          setState(() {
            loadingPage = true;
            nextPage = wallpaperPage + 1;
          });

          getWallpapers(nextPage);
          //print('Отправляем запрос');
        } else {
          //print('Больше страниц нету');
        }
      }
    });
    super.initState();
    //myNative.load();
  }

  // обновляем переменные и перезапускаем контент
  void updateWallpaper(responseJson, wallpaperArr) {
    setState(() {
      wallpaperJson = responseJson;
      wallpaperJsonData = responseJson['data'];
      loadingPage = false;

      if(wallpaperJsonData.length > 0) {
        wallpaperPage = wallpaperJsonData['current_page'];
        wallpaperLastPage = wallpaperJsonData['last_page'];
      } else {
        wallpaperPage = 0;
        wallpaperLastPage = 0;
      }
      wallpaperJsonDataOnly = wallpaperArr;
    });
  }

  // Получаем обои
  void getWallpapers(wallPage) {
    //startCheckInternet();

    APIManager apiManager = new APIManager();
    apiManager.getQuery('Wallpapers', categoryId, wallPage).then((response) {
      //print(wallpaperPage);
      final responseJson = json.decode(response.body.toString());
      var wallpaperArr = wallpaperJsonDataOnly ?? [];
      if(responseJson['data'].length > 0) {
        for(int i = 0; i < responseJson['data']['data'].length; i++) {
          wallpaperArr.add(responseJson['data']['data'][i]);
        }
      }
      // print(responseJson['data']['data'].length);
      updateWallpaper(responseJson, wallpaperArr);
      //print(responseJson);
      //print(wallpaperArr);
    }).catchError((onError) {
      print(onError);
      //print("Ошибка обоев");
    });
  }


  // Widget adsContainer() {
  //
  //   //final AdWidget adWidget = AdWidget(ad: myNative);
  //
  //   return Container(
  //     child: Container(
  //       height: 250,
  //       child: adWidget,
  //     ),
  //   );
  // }

  // Widget adsContainer() {
  // return Container(
  //   child: Container(
  //     height: 250,
  //     child: NativeAdmob(
  //       adUnitID: adUnitId,
  //       controller: nativeAdController,
  //       type: NativeAdmobType.full,
  //       error: CupertinoActivityIndicator(),
  //     ),
  //   ),
  // );
  // }

  List wallpaperList() {

    // myNative.load();
    // final AdWidget adWidgetNative = AdWidget(ad: myNative);
    // final Container adContainerNative = Container(
    //   alignment: Alignment.center,
    //   child: adWidgetNative,
    //   // width: 200,
    //   // height: 200,
    // );



    List<Widget> wallpapers = <Widget>[];

    for(int i = 0; i < wallpaperJsonDataOnly.length; i++) {
      //if(i == 5) {
        //wallpapers.add(adContainerNative);
      //}
      var dataIndex = wallpaperJsonDataOnly[i];
      wallpapers.add(
          WallpaperCard(index: i, wallpaperId: dataIndex['id'], siteUrl: siteUrl, imgUrl: dataIndex['img'], imgUrlOriginal: dataIndex['img_original'], title: dataIndex['title_' + loc])
      );
    }
    return wallpapers;
  }

  @override
  Widget build(BuildContext context) {


    final AdWidget adWidget = AdWidget(ad: myBanner);

    // если обоев нету, получаем их
    if(wallpaperJsonDataOnly == null) {
      getWallpapers(wallpaperPage);
    } else {
      if(wallpaperJsonDataOnly.length > 0) {
        return Container(
          height: double.infinity,
          child: Stack(
            children: [
              GridView(
                padding: EdgeInsets.all(8),
                controller: _controller,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  //childAspectRatio: 50.0
                ),
                children: wallpaperList(),
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  alignment: Alignment.center,
                  child: adWidget,
                  width: myBanner.size.width.toDouble(),
                  height: myBanner.size.height.toDouble(),
                )
              ),
              Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                      child: loadingPage ? Container(
                        alignment: Alignment.center,
                        color: Colors.yellow[900].withOpacity(0.95),
                        height: 50,
                        child: CircularProgressIndicator(),
                      ) : null
                  )
              )
            ],
          ),
        );

      } else {
        return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: Text(contentApp[loc]["wZero"]),
                  //child: Text(wallpaperJson['mess']),
                ),
                RaisedButton(
                    child: Text(contentApp[loc]["again"]),
                    onPressed: (() {
                      getWallpapers(wallpaperPage);
                    })
                )
              ],
            )
        );
      }
    }

    return Center(
      child: Text(contentApp[loc]["loadingStart"]),
    );
  }
}




// Определяем язык ru или en
String locationGet() {
  if(userLocales.length > 0) {
    String userLocalesOne = userLocales[0].toString();
    String locSplit = userLocalesOne.split('_')[0];
    if(locSplit != 'ru' && locSplit != 'uk') {
      return 'en';
    }
  }
  return 'ru';
}