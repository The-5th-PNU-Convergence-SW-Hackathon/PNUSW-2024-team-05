import 'package:flutter/material.dart';
import '../../utils/shared_preferences_helper.dart';

// 회원가입 스크린 2(시니어)
class RegisterSeniorScreen2 extends StatefulWidget {
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  RegisterSeniorScreen2(
      {required this.onNextPage, required this.onPreviousPage});

  @override
  _RegisterSeniorScreen2State createState() => _RegisterSeniorScreen2State();
}

class _RegisterSeniorScreen2State extends State<RegisterSeniorScreen2> {
  String selectedCity = '부산광역시';
  String selectedDistrict = '금정구';
  String? selectedSubDistrict;
  String detailedAddress = ''; // 상세 주소 저장

  final TextEditingController _addressController = TextEditingController();

  Map<String, List<String>> cityDistrictMap = {
    '서울특별시': [],
    '부산광역시': [
      '강서구',
      '금정구',
      '기장군',
      '남구',
      '동구',
      '동래구',
      '부산진구',
      '북구',
      '사상구',
      '사하구',
      '서구',
      '수영구',
      '연제구',
      '영도구',
      '중구',
      '해운대구'
    ],
    '대구광역시': [],
    '인천광역시': [],
    '광주광역시': [],
    '대전광역시': [],
    '울산광역시': [],
    '세종특별자치시': [],
    '경기도': [],
    '강원특별자치도': [],
    '충청북도': [],
    '충청남도': [],
    '전북특별자치도': [],
    '전라남도': [],
    '경상북도': [],
    '경상남도': [],
    '제주특별자치도': [],
  };

  Map<String, List<String>> districtSubDistrictMap = {
    '금정구': [
      '구서1동',
      '구서2동',
      '금사회동동',
      '금성동',
      '남산동',
      '부곡1동',
      '부곡2동',
      '부곡3동',
      '부곡4동',
      '서1동',
      '서2동',
      '서3동',
      '선두구동',
      '장전1동',
      '장전2동',
      '청룡노포동'
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadSavedAddress(); // 수정된 메서드 호출
  }

  Future<void> _loadSavedAddress() async {
    // 저장된 동과 상세 주소 불러오기
    String? subDistrict = await SharedPreferencesHelper.getByKey('_dong');
    String? savedDetailedAddress =
        await SharedPreferencesHelper.getByKey('_detailedAddress');

    setState(() {
      if (subDistrict != null) {
        selectedSubDistrict = subDistrict;
      } else {
        selectedSubDistrict = districtSubDistrictMap[selectedDistrict]![0];
      }

      if (savedDetailedAddress != null) {
        detailedAddress = savedDetailedAddress;
        _addressController.text = detailedAddress; // 텍스트 필드에 값 표시
      }
    });
  }

  Future<void> _saveLocationData() async {
    await SharedPreferencesHelper.saveData('_city', selectedCity);
    await SharedPreferencesHelper.saveData('_gu', selectedDistrict);
    await SharedPreferencesHelper.saveData('_dong', selectedSubDistrict!);
    await SharedPreferencesHelper.saveData('_detailedAddress', detailedAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('어디서 돌봐드릴까요?',
            style: TextStyle(
                fontFamily: 'NotoSansKR', fontWeight: FontWeight.w400)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onPreviousPage,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "1. 거주 지역을 선택해 주세요.",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2),
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: SingleChildScrollView(
                        child: _buildButtonColumn(
                          cityDistrictMap.keys.toList(),
                          selectedCity,
                          (value) {},
                          true, // 1열은 비활성화
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: SingleChildScrollView(
                      child: _buildButtonColumn(
                        cityDistrictMap[selectedCity]!,
                        selectedDistrict,
                        (value) {},
                        true, // 2열은 비활성화
                      ),
                    ),
                  )),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: SingleChildScrollView(
                        child: _buildButtonColumn(
                          districtSubDistrictMap[selectedDistrict]!,
                          selectedSubDistrict,
                          (value) {
                            setState(() {
                              selectedSubDistrict = value;
                            });
                          },
                          false, // 3열은 활성화
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "2. 상세 주소를 작성해 주세요.",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2),
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
              SizedBox(height: 10),
              TextField(
                controller: _addressController,
                onChanged: (value) {
                  setState(() {
                    detailedAddress = value;
                  });
                },
                maxLength: 30,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '상세 주소를 입력하세요. (30자 이내)',
                  hintStyle: TextStyle(
                      fontSize: 16,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton(
          onPressed: selectedSubDistrict != null && detailedAddress.isNotEmpty
              ? () async {
                  await _saveLocationData();
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

  Widget _buildButtonColumn(List<String> items, String? selectedItem,
      ValueChanged<String> onPressed, bool isDisabled) {
    return Column(
      children: items.map((item) {
        final isSelected = item == selectedItem;
        return SizedBox(
          width: double.infinity,
          height: 50.0,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (isSelected) {
                  return Colors.red.shade100; // 선택된 버튼 색상
                }
                if (isDisabled) {
                  return Colors.grey.shade300; // 비활성화 상태의 선택되지 않은 버튼 색상
                }
                return Colors.white; // 3열의 선택되지 않은 버튼 색상
              }),
              foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (isSelected) {
                  return Colors.red; // 선택된 버튼 텍스트 색상
                }
                if (isDisabled) {
                  return Colors.grey.shade700; // 비활성화 상태의 선택되지 않은 버튼 텍스트 색상
                }
                return Colors.black; // 3열의 선택되지 않은 버튼 텍스트 색상
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // 테두리 곡률 없애기
                  side: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            onPressed: isDisabled
                ? null
                : () => onPressed(item), // 비활성화 여부에 따라 onPressed 설정
            child: Text(
              item,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSansKR',
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        );
      }).toList(),
    );
  }
}
