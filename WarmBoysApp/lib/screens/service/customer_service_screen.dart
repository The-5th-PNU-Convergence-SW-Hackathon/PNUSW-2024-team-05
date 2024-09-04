import 'package:flutter/material.dart';
import 'package:warm_boys/screens/service/write_inquiry_screen.dart';

class CustomerServiceScreen extends StatelessWidget {
  final String uid;

  CustomerServiceScreen({required this.uid});

  final List<Map<String, String>> _faqList = [
    {
      "question": "회원가입을 할 때 사진 촬영을 하는 이유가 뭔가요",
      "answer": "회원가입 시 제출한 사진은 추후 활동의 인증용 및 프로필 사진으로 사용됩니다."
    },
    {
      "question": "시니어의 상세한 주소를 알려면 어떻게 해야 하나요?",
      "answer":
          "시니어의 상세 주소는 매칭이 완료된 후에만 확인할 수 있습니다. '매칭'화면의 '매칭 후' 탭에서 시니어 카드를 클릭하면 상세 주소를 확인하실 수 있습니다."
    },
    {
      "question": "활동을 시작하려면 얼굴 인증이 필요한가요?",
      "answer":
          "네, 활동을 시작하기 위해서는 얼굴 인증이 반드시 필요합니다. 얼굴 인증이 완료되어야만 활동을 시작할 수 있습니다."
    },
    {
      "question": "활동을 종료할 때도 얼굴 인증이 필요한가요?",
      "answer":
          "네, 활동을 종료할 때도 얼굴 인증이 필요합니다. 얼굴 인증이 완료되어야만 활동이 종료되며, 이후 크레딧이 적립됩니다."
    },
    {
      "question": "활동 중 문제가 발생하면 어떻게 해야 하나요?",
      "answer":
          "활동 중 문제가 발생하면 즉시 다음 단계를 따라야 합니다.\n\n1. 우측 상단의 프로필 이미지 버튼 클릭\n2. '고객센터' 버튼 클릭\n3. 하단의 '문의하기' 버튼 클릭\n4. 문의 사항 작성 후, '문의 접수' 클릭"
    },
    {
      "question": "활동이 완료되면 어떤 절차가 이루어지나요?",
      "answer": "활동이 완료되면 시니어와 메이트 상호 간의 후기와 평점을 남길 수 있으며, 메이트는 크레딧을 적립받습니다."
    },
    {"question": "크레딧은 어떻게 적립되나요?", "answer": "활동이 완료된 후 크레딧이 즉시 적립됩니다."},
    {
      "question": "크레딧으로 어떤 혜택을 받을 수 있나요?",
      "answer":
          "적립된 크레딧은 다양한 상품권이나 장학금으로 교환할 수 있습니다. 교환 가능한 혜택은 앱 내의 '교환' 화면에서 확인할 수 있습니다."
    },
    {
      "question": "매칭 신청은 어떻게 하나요?",
      "answer":
          "메이트는 시니어가 올린 공고글을 보고 매칭 신청을 할 수 있습니다. 신청 후 시니어가 한 명의 메이트를 선택하게 됩니다."
    },
    {
      "question": "얼굴 인증이 실패했을 때는 어떻게 해야 하나요?",
      "answer": "얼굴 인증이 실패할 경우 앱을 재시작하거나, 고객센터에 문의해 문제를 해결할 수 있습니다."
    },
  ];

  void _showFAQDialog(BuildContext context, String question, String answer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          question,
          style: TextStyle(fontSize: 20),
        ),
        content: Text(
          '\n$answer',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '고객 센터',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '따뜻한 청년들입니다.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '무엇을 도와드릴까요?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey[200],
              thickness: 7,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "자주 묻는 질문",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ..._faqList.map((faq) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showFAQDialog(
                              context,
                              faq["question"]!,
                              faq["answer"]!,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Text(
                                  "Q",
                                  style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 28, 125, 204),
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    faq["question"]!,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey[200], thickness: 1),
                      ],
                    );
                  }).toList(),
                  SizedBox(height: 200),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 150, // 버튼 너비를 조절
        child: FloatingActionButton.extended(
          backgroundColor: Colors.black,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WriteInquiryScreen(uid: uid),
              ),
            );
          },
          icon: Icon(Icons.edit, color: Colors.white),
          label: Text(
            '문의하기',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
