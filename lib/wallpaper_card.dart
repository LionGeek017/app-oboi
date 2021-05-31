import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class WallpaperCard extends StatelessWidget {
  const WallpaperCard({Key key, this.index, this.wallpaperId, this.siteUrl, this.imgUrl, this.imgUrlOriginal, this.title}) : super(key: key);

  final int index;
  final int wallpaperId;
  final String siteUrl;
  final String imgUrl;
  final String imgUrlOriginal;
  final String title;

  @override
  Widget build(BuildContext context) {
    // возвращаем текст в контейнере
    return GestureDetector(
        onTap: (() {
          Wallpaper wallpaper = Wallpaper(index: index, wallpaperId: wallpaperId, siteUrl: siteUrl, imgUrl: imgUrl, imgUrlOriginal: imgUrlOriginal, title: title);
          Navigator.pushNamed(
              context,
              '/wallpaper_view',
              arguments: wallpaper
          );
        }),
        child: Container(
          //alignment: Alignment.center,
          padding: EdgeInsets.all(8),
          child: Stack(
            children: [
              Center(
                child: CircularProgressIndicator(),
              ),
              Container(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: new FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: imgUrl,
                      fit: BoxFit.cover,
                    ),
                  )
              )
            ],
          ),
        )
    );
  }
}

class Wallpaper {
  final int index;
  final int wallpaperId;
  final String siteUrl;
  final String imgUrl;
  final String imgUrlOriginal;
  final String title;
  Wallpaper({this.index, this.wallpaperId, this.siteUrl, this.imgUrl, this.imgUrlOriginal, this.title});
}