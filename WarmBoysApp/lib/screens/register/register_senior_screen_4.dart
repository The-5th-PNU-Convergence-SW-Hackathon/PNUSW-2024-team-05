import 'package:flutter/material.dart';
import '../../utils/shared_preferences_helper.dart';

// 회원가입 스크린 4(시니어)
class RegisterSeniorScreen4 extends StatefulWidget {
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  RegisterSeniorScreen4(
      {required this.onNextPage, required this.onPreviousPage});

  @override
  _RegisterSeniorScreen4State createState() => _RegisterSeniorScreen4State();
}

class _RegisterSeniorScreen4State extends State<RegisterSeniorScreen4> {
  String _selectedLivingOption = '2~3인';
  bool _hasPet = false;
  List<String> _selectedSymptoms = [];
  bool _selectedCCTVOption = false;
  String _selectedMobilityOption = '자가 보행';
  String? _petInfo;
  String? _symptomInfo;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    String? dependentType =
        await SharedPreferencesHelper.getByKey('_dependentType');
    bool hasPet = await SharedPreferencesHelper.getBool('_withPet') ?? false;
    String? petInfo = await SharedPreferencesHelper.getByKey('_petInfo');
    bool withCam = await SharedPreferencesHelper.getBool('_withCam') ?? false;
    List<String> symptomList =
        await SharedPreferencesHelper.getStringList('_symptom') ?? [];
    String? symptomInfo =
        await SharedPreferencesHelper.getByKey('_symptomInfo');
    String? walkingType =
        await SharedPreferencesHelper.getByKey('_walkingType');

    setState(() {
      _selectedLivingOption = dependentType ?? '2~3인';
      _hasPet = hasPet;
      _petInfo = petInfo;
      _selectedCCTVOption = withCam;
      _selectedSymptoms = symptomList;
      _symptomInfo = symptomInfo;
      _selectedMobilityOption = walkingType ?? '자가 보행';
    });
  }

  Future<void> _saveFormData() async {
    await SharedPreferencesHelper.saveData(
        '_dependentType', _selectedLivingOption);
    await SharedPreferencesHelper.saveBool('_withPet', _hasPet);
    await SharedPreferencesHelper.saveData('_petInfo', _petInfo ?? '');
    await SharedPreferencesHelper.saveBool('_withCam', _selectedCCTVOption);
    await SharedPreferencesHelper.saveStringList('_symptom', _selectedSymptoms);
    await SharedPreferencesHelper.saveData('_symptomInfo', _symptomInfo ?? '');
    await SharedPreferencesHelper.saveData(
        '_walkingType', _selectedMobilityOption);
  }

  void _toggleCCTVOption(bool option) {
    setState(() {
      _selectedCCTVOption = option;
    });
  }

  void _toggleLivingOption(String option) {
    setState(() {
      _selectedLivingOption = option;
    });
  }

  void _toggleHasPet() {
    setState(() {
      _hasPet = !_hasPet;
    });
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  void _toggleMobilityOption(String option) {
    setState(() {
      _selectedMobilityOption = option;
    });
  }

  Widget _buildImageCard(String text, IconData icon, String option) {
    final isSelected = _selectedLivingOption == option;
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleLivingOption(option),
        child: Card(
          color: isSelected ? Color.fromARGB(255, 251, 196, 198) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4,
          child: Container(
            width: 80,
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.grey),
                SizedBox(height: 5),
                Text(text, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(String text, IconData icon) {
    return GestureDetector(
      onTap: _toggleHasPet,
      child: Card(
        color: _hasPet ? Color.fromARGB(255, 251, 196, 198) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(16.0),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.grey),
              SizedBox(width: 10),
              Text(text, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedButton(
      String text, bool isSelected, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor:
              isSelected ? Color.fromARGB(255, 224, 73, 81) : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'NotoSansKR',
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildSymptomButton(String text) {
    final isSelected = _selectedSymptoms.contains(text);
    return ElevatedButton(
      onPressed: () => _toggleSymptom(text),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Color.fromARGB(255, 224, 73, 81) : Colors.grey,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansKR',
              fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 상세 정보',
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
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q1. 함께 사는 동거인과 반려동물 정보를 선택해주세요.",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildImageCard('독거', Icons.person, '독거'),
                        _buildImageCard('2~3인', Icons.group, '2~3인'),
                        _buildImageCard('4인 이상', Icons.people, '4인 이상'),
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildPetCard('반려동물', Icons.pets),
                    if (_hasPet) ...[
                      SizedBox(height: 20),
                      Text(
                        "Q1-1. 반려동물 종류와 유의사항을 작성해주세요.",
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: TextEditingController(text: _petInfo),
                        maxLines: 5,
                        maxLength: 200,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _petInfo = value;
                        },
                      ),
                    ]
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q2. 집 내부 홈캠 또는 CCTV 설치 유무를 선택해주세요.",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildElevatedButton('없음', !_selectedCCTVOption, () {
                          _toggleCCTVOption(false);
                        }),
                        SizedBox(width: 8),
                        _buildElevatedButton('있음', _selectedCCTVOption, () {
                          _toggleCCTVOption(true);
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q3. 회원님에게 해당되는 증상을 선택해주세요.",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 3,
                      children: [
                        _buildSymptomButton('치매'),
                        _buildSymptomButton('섬망'),
                        _buildSymptomButton('피딩'),
                        _buildSymptomButton('정신 질환'),
                        _buildSymptomButton('재활'),
                        _buildSymptomButton('난청'),
                        _buildSymptomButton('시력'),
                        _buildSymptomButton('인지력'),
                        _buildSymptomButton('관절질염'),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Q3-1.상세증상 기재",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: _symptomInfo),
                      maxLines: 8,
                      maxLength: 300,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _symptomInfo = value;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q4. 회원님의 거동 상태를 선택해주세요.",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildElevatedButton(
                            '자가 보행', _selectedMobilityOption == '자가 보행', () {
                          _toggleMobilityOption('자가 보행');
                        }),
                        SizedBox(width: 8),
                        _buildElevatedButton(
                            '보행 도구 필요', _selectedMobilityOption == '보행 도구 필요',
                            () {
                          _toggleMobilityOption('보행 도구 필요');
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton(
          onPressed: () async {
            await _saveFormData();
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
}
