import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../models/post.dart';

import '../styles.dart';
import '../util.dart';

class Details extends StatelessWidget {
  static const routeName = 'Details';
  final Post post;

  Details({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wasteagram', style: Styles.appTitle)),
      body: MergeSemantics(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DisplayDateHeadline(date: post.date),
              DisplayImage(imageURL: post.imageURL),
              DisplayQuantity(quantity: post.quantity),
              DisplayCoords(lat: post.latitude, long: post.longitude)
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayDateHeadline extends StatelessWidget {
  final String date;
  DisplayDateHeadline({this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 18.0, 0, 8.0),
      child: Semantics(
        key: Key('displayDateHeadline'),
        textField: true,
        readOnly: true,
        header: true,
        label: "Post title",
        value: Util.formatDateWithYear(date),
        child: Text(Util.formatDateWithYear(date), style: Styles.postTitle),
      ),
    );
  }
}

class DisplayImage extends StatelessWidget {
  final String imageURL;
  DisplayImage({this.imageURL});

  @override
  Widget build(BuildContext context) {
    return Container(
        key: Key('displayImage'),
        height:300,
        child: Stack(
            children: [
              Container(
                color: Colors.grey[100],
                child: Center(
                  child: Semantics(
                    label: "Progress indicator",
                    child: imageURL != '' ? CircularProgressIndicator() : Text('No image saved'),
                  ),
                ),
              ),
              ConditionalImage(imageURL),
            ]
          ),
      );//return Image.network(this.imageURL);
  }
}

class ConditionalImage extends StatelessWidget {
  final imageURL;

  ConditionalImage(this.imageURL);

  @override
  Widget build(BuildContext context) {
    if (imageURL != '' && imageURL != null) {
      print(imageURL);
      return Positioned.fill(
          child: Semantics(
            label: "Photo of food items going to waste",
            child: FadeInImage.memoryNetwork(
              height: 300,
              placeholder: kTransparentImage,
              image: this.imageURL,
            ),
          ));
    } else {
      return Positioned.fill(
          child: Semantics(
            label: "No image saved to this post",
          )
      );
    }
  }
}

class DisplayQuantity extends StatelessWidget {
  final int quantity;
  DisplayQuantity({this.quantity});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: Key('displayQuantity'),
      label: "Item count",
      value: quantity.toString(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 6.0, 0, 6.0),
        child: Text('Items: ' + quantity.toString(), style: Styles.detailsItemsCount)
      )
    );
  }
}

class DisplayCoords extends StatelessWidget {
  final String lat;
  final String long;

  DisplayCoords({this.lat, this.long});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: Key('displayCoords'),
      label: "Lat and Long coordinates",
      value: '$lat, $long',
      child: Text('($lat, $long)', style: Styles.detailsCoords)
    );
  }
}