import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:path/path.dart' as Path;

import '../styles.dart';

class NewPost extends StatelessWidget {
  static const routeName = 'NewPost';

  final String localImagePath;
  NewPost({this.localImagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wasteagram', style: Styles.appTitle)),
      body: SingleChildScrollView(
        child: AddEntryForm(localImagePath),
      ),
    );
  }
}

class PostEntryFields {
  String photoURL;
  String quantity;
}

class AddEntryForm extends StatefulWidget {
  final String localImagePath;
  AddEntryForm(this.localImagePath);

  @override
  _AddEntryFormState createState() => _AddEntryFormState(localImagePath);
}

class _AddEntryFormState extends State<AddEntryForm> {
  final String localImagePath;

  _AddEntryFormState(this.localImagePath);

  final formKey = GlobalKey<FormState>();
  final postEntryFields = PostEntryFields();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imagePreview(),
            _quantityFormField(),
            _submitButton(),
          ]
        )
      )
    );
  }

  Widget _imagePreview() {
    if (localImagePath == null || localImagePath == '') {
      return Container(
        key: Key('photoPreview'),
        height: 260,
        child: Center(
          child: Semantics(
            label: 'Empty container, no image to display',
            child: Text('No image selected')
          )
        )
      );
    } else {
      return Stack(
        key: Key('photoPreview'),
        children: [
          Container(
            height: 260,
            child: Center(
              child: Semantics(
                label: "Progress indicator",
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          Center(
              child: Image.file(File(localImagePath))
          ),
        ]
      );
    }
  }

  Widget _quantityFormField() {
    return Container(
      height:100,
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Number of items'),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        validator: (value) => validateQuantity(value),
        onSaved: (value) {
          postEntryFields.quantity = value;
        }
      ),
    );
  }


  Widget _submitButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 240,
        height: 90,
        child: Semantics(
          label:"Submit post button",
          hint:"Submits a new post",
          child: RaisedButton(
            key: Key('submitButton'),
            color: Colors.green[100],
            onPressed: () => validateAndSave(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload),
                Text("Submit post"),
              ]
            ),
          ),
        ),
      ),
    );
  }


  String validateQuantity(String value) {
    if (value.isEmpty) {
      return 'Please enter a quantity';
    } else
      return null;
  }

  void validateAndSave(BuildContext context) async {
    final formState = formKey.currentState;

    if (formState.validate()) {
      formKey.currentState.save();

      // lat and long info
      LocationData locationData;
      var locationService = Location();
      locationData = await locationService.getLocation();

      // pop the snack bar up
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Posting...')));

      // see if there's an image to upload, and if so, upload it
      if (localImagePath == '' || localImagePath == null) {
        postEntryFields.photoURL = '';
      } else {
        StorageReference storageReference = FirebaseStorage.instance.ref()
            .child(Path.basename(DateTime.now().toString()));

        // actually upload the image
        // do this only when form is valid, and hold the completion until the url is returned
        StorageUploadTask uploadTask = storageReference.putFile(
            File(localImagePath));
        await uploadTask.onComplete;
        postEntryFields.photoURL = await storageReference.getDownloadURL();
      }

      await Firestore.instance.collection('posts').add({
        'date': DateTime.now().toString(),
        'imageURL': postEntryFields.photoURL,
        'latitude': locationData.latitude.toString(),
        'longitude': locationData.longitude.toString(),
        'quantity': int.parse(postEntryFields.quantity),
      });

      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }
}

class ChoosePhoto extends StatelessWidget {
  final getImage;
  ChoosePhoto(this.getImage);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: RaisedButton(
            child: Text('Choose Photo'),
            onPressed: getImage
        )
    );
  }
}



