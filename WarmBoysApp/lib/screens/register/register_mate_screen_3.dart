import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warm_boys/providers/custom_auth_provider.dart';
import '../../utils/shared_preferences_helper.dart';
import '../../providers/custom_auth_provider.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:warm_boys/utils/recognition.dart';
import 'package:warm_boys/utils/recognizer.dart';
import 'package:flutter/services.dart';

// 회원가입 스크린 3(메이트)
class RegisterMateScreen3 extends StatefulWidget {
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  RegisterMateScreen3({required this.onNextPage, required this.onPreviousPage});

  @override
  _RegisterMateScreen3State createState() => _RegisterMateScreen3State();
}

class _RegisterMateScreen3State extends State<RegisterMateScreen3> {
  String _selectedGender = '남성';
  String? _selectedAge;
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _additionalInfoController;
  late TextEditingController _resiFrontNumController;
  late TextEditingController _resiBackNumController;
  late String? _residentNumber;

  // 얼굴 등록 관련 변수
  late ImagePicker imagePicker;
  File? _image;
  late FaceDetector faceDetector;
  late Recognizer recognizer;
  List<Face> faces = [];
  var image;
  String? _imgEmbd;

  List<String> _ageOptions = List.generate(
      46, (index) => '${19 + index}세(${DateTime.now().year - (19 + index)}년생)');

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _selectedAge != null &&
        _phoneNumberController.text.isNotEmpty &&
        _resiFrontNumController.text.isNotEmpty &&
        _resiBackNumController.text.isNotEmpty &&
        _image != null &&
        _imgEmbd != null;
  }

  // 카메라 사진 촬영
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() async {
        _image = File(pickedFile.path);
        print(pickedFile.path);

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
        print(pickedFile.path);
        doFaceDetection();
      });
    }
  }

  doFaceDetection() async {
    // _image를 File형에서 InputImage형으로 변환
    InputImage inputImage = InputImage.fromFile(_image!);

    // InputImage형으로 변환한 _image를 얼굴 검출기에 넣어 '얼굴들의 각 영역'을 검출함.
    faces = await faceDetector.processImage(inputImage);

    // _image을 Image형으로 가져온 image 변수
    image = await decodeImageFromList(_image!.readAsBytesSync());

    // 얼굴이 여러 개인 경우 알람을 띄움
    if (faces.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지에 여러 얼굴이 포함되어 있습니다.')),
      );
      _image = null;
      return;
    }

    // 인식된 얼굴이 하나인 경우 처리
    if (faces.isNotEmpty) {
      Face face = faces.first;
      final Rect boundingBox = face.boundingBox;
      print("Rect = " + boundingBox.toString());

      // 바운딩 박스가 화면 밖으로 벗어난 상황, 처리 과정
      num left = boundingBox.left < 0 ? 0 : boundingBox.left;
      num top = boundingBox.top < 0 ? 0 : boundingBox.top;
      num right =
          boundingBox.right > image.width ? image.width - 1 : boundingBox.right;
      num bottom = boundingBox.bottom > image.height
          ? image.height - 1
          : boundingBox.bottom;
      num width = right - left;
      num height = bottom - top;

      final bytes = _image!.readAsBytesSync(); // _image Bytes값(Uint8List)를 기록
      img.Image? faceImg = img.decodeImage(bytes!);
      img.Image croppedFace = img.copyCrop(faceImg!,
          x: left.toInt(),
          y: top.toInt(),
          width: width.toInt(),
          height: height.toInt());
      Recognition recognition = recognizer.recognize(croppedFace, boundingBox);
      showFaceRegistrationDialogue(
          Uint8List.fromList(img.encodeBmp(croppedFace)), recognition);
    }
  }

  showFaceRegistrationDialogue(Uint8List croppedFace, Recognition recognition) {
    showDialog(
      context: context,
      builder: (ctx) {
        final customAuthProvider = Provider.of<CustomAuthProvider>(ctx);
        return AlertDialog(
          title: const Text("얼굴이 올바르게 인식되었나요?", textAlign: TextAlign.center),
          alignment: Alignment.center,
          content: SizedBox(
            height: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Image.memory(
                  croppedFace,
                  width: 200,
                  height: 200,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      customAuthProvider.setProfileImage(_image);
                      SharedPreferencesHelper.saveData(
                          '_imgEmbd', recognition.embeddings.join(','));
                      this._imgEmbd = recognition.embeddings.join(',');
                      print("saved _imgEmbd: ${_imgEmbd}");
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 224, 73, 81),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 40)),
                    child: const Text("완료"))
              ],
            ),
          ),
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _resiFrontNumController = TextEditingController();
    _resiBackNumController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _additionalInfoController = TextEditingController();
    imagePicker = ImagePicker();
    _loadFormData();

    // 얼굴 검출기 초기화
    final options =
        FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate);
    faceDetector = FaceDetector(options: options);

    // 인식기 초기화
    recognizer = Recognizer();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _resiFrontNumController.dispose();
    _resiBackNumController.dispose();
    _phoneNumberController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    _nameController.text =
        await SharedPreferencesHelper.getByKey('_username') ?? '';
    _selectedAge = await SharedPreferencesHelper.getByKey('_age');
    _selectedGender = await SharedPreferencesHelper.getByKey('_gender') ?? '남성';
    _residentNumber =
        await SharedPreferencesHelper.getByKey('_residentNumber') ?? '';
    if (_residentNumber != '') {
      _resiFrontNumController.text = _residentNumber!.substring(0, 6);
      _resiBackNumController.text = _residentNumber!.substring(6, 7);
    } else {
      _resiFrontNumController.text = '';
      _resiBackNumController.text = '';
    }
    _phoneNumberController.text =
        await SharedPreferencesHelper.getByKey('_phoneNum') ?? '';
    _additionalInfoController.text =
        await SharedPreferencesHelper.getByKey('_addInfo') ?? '';
    _imgEmbd = await SharedPreferencesHelper.getByKey('_imgEmbd') ?? '';
    _image = customAuthProvider.profileImage;
    setState(() {
      _onFormFieldChanged();
    });
  }

  Future<void> _saveFormData() async {
    await SharedPreferencesHelper.saveData('_username', _nameController.text);
    await SharedPreferencesHelper.saveData('_age', _selectedAge ?? '');
    await SharedPreferencesHelper.saveData('_gender', _selectedGender);
    await SharedPreferencesHelper.saveData('_residentNumber',
        '${_resiFrontNumController.text}${_resiBackNumController.text}');
    await SharedPreferencesHelper.saveData(
        '_phoneNum', _phoneNumberController.text);
    await SharedPreferencesHelper.saveData(
        '_addInfo', _additionalInfoController.text);
  }

  void _onFormFieldChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 개인 정보',
            style: TextStyle(
                fontFamily: 'NotoSansKR', fontWeight: FontWeight.w400)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onPreviousPage,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '활동 인증용 사진을 등록해주세요.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              _image != null
                  ? Center(
                      child: Container(
                      width: 200,
                      height: 300,
                      child: Image.file(_image!),
                    ))
                  : Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[300],
                        child: Icon(Icons.photo,
                            size: 100, color: Colors.grey[700]),
                      ),
                    ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // 사진 등록 기능 추가
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
                        "사진 촬영",
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 106, 106, 106),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // 사진 등록 기능 추가
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
                          color: const Color.fromARGB(255, 106, 106, 106),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("이름", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text("필수",
                            style: TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _nameController,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣]')), // 문자만 허용
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _onFormFieldChanged();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("나이", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text("필수",
                            style: TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                    Container(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _selectedAge,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        hint: Text('나이 선택'),
                        items: _ageOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          _selectedAge = newValue;
                          _onFormFieldChanged();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("성별을 선택해주세요.", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text("중복 선택 불가",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.red)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedGender = '남성';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedGender == '남성'
                                  ? Color.fromARGB(255, 224, 73, 81)
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8.0), // 모서리 곡률 설정
                              ),
                            ),
                            child: Text('남성'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedGender = '여성';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedGender == '여성'
                                  ? Color.fromARGB(255, 224, 73, 81)
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8.0), // 모서리 곡률 설정
                              ),
                            ),
                            child: Text('여성'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("주민등록번호를 작성해주세요.", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text("필수",
                            style: TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 60,
                          child: TextField(
                            controller: _resiFrontNumController,
                            maxLength: 6,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              counterText: '',
                            ),
                            onChanged: (value) {
                              _onFormFieldChanged();
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Text("-", style: TextStyle(fontSize: 20)),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 10,
                          child: TextField(
                            controller: _resiBackNumController,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              counterText: '',
                            ),
                            onChanged: (value) {
                              _onFormFieldChanged();
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Text("******",
                            style: TextStyle(
                              fontSize: 20,
                            )),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("회원님 휴대폰 번호를 작성해주세요.",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text("필수",
                            style: TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                    TextField(
                      controller: _phoneNumberController,
                      maxLength: 11,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: "'-'를 제외하고 작성해주세요.",
                      ),
                      onChanged: (value) {
                        _onFormFieldChanged();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("회원님을 소개해주세요.", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text("선택",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.red)),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _additionalInfoController,
                      maxLines: 8,
                      maxLength: 300,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: "시니어가 알아야 할 사항 등을 작성해주세요.",
                      ),
                      onChanged: (value) {
                        _onFormFieldChanged();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton(
          onPressed: _isFormValid
              ? () async {
                  await _saveFormData();
                  widget.onNextPage();
                }
              : null,
          child: Text('다음으로',
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'NotoSansKR',
                  fontWeight: FontWeight.w500)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: Size(double.infinity, 50),
            backgroundColor: Color.fromARGB(255, 224, 73, 81),
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
