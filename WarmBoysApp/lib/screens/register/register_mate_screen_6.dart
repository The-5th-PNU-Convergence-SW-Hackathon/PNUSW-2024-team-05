import 'package:flutter/material.dart';
import '../../utils/shared_preferences_helper.dart';

// 회원가입 스크린 5(메이트)
class RegisterMateScreen6 extends StatefulWidget {
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  RegisterMateScreen6({required this.onNextPage, required this.onPreviousPage});

  @override
  _RegisterMateScreen6State createState() => _RegisterMateScreen6State();
}

class _RegisterMateScreen6State extends State<RegisterMateScreen6> {
  String _username = '';
  String _age = '';
  String _phoneNum = '';
  String _city = '';
  String _gu = '';
  String _dong = '';
  String _detailedAddress = '';
  List<String> _activityType = [];
  String _addInfo = '';
  Map<String, dynamic> _dayTime = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    SharedPreferencesHelper.printAll();
  }

  Future<void> _loadData() async {
    _username = await SharedPreferencesHelper.getByKey('_username') ?? '';
    _age = await SharedPreferencesHelper.getByKey('_age') ?? '';
    _phoneNum = await SharedPreferencesHelper.getByKey('_phoneNum') ?? '';
    _city = await SharedPreferencesHelper.getByKey('_city') ?? '';
    _gu = await SharedPreferencesHelper.getByKey('_gu') ?? '';
    _dong = await SharedPreferencesHelper.getByKey('_dong') ?? '';
    _detailedAddress =
        await SharedPreferencesHelper.getByKey('_detailedAddress') ?? '';
    _activityType =
        await SharedPreferencesHelper.getStringList('_activityType') ?? [];
    _addInfo = await SharedPreferencesHelper.getByKey('_addInfo') ?? '';
    _dayTime = await SharedPreferencesHelper.getJson('_dayTime') ?? {};
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
              _buildInfoRow('성함:', _username, fontSize: 16.0),
              SizedBox(height: 10),
              _buildInfoRow('나이:', _age, fontSize: 16.0),
              SizedBox(height: 10),
              _buildInfoRow('연락처:', _phoneNum, fontSize: 16.0),
              SizedBox(height: 10),
              _buildInfoRow('지역:', '$_city > $_gu > $_dong', fontSize: 16.0),
              SizedBox(height: 10),
              _buildDetailedAddressSection(),
              SizedBox(height: 30),
              _buildActivitySection(),
              SizedBox(height: 30),
              _buildAvailableTimeSection(),
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
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '제공 서비스',
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
                      style: TextStyle(fontSize: 12),
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

  Widget _buildAvailableTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '활동 가능 시간',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _daysOfWeek.map((day) {
              final dayInfo = _dayTime[day];
              final startTime =
                  dayInfo != null ? DateTime.parse(dayInfo['startTime']) : null;
              final endTime =
                  dayInfo != null ? DateTime.parse(dayInfo['endTime']) : null;
              final isMorning = startTime != null &&
                  endTime != null &&
                  startTime.hour < 12 &&
                  endTime.hour < 12;
              final isAfternoon = startTime != null &&
                  endTime != null &&
                  startTime.hour >= 12 &&
                  endTime.hour >= 12;
              final isFullDay = startTime != null &&
                  endTime != null &&
                  startTime.hour < 12 &&
                  endTime.hour >= 12;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: dayInfo != null
                          ? Color.fromARGB(255, 224, 73, 81)
                          : Colors.grey,
                      child: Text(
                        day,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 5),
                    Icon(
                      Icons.wb_sunny,
                      size: 30,
                      color: isMorning || isFullDay
                          ? Color.fromARGB(255, 224, 73, 81)
                          : Colors.grey,
                    ),
                    SizedBox(height: 5),
                    Icon(
                      Icons.nights_stay,
                      size: 30,
                      color: isAfternoon || isFullDay
                          ? Color.fromARGB(255, 224, 73, 81)
                          : Colors.grey,
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              );
            }).toList(),
          ),
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
            style: TextStyle(fontSize: 14),
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

  List<String> get _daysOfWeek => ['일', '월', '화', '수', '목', '금', '토'];
}
