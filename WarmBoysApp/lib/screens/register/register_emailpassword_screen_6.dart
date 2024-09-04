import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warm_boys/providers/custom_auth_provider.dart';
import '../../utils/shared_preferences_helper.dart';
import '../../utils/firebase_helper.dart';
import '../../providers/custom_auth_provider.dart';
import 'package:provider/provider.dart';

// 회원가입 스크린 6(이메일, 비밀번호)
class RegisterEmailpasswordScreen6 extends StatefulWidget {
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  RegisterEmailpasswordScreen6(
      {required this.onNextPage, required this.onPreviousPage});

  @override
  _RegisterEmailpasswordScreen6State createState() =>
      _RegisterEmailpasswordScreen6State();
}

class _RegisterEmailpasswordScreen6State
    extends State<RegisterEmailpasswordScreen6> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<String> _emailDomains = ['gmail.com', 'yahoo.com', 'naver.com'];
  String? _selectedDomain;
  bool _isFormValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register(CustomAuthProvider customAuthProvider) async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    bool emailExists = await FirebaseHelper.checkEmail(email);
    if (emailExists) {
      try {
        await SharedPreferencesHelper.saveData('_email', email);
        await SharedPreferencesHelper.saveData('_password', password);

        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // SharedPreferences에서 _memberType 확인
        final memberType =
            await SharedPreferencesHelper.getByKey('_memberType');

        if (memberType == '시니어') {
          // Firestore에 시니어 데이터 저장
          await FirebaseHelper.saveSenior(
              userCredential.user!.uid, customAuthProvider);
        } else if (memberType == '메이트') {
          // Firestore에 메이트 데이터 저장
          await FirebaseHelper.saveMate(
              userCredential.user!.uid, customAuthProvider);
        }

        // 콘솔창에 shared preference 정보 모두 삭제
        await SharedPreferencesHelper.clearAll();

        widget.onNextPage();
      } catch (e) {
        print('Error: $e');
        // 오류 발생 시 처리 (예: 다이얼로그로 사용자에게 알리기)
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _isFormValid = false;
      });
      print("이메일이 이미 존재합니다.");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('이메일이 이미 존재합니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customAuthProvider = Provider.of<CustomAuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("이메일 / 비밀번호 입력",
            style: TextStyle(
                fontFamily: 'NotoSansKR', fontWeight: FontWeight.w400)),
        automaticallyImplyLeading: false, // 기본 뒤로 가기 버튼을 비활성화
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onPreviousPage,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmailField(),
              SizedBox(height: 20),
              _buildPasswordField(),
              SizedBox(height: 20),
              _buildConfirmPasswordField(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed:
                    _isFormValid ? () => _register(customAuthProvider) : null,
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

  Widget _buildEmailField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email),
              hintText: '이메일',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        hintText: '비밀번호',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        hintText: '비밀번호 확인',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
    );
  }
}
