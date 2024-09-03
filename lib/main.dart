// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'tflite_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TFLiteFlutterApp(),
    );
  }
}

class TFLiteFlutterApp extends StatefulWidget {
  @override
  _TFLiteFlutterAppState createState() => _TFLiteFlutterAppState();
}

class _TFLiteFlutterAppState extends State<TFLiteFlutterApp> {
  File? _image;
  String? _prediction;
  double? _confidence;
  final TFLiteModel _model = TFLiteModel();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _predictImage(_image!);
      });
    }
  }

  void _predictImage(File image) {
    var result = _model.predict(image);
    setState(() {
      _confidence = result[0] * 100;
      _prediction = result[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TFLite Image Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null ? Text('No image selected.') : Image.file(_image!),
            SizedBox(height: 20),
            _prediction == null
                ? Container()
                : Text(
                    'Prediction: $_prediction\nConfidence: ${_confidence?.toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 18),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
          ],
        ),
      ),
    );
  }
}
