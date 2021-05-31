import 'package:flutter/material.dart';
var heightRow = 50;
String hR = '$heightRow';

class CategoryCard extends StatelessWidget {
  // константа
  const CategoryCard({Key key, this.index, this.title, this.categoryId, this.imgUrl, this.all = false}) : super(key: key);
  // переменные
  final bool all;
  final int index;
  final String title;
  final int categoryId;
  final String imgUrl;


  // переопределяем виджет build
  @override
  Widget build(BuildContext context) {
    // формируем карточку
    return Container(
      //padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: <Widget>[
            Container(
              width: 50,
              height: double.parse(hR),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: all == true ? AssetImage('$imgUrl') : Image.network('$imgUrl').image,
                      fit: BoxFit.cover
                  ),
                  shape: BoxShape.circle
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        )
    );
  }
}