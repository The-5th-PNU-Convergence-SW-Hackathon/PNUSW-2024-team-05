import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/services.dart';

class WriteInquiryScreen extends StatefulWidget {
  final String uid;

  WriteInquiryScreen({required this.uid});

  @override
  _WriteInquiryScreenState createState() => _WriteInquiryScreenState();
}

class _WriteInquiryScreenState extends State<WriteInquiryScreen> {
  String? _selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isButtonEnabled = false;

  final List<String> _inquiryCategories = [
    '매칭 관련 일반 문의',
    '채팅 관련 일반 문의',
    '프로필',
    '홈페이지 공고',
    '크레딧 반영 오류',
    '얼굴 인증 문의',
  ];

  @override
  void initState() {
    super.initState();

    _titleController.addListener(_onTextFieldChanged);
    _contentController.addListener(_onTextFieldChanged);
  }

  void _onTextFieldChanged() {
    setState(() {
      _isButtonEnabled = _selectedCategory != null &&
          _titleController.text.isNotEmpty &&
          _contentController.text.isNotEmpty;
    });
  }

  Future<void> _sendEmail() async {
    final String subject = '[${_selectedCategory}] ${_titleController.text}';
    final String body = 'uid: ${widget.uid}\n\n${_contentController.text}';

    final Email emailToSend = Email(
      body: body,
      subject: subject,
      recipients: ['addarrow3@gmail.com'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(emailToSend);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문의가 접수되었습니다.')),
      );

      // 키보드 내려가게 하기
      FocusScope.of(context).unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      _resetForm();
    } catch (error) {
      print('Email send error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문의 접수에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCategory = null;
      _titleController.clear();
      _contentController.clear();
      _isButtonEnabled = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '문의하기',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "문의 분류",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "*",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: Text('문의 분류를 선택하세요'),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                      _onTextFieldChanged();
                    },
                    items: _inquiryCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "문의 제목",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "*",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    maxLength: 20,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '제목을 입력해 주세요. (20자 이내)',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "문의 내용",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "*",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '문의 내용을 입력하세요',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled ? _sendEmail : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _isButtonEnabled
                            ? Color.fromARGB(255, 245, 174, 168)
                            : Colors.grey,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        '문의 접수',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
