import 'package:flutter/material.dart';
import '../../utils/shared_preferences_helper.dart';

// 회원가입 스크린 5(시니어)
class RegisterSeniorScreen5 extends StatefulWidget {
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  RegisterSeniorScreen5(
      {required this.onNextPage, required this.onPreviousPage});

  @override
  _RegisterSeniorScreen5State createState() => _RegisterSeniorScreen5State();
}

class _RegisterSeniorScreen5State extends State<RegisterSeniorScreen5> {
  String _username = '';
  String _age = '';
  List<String> _activityType = [];
  String _city = '';
  String _gu = '';
  String _dong = '';
  String _detailedAddress = '';
  String _dependentType = '';
  bool _withPet = false;
  bool _withCam = false;
  List<String> _symptom = [];
  String _walkingType = '';
  String _phoneNum = '';
  String _phoneNum2 = '';
  String _addInfo = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _username = await SharedPreferencesHelper.getByKey('_username') ?? '';
    _age = await SharedPreferencesHelper.getByKey('_age') ?? '';
    _activityType =
        await SharedPreferencesHelper.getStringList('_activityType') ?? [];
    _city = await SharedPreferencesHelper.getByKey('_city') ?? '';
    _gu = await SharedPreferencesHelper.getByKey('_gu') ?? '';
    _dong = await SharedPreferencesHelper.getByKey('_dong') ?? '';
    _detailedAddress =
        await SharedPreferencesHelper.getByKey('_detailedAddress') ?? '';
    _dependentType =
        await SharedPreferencesHelper.getByKey('_dependentType') ?? '';
    _withPet = await SharedPreferencesHelper.getBool('_withPet') ?? false;
    _withCam = await SharedPreferencesHelper.getBool('_withCam') ?? false;
    _symptom = await SharedPreferencesHelper.getStringList('_symptom') ?? [];
    _walkingType = await SharedPreferencesHelper.getByKey('_walkingType') ?? '';
    _phoneNum = await SharedPreferencesHelper.getByKey('_phoneNum') ?? '';
    _phoneNum2 = await SharedPreferencesHelper.getByKey('_phoneNum2') ?? '';
    _addInfo = await SharedPreferencesHelper.getByKey('_addInfo') ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가입 정보 상세',
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
              _buildInfoRow('성함:', _username, fontSize: 18.0),
              SizedBox(height: 10),
              _buildInfoRow('나이:', _age, fontSize: 18.0),
              SizedBox(height: 10),
              _buildInfoRow('연락처:', _phoneNum, fontSize: 18.0),
              SizedBox(height: 10),
              _buildInfoRow('비상 연락망:', _phoneNum2, fontSize: 18.0),
              SizedBox(height: 10),
              _buildLocationSection(),
              SizedBox(height: 10),
              _buildDetailedAddressSection(),
              SizedBox(height: 30),
              _buildActivitySection(),
              SizedBox(height: 30),
              _buildDependentSection(),
              SizedBox(height: 30),
              _buildSymptomsSection(),
              SizedBox(height: 30),
              _buildWalkingSection(),
              SizedBox(height: 30),
              _buildAdditionalInfoSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton(
          onPressed: () async {
            widget.onNextPage();
          },
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

  Widget _buildInfoRow(String label, String value, {double fontSize = 18.0}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '희망하는 서비스',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _activityType.map((activity) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Icon(
                      _getActivityIcon(activity),
                      size: 40,
                    ),
                    SizedBox(height: 5),
                    Text(
                      activity,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '지역:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '$_city > $_gu > $_dong',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 주소:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(8.0),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            _detailedAddress,
            style: TextStyle(fontSize: 16),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDependentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '회원 주거 환경',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (_dependentType.isNotEmpty)
                _buildDependentCard(_dependentType),
              if (_withPet) _buildDependentCard('반려동물'),
              if (_withCam) _buildDependentCard('CCTV'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDependentCard(String type) {
    IconData icon;
    switch (type) {
      case '독거':
        icon = Icons.person;
        break;
      case '2~3인':
        icon = Icons.group;
        break;
      case '4인 이상':
        icon = Icons.people;
        break;
      case '반려동물':
        icon = Icons.pets;
        break;
      case 'CCTV':
        icon = Icons.videocam;
        break;
      default:
        icon = Icons.help_outline;
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40),
            SizedBox(height: 10),
            Text(type, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '해당되는 증상',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _symptom.map((symptom) {
              return Container(
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(symptom, style: TextStyle(fontSize: 16)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWalkingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '거동 상태',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(_walkingType, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추가 내용',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(8.0),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            _addInfo,
            style: TextStyle(fontSize: 16),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String activity) {
    switch (activity) {
      case '실내 오락':
        return Icons.games;
      case '실외 활동':
        return Icons.nature_people;
      case '식사 지원':
        return Icons.restaurant;
      case '사회적 교류':
        return Icons.people;
      case '문화 및 여가':
        return Icons.theater_comedy;
      case '정서적 지원':
        return Icons.favorite;
      case '지적 활동':
        return Icons.book;
      case '디지털 교육':
        return Icons.computer;
      case '생활 지원':
        return Icons.cleaning_services;
      case '예술 및 창작':
        return Icons.brush;
      case '재능 기부':
        return Icons.volunteer_activism;
      case '취미 활동':
        return Icons.local_florist;
      default:
        return Icons.help_outline;
    }
  }
}
