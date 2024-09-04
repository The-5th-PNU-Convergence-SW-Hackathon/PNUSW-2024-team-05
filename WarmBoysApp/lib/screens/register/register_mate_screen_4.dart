import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warm_boys/providers/custom_auth_provider.dart';
import '../../utils/shared_preferences_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RegisterMateScreen4 extends StatefulWidget {
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  RegisterMateScreen4({required this.onNextPage, required this.onPreviousPage});

  @override
  _RegisterMateScreen4State createState() => _RegisterMateScreen4State();
}

class _RegisterMateScreen4State extends State<RegisterMateScreen4> {
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  late ImagePicker imagePicker;
  File? _image;

  // 대학교 목록
  final List<String> _universities = [
    '경남정보대학교',
    '경성대학교',
    '고신대학교',
    '한국해양대학교',
    '동명대학교',
    '동서대학교',
    '동아대학교',
    '동의대학교',
    '부경대학교',
    '부산가톨릭대학교',
    '부산경상대학교',
    '부산과학기술대학교',
    '부산교육대학교',
    '부산대학교',
    '부산보건대학교',
    '부산여자대학교',
    '부산예술대학교',
    '부산외국어대학교',
    '신라대학교',
    '영산대학교',
    '인제대학교',
    '대동대학교',
    '동의과학대학교',
    '한국폴리텍VII대학',
  ];

  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _loadFormData() async {
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    _universityController.text =
        await SharedPreferencesHelper.getByKey('_university') ?? '';
    _departmentController.text =
        await SharedPreferencesHelper.getByKey('_department') ?? '';
    _image = customAuthProvider.schoolCertImage;
    setState(() {
      _onFormFieldChanged();
    });
  }

  Future<void> _saveFormData() async {
    await SharedPreferencesHelper.saveData(
        '_university', _universityController.text);
    await SharedPreferencesHelper.saveData(
        '_department', _departmentController.text);
  }

  void _onFormFieldChanged() {
    setState(() {});
  }

  bool get _isFormValid {
    return _universityController.text.isNotEmpty &&
        _departmentController.text.isNotEmpty &&
        _universities.contains(_universityController.text) &&
        _image != null;
  }

  @override
  void initState() {
    _loadFormData();
    imagePicker = ImagePicker();
    super.initState();
  }

  @override
  void dispose() {
    _universityController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('소속을 인증해 주세요.',
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "1. 소속",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  "*",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _universities.where((String university) {
                  return university.contains(textEditingValue.text);
                });
              },
              onSelected: (String selection) {
                _universityController.text = selection;
                _onFormFieldChanged();
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                fieldTextEditingController.text = _universityController.text;
                fieldTextEditingController.selection =
                    TextSelection.fromPosition(
                  TextPosition(offset: fieldTextEditingController.text.length),
                );

                fieldTextEditingController.addListener(() {
                  if (_universityController.text !=
                      fieldTextEditingController.text) {
                    _universityController.text =
                        fieldTextEditingController.text;
                    _onFormFieldChanged();
                  }
                });

                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    labelText: '대학교',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    _onFormFieldChanged();
                  },
                );
              },
            ),
            SizedBox(height: 20),

            // 학과 입력 섹션
            TextField(
              controller: _departmentController,
              decoration: InputDecoration(
                labelText: '학과',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                _onFormFieldChanged();
              },
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "2. 학생증 사진",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  "*",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            _image != null
                ? Center(
                    child: Container(
                    width: 300,
                    height: 200,
                    child: Image.file(_image!),
                  ))
                : Center(
                    child: Container(
                      width: 300,
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                          child: Text("학생증 사진을 등록해주세요.",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'NotoSansKR',
                                  fontWeight: FontWeight.w400))),
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
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton(
          onPressed: _isFormValid
              ? () async {
                  await _saveFormData();
                  if (_image != null) {
                    customAuthProvider.setSchoolCertImage(_image);
                  }
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
