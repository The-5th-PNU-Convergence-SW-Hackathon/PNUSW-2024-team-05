import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'recognition.dart';
import 'firebase_helper.dart';

class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  static const int WIDTH = 160;
  static const int HEIGHT = 160;
  Map<String, Recognition> registered = Map();
  @override
  String get modelName => 'assets/models/facenet.tflite';

  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
    initDB();
  }

  initDB() async {
    // await dbHelper.init();
    loadRegisteredFaces();
  }

  void loadRegisteredFaces() async {
    final allRows = await FirebaseHelper.getAllEmbd();
    for (final row in allRows) {
      String uid = row['uid']!;
      String username = row['username']!;
      String memberType = row['memberType']!;
      List<double> embd = row['imgEmbd']!
          .split(',')
          .map((e) => double.parse(e))
          .toList()
          .cast<double>();
      Recognition recognition =
          Recognition(uid, username, memberType, Rect.zero, embd, 0);
      registered.putIfAbsent(uid, () => recognition);
    }
  }

  // void loadRegisteredFaces() async {
  //   final allRows = await dbHelper.queryAllRows();
  //   // debugPrint('query all rows:');
  //   for (final row in allRows) {
  //     //  debugPrint(row.toString());
  //     print(row[DatabaseHelper.columnName]);
  //     String name = row[DatabaseHelper.columnName];
  //     List<double> embd = row[DatabaseHelper.columnEmbedding]
  //         .split(',')
  //         .map((e) => double.parse(e))
  //         .toList()
  //         .cast<double>();
  //     Recognition recognition =
  //         Recognition(row[DatabaseHelper.columnName], Rect.zero, embd, 0);
  //     registered.putIfAbsent(name, () => recognition);
  //   }
  // }

  // void registerFaceInDB(String name, List<double> embedding) async {
  //   // List<double>을 String으로 변환
  //   String embeddingString = embedding.join(',');

  //   // row to insert
  //   Map<String, dynamic> row = {
  //     DatabaseHelper.columnName: name,
  //     DatabaseHelper.columnEmbedding: embeddingString
  //   };
  //   final id = await dbHelper.insert(row);
  //   print('inserted row id: $id');
  // }

  // 모델 로드
  Future<void> loadModel() async {
    try {
      interpreter =
          await Interpreter.fromAsset(modelName, options: _interpreterOptions);
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  // 이미지를 배열로 변환
  List<dynamic> imageToArray(img.Image inputImage) {
    img.Image resizedImage =
        img.copyResize(inputImage!, width: WIDTH, height: HEIGHT);
    List<double> flattenedList = resizedImage.data!
        .expand((channel) => [channel.r, channel.g, channel.b])
        .map((value) => value.toDouble())
        .toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = HEIGHT;
    int width = WIDTH;
    Float32List reshapedArray = Float32List(1 * height * width * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int index = c * height * width + h * width + w;
          reshapedArray[index] =
              float32Array[c * height * width + h * width + w];
        }
      }
    }
    return reshapedArray.reshape([1, 160, 160, 3]);
  }

  //
  Recognition recognize(img.Image image, Rect location) {
    //TODO crop face from image resize it and convert it to float array
    var input = imageToArray(image);
    print(input.shape.toString());

    //TODO output array
    List output = List.filled(1 * 512, 0).reshape([1, 512]);

    //TODO performs inference
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(input, output);
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms$output');

    //TODO convert dynamic list to double list
    List<double> outputArray = output.first.cast<double>();

    //TODO looks for the nearest embeeding in the database and returns the pair
    Pair pair = findNearest(outputArray);
    print("pair name= ${pair.name}");
    print("pair username= ${pair.username}");
    print("pair memberType= ${pair.memberType}");
    print("distance= ${pair.distance}");

    return Recognition(pair.name, pair.username, pair.memberType, location,
        outputArray, pair.distance);
  }

  //TODO  looks for the nearest embeeding in the database and returns the pair which contain information of registered face with which face is most similar
  findNearest(List<double> emb) {
    Pair pair = Pair("Unknown", "Unknown", "", -5);
    for (MapEntry<String, Recognition> item in registered.entries) {
      final String name = item.key;
      final String username = item.value.username;
      final String memberType = item.value.memberType;
      List<double> knownEmb = item.value.embeddings;
      double distance = 0;
      for (int i = 0; i < emb.length; i++) {
        double diff = emb[i] - knownEmb[i];
        distance += diff * diff;
      }
      distance = sqrt(distance);
      if (pair.distance == -5 || distance < pair.distance) {
        pair.distance = distance;
        pair.name = name;
        pair.username = username;
        pair.memberType = memberType;
      }
    }
    return pair;
  }

  void close() {
    interpreter.close();
  }
}

class Pair {
  String name;
  String username;
  String memberType;
  double distance;
  Pair(this.name, this.username, this.memberType, this.distance);
}
