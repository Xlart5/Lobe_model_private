import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

class TFLiteModel {
  Interpreter? _interpreter;
  List<String>? _labels;
  ImageProcessor? _imageProcessor;

  TFLiteModel() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('saved_model.tflite');
      _labels = await _loadLabels('labels.txt');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<List<String>> _loadLabels(String filename) async {
    final String labelsData = await rootBundle.loadString('assets/$filename');
    return labelsData.split('\n').where((label) => label.isNotEmpty).toList();
  }

  List<dynamic> predict(File image) {
    if (_interpreter == null || _labels == null) {
      print('Model or labels are not loaded');
      return [];
    }

    try {
      var inputImage = _preProcessImage(image);
      var output = List.filled(1 * _labels!.length, 0).reshape([1, _labels!.length]);

      _interpreter!.run(inputImage.buffer, output);

      if (output.isEmpty || output[0].isEmpty) {
        print('Model output is empty');
        return [];
      }

      int maxIndex = output[0].indexWhere((value) => value == output[0].reduce((curr, next) => curr > next ? curr : next));

      if (maxIndex == -1) {
        print('Could not find a valid prediction');
        return [];
      }

      return [output[0][maxIndex], _labels![maxIndex]];
    } catch (e) {
      print('Error during prediction: $e');
      return [];
    }
  }

  TensorImage _preProcessImage(File image) {
    try {
      _imageProcessor = ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(224, 224))
          .add(NormalizeOp(0, 255))
          .build();

      TensorImage tensorImage = TensorImage.fromFile(image);
      tensorImage = _imageProcessor!.process(tensorImage);

      return tensorImage;
    } catch (e) {
      print('Error processing image: $e');
      rethrow;
    }
  }
}
