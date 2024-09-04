import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:warm_boys/utils/recognition.dart';
import 'package:warm_boys/utils/recognizer.dart';
import 'package:warm_boys/utils/firebase_helper.dart';
import '../index/main_index.dart';
import '../../widgets/rate_stars.dart';
import '../../widgets/member_symptom_scrollview.dart';

class ActivityScreen extends StatefulWidget {
  final String postId;
  final String currentStatus;
  final String seniorUid;
  final String seniorPhoneNum2;
  final String mateUid;

  ActivityScreen({
    required this.postId,
    required this.currentStatus,
    required this.seniorUid,
    required this.seniorPhoneNum2,
    required this.mateUid,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  // 얼굴 등록 관련 변수
  late ImagePicker imagePicker;
  File? _image;
  Uint8List? paintedImageBytes;
  late FaceDetector faceDetector;
  late Recognizer recognizer;
  List<Face> faces = [];
  List<Recognition> recognitions = [];
  var image;
  bool faceAuth = false;
  final TextEditingController _reportController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  int ratingByMate = 0;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();

    // 얼굴 검출기 초기화
    final options =
        FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate);
    faceDetector = FaceDetector(options: options);

    // 인식기 초기화
    recognizer = Recognizer();
  }

  // 카메라 사진 촬영
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() async {
        _image = File(pickedFile.path);

        // 이미지 회전 처리
        await _fixImageOrientation();

        doFaceDetection();
      });
    }
  }

  // 이미지 회전 처리
  Future<void> _fixImageOrientation() async {
    final bytes = await _image!.readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage != null) {
      img.Image orientedImage = img.bakeOrientation(originalImage);
      _image = File(_image!.path)
        ..writeAsBytesSync(img.encodeJpg(orientedImage));
    }
  }

  // 갤러리에서 이미지 선택
  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        doFaceDetection();
      });
    }
  }

  doFaceDetection() async {
    // _image를 File형에서 InputImage형으로 변환
    InputImage inputImage = InputImage.fromFile(_image!);
    recognitions.clear();

    // _image을 Image형으로 가져온 image 변수
    image = await decodeImageFromList(_image!.readAsBytesSync());

    // InputImage형으로 변환한 _image를 얼굴 검출기에 넣어 '얼굴들의 각 영역'을 검출함.
    faces = await faceDetector.processImage(inputImage);

    // 얼굴 순회
    for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;

      num left = boundingBox.left < 0 ? 0 : boundingBox.left;
      num top = boundingBox.top < 0 ? 0 : boundingBox.top;
      num right =
          boundingBox.right > image.width ? image.width - 1 : boundingBox.right;
      num bottom = boundingBox.bottom > image.height
          ? image.height - 1
          : boundingBox.bottom;
      num width = right - left;
      num height = bottom - top;

      final bytes = _image!.readAsBytesSync();
      img.Image? faceImg = img.decodeImage(bytes!);
      img.Image croppedFace = img.copyCrop(faceImg!,
          x: left.toInt(),
          y: top.toInt(),
          width: width.toInt(),
          height: height.toInt());
      Recognition recognition = recognizer.recognize(croppedFace, boundingBox);
      if (recognition.distance > 1.25) {
        recognition.name = "Unknown";
        recognition.username = "Unknown";
      }
      recognitions.add(recognition);
    }

    checkFaceAuth();

    drawRectangleAroundFaces();
  }

  // 얼굴 목록에서 seniorUid와 mateUid를 확인하는 메서드
  void checkFaceAuth() {
    bool foundSenior = false;
    bool foundMate = false;

    for (Recognition recognition in recognitions) {
      if (recognition.name == widget.seniorUid) {
        foundSenior = true;
      }
      if (recognition.name == widget.mateUid) {
        foundMate = true;
      }
      // 두 유저 모두 발견되면 더 이상 확인할 필요가 없음
      if (foundSenior && foundMate) {
        faceAuth = true;
        break;
      }
    }

    if (!(foundSenior && foundMate)) {
      faceAuth = false;
    }

    setState(() {
      faceAuth;
    });
  }

  drawRectangleAroundFaces() async {
    final painter = FacePainter(
        facesList: recognitions, imageFile: image, faceAuth: faceAuth);
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    painter.paint(
        canvas, Size(image.width.toDouble(), image.height.toDouble()));

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(image.width, image.height);

    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    paintedImageBytes = byteData?.buffer.asUint8List();

    setState(() {
      paintedImageBytes;
    });
  }

  // 전화번호 포맷
  String formatPhoneNumber(String phoneNumber) {
    // 전화번호 길이 체크 및 포맷 적용
    if (phoneNumber.length == 11) {
      return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 7)}-${phoneNumber.substring(7)}';
    } else if (phoneNumber.length == 10) {
      return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6)}';
    } else {
      return phoneNumber; // 잘못된 길이의 경우 입력 그대로 반환
    }
  }

  // 보고서가 작성되었는지 확인
  bool get isReportFilled => _reportController.text.isNotEmpty;
  bool get isReviewFilled => _reviewController.text.isNotEmpty;

  _buildMatchedScaffold(
      String postId, String seniorUid, String seniorPhoneNum2, String mateUid) {
    return Scaffold(
      appBar: AppBar(
        title: Text("활동 시작하기"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "1. 사진 인증",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  paintedImageBytes != null
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height / 3,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(paintedImageBytes!),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        )
                      : Center(
                          child: Container(
                            width: 300,
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(Icons.photo,
                                size: 100, color: Colors.grey[700]),
                          ),
                        ),
                  SizedBox(height: 5),
                  faceAuth
                      ? Center(
                          child: Text(
                            '얼굴 인증이 성공했습니다.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ui.Color.fromARGB(255, 7, 183, 33),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Center(
                          child: Text(
                            '메이트와 시니어의 얼굴이 포함된 사진을 촬영해주세요.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const ui.Color.fromARGB(255, 255, 17, 0),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _imgFromCamera();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(140, 60),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 32,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "카메라 촬영",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color.fromARGB(
                                        255, 106, 106, 106),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _imgFromGallery();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(140, 60),
                                  ),
                                  child: Icon(
                                    Icons.photo_library,
                                    size: 32,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "갤러리",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color.fromARGB(
                                        255, 106, 106, 106),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Text(
                          "2. 활동 시작 보고서 작성",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _reportController,
                          maxLines: 10,
                          maxLength: 1000,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "보고서를 작성하세요...",
                          ),
                          onChanged: (text) {
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 50),
                        MemberSymptomScrollview(symptoms: [
                          ' ※ 비상 연락망: ${formatPhoneNumber(seniorPhoneNum2)} '
                        ]),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: ElevatedButton(
                onPressed: faceAuth && isReportFilled
                    ? () async {
                        bool success = await FirebaseHelper.submitStartReport(
                          postId: widget.postId,
                          startImg: _image!,
                          startReport: _reportController.text,
                        );
                        if (success) {
                          // 성공 시 현재 화면을 닫음
                          MainIndex.globalKey.currentState
                              ?.navigateToMatchingScreen();
                          Navigator.pop(context);
                        } else {
                          // 실패 시 다이얼로그 표시
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('오류'),
                                content: Text('시작 보고서 제출에 실패했습니다.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('확인'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    : null,
                child: Text(
                  "시작 보고서 제출하기",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 224, 73, 81),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildActivatedScaffold(
      String postId, String seniorUid, String seniorPhoneNum2, String mateUid) {
    return Scaffold(
      appBar: AppBar(
        title: Text("활동 종료하기"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "1. 사진 인증",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  paintedImageBytes != null
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height / 3,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(paintedImageBytes!),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        )
                      : Center(
                          child: Container(
                            width: 300,
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(Icons.photo,
                                size: 100, color: Colors.grey[700]),
                          ),
                        ),
                  SizedBox(height: 5),
                  faceAuth
                      ? Center(
                          child: Text(
                            '얼굴 인증이 성공했습니다.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ui.Color.fromARGB(255, 7, 183, 33),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Center(
                          child: Text(
                            '메이트와 시니어의 얼굴이 포함된 사진을 촬영해주세요.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const ui.Color.fromARGB(255, 255, 17, 0),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                  SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _imgFromCamera();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(140, 60),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 32,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "카메라 촬영",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color.fromARGB(
                                        255, 106, 106, 106),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _imgFromGallery();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(140, 60),
                                  ),
                                  child: Icon(
                                    Icons.photo_library,
                                    size: 32,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "갤러리",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color.fromARGB(
                                        255, 106, 106, 106),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Text(
                          "2. 활동 종료 보고서 작성",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _reportController,
                          maxLines: 10,
                          maxLength: 1000,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "보고서를 작성하세요...",
                          ),
                          onChanged: (text) {
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 30),
                        Text(
                          "3. 활동에 참여한 시니어에 대해 평가해주세요.",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        RateStars(
                          rating: ratingByMate,
                          onRatingChanged: (rating) {
                            setState(() {
                              ratingByMate = rating;
                            });
                          },
                        ),
                        SizedBox(height: 30),
                        Text(
                          "4. 시니어에 대한 후기를 작성해주세요.",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _reviewController,
                          maxLines: 5,
                          maxLength: 300,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "리뷰를 작성하세요...",
                          ),
                          onChanged: (text) {
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 50),
                        MemberSymptomScrollview(symptoms: [
                          ' ※ 비상 연락망: ${formatPhoneNumber(seniorPhoneNum2)} '
                        ]),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: ElevatedButton(
                onPressed: faceAuth &&
                        isReportFilled &&
                        ratingByMate > 0 &&
                        isReviewFilled
                    ? () async {
                        // FirebaseHelper.submitEndReport를 사용하여 제출 로직 구현
                        bool success = await FirebaseHelper.submitEndReport(
                          postId: widget.postId,
                          endImg: _image!,
                          endReport: _reportController.text,
                          ratingByMate: ratingByMate,
                          reviewByMate: _reviewController.text,
                        );
                        if (success) {
                          print(widget.mateUid);
                          await FirebaseHelper.getCredit(
                              widget.postId, widget.mateUid);
                          MainIndex.globalKey.currentState
                              ?.navigateToMatchingScreen();
                          Navigator.pop(context);
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('오류'),
                                content: Text('종료 보고서 제출에 실패했습니다.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('확인'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    : null,
                child: Text(
                  "종료 보고서 제출하기",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 224, 73, 81),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentStatus == 'matched') {
      return _buildMatchedScaffold(widget.postId, widget.seniorUid,
          widget.seniorPhoneNum2, widget.mateUid);
    } else if (widget.currentStatus == 'activated') {
      return _buildActivatedScaffold(widget.postId, widget.seniorUid,
          widget.seniorPhoneNum2, widget.mateUid);
    } else {
      return Scaffold(
        appBar: AppBar(title: Text("그 외")),
      );
    }
  }
}

class FacePainter extends CustomPainter {
  List<Recognition> facesList;
  dynamic imageFile;
  bool faceAuth;
  FacePainter(
      {required this.facesList,
      @required this.imageFile,
      required this.faceAuth});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    Paint p = Paint();
    p.color = faceAuth ? Colors.green : Colors.red;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 5;

    for (Recognition face in facesList) {
      canvas.drawRect(face.location, p);

      TextSpan textSpan = TextSpan(
          text: '${face.username}<${face.memberType}>',
          style: TextStyle(
              color: faceAuth ? Colors.green : Colors.red,
              fontFamily: 'NotoSansKR',
              fontWeight: FontWeight.w600,
              fontSize: 80));
      TextPainter tp =
          TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(face.location.left, face.location.top));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
