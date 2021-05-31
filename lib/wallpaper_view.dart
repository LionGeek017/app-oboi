import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_oboi/wallpaper_card.dart';
import 'package:smart_oboi/wallpaper_page.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';

bool
loadingDownload = false,
    loadingWallpaper = false;

class WallpaperView extends StatefulWidget {
  @override
  WallpaperViewState createState() {
    return new WallpaperViewState();
  }
}

class WallpaperViewState extends State<WallpaperView> {

  final InterstitialAd myInterstitialWallpaper = InterstitialAd(
    adUnitId: 'ca-app-pub-3940256099942544/1033173712', // для тестовой рекламы
    //adUnitId: 'ca-app-pub-8726494808516661/8182847744',
    request: AdRequest(),
    listener: AdListener(),
  );

  final InterstitialAd myInterstitial = InterstitialAd(
    adUnitId: 'ca-app-pub-3940256099942544/1033173712', // для тестовой рекламы
    //adUnitId: 'ca-app-pub-8726494808516661/9020163567',
    request: AdRequest(),
    listener: AdListener(),
  );

  @override
  void initState() {
    super.initState();
    myInterstitial.load();
    myInterstitialWallpaper.load();
  }

  var imagePathDownload = null;

  // Установить как обои
  void wallpaperImage(String imgUrl, int imgId) async {

    if(await downloadAndSaveImage(imgUrl, imgId)) {

      if(imagePathDownload != null) {
        var resultFilePath = imagePathDownload['filePath'];
        var resultPathSplit = resultFilePath.split('file://')[1];
        var file = new File(resultPathSplit);

        final result = await WallpaperManager.setWallpaperFromFile(
            file.path,
            WallpaperManager.HOME_SCREEN
        );
        print(result);

        myInterstitialWallpaper.show();
        loadingInfo(true, contentApp[loc]["wInstall"]);
      } else {
        loadingInfo(false, null);
      }
    } else {
      loadingInfo(false, null);
    }

    setState(() {
      loadingDownload = false;
    });
  }

  // Скачать картинку в галерею
  void downloadImage(String imgUrl, int imgId) async {

    if(await downloadAndSaveImage(imgUrl, imgId)) {
      myInterstitial.show();
      loadingInfo(true, contentApp[loc]["wDownload"]);
    } else {
      loadingInfo(false, null);
    }

    setState(() {
      loadingWallpaper = false;
    });
  }

  // Поделиться картинкой
  void shareImage() async {

  }

  @override
  Widget build(BuildContext context) {

    final Wallpaper wallpaper = ModalRoute.of(context).settings.arguments;
    String imgUrlFinal = wallpaper.imgUrlOriginal;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
              wallpaper.title ?? ''
          ),
          backgroundColor: Colors.black38.withOpacity(0.3),
        ),
        body: Stack(
          children: [
            Center(
              child: CircularProgressIndicator(),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.zero,
              child: new FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: imgUrlFinal,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            Positioned(
                bottom: 50.0,
                left: 0.0,
                right: 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: FloatingActionButton(
                        backgroundColor: Colors.amber[600],
                        foregroundColor: Colors.white,
                        elevation: 1,
                        heroTag: 2,
                        child: loadingWallpaper ? CircularProgressIndicator() : Icon(
                          Icons.file_download,
                          size: 35,
                        ),
                        onPressed: () => {
                          setState(() {
                            loadingWallpaper = true;
                          }),
                          downloadImage(imgUrlFinal, wallpaper.wallpaperId),
                          //Scaffold.of(context).showSnackBar(SnackBar(content: Text('Начало загрузки')))
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: FloatingActionButton(
                        backgroundColor: Colors.amber[500],
                        foregroundColor: Colors.white,
                        elevation: 1,
                        heroTag: 3,
                        child: loadingDownload ? CircularProgressIndicator() : Icon(
                          Icons.wallpaper,
                          size: 25,
                        ),
                        onPressed: () => {
                          setState(() {
                            loadingDownload = true;
                          }),
                          wallpaperImage(imgUrlFinal, wallpaper.wallpaperId)
                        },
                      ),
                    )
                  ],
                )
            )
          ],
        )
    );
  }

  Future<bool> downloadAndSaveImage(String imgUrl, int imgId) async {
    try {

      File file = new File(imgUrl);
      Path path = new Path();
      String name = file.path;

      var response = await Dio().get(imgUrl, options: Options(responseType: ResponseType.bytes));
      if(await _requestPermission(Permission.storage)) {
        final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.data), quality: 100, name: "wallpaper_$imgId"
        );
        imagePathDownload = result;
      }
      return true;
    } catch(error) {
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if(await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if(result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  void loadingInfo(bool loading, String mess) {
    SnackBar snackBar;
    if(loading) {
      snackBar = SnackBar(
          content: Text(mess),
          backgroundColor: Colors.green
      );
    } else {
      snackBar = SnackBar(
          content: Text(contentApp[loc]["errorApp"]),
          backgroundColor: Colors.redAccent
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}
