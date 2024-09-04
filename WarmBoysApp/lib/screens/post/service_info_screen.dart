import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceInfoScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  ServiceInfoScreen({
    required this.post,
  });

  @override
  _ServiceInfoScreenState createState() => _ServiceInfoScreenState();
}

class _ServiceInfoScreenState extends State<ServiceInfoScreen> {
  bool _canApply = false; // _canApply 변수 선언

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("서비스 상세"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 30,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "기관 정보",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500]),
              ),
              SizedBox(height: 3),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "기관명",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.post['inc']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color.fromARGB(255, 234, 234, 234),
                      thickness: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "장소",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.post['location']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w400,
                          ),
                          softWrap: true, // 줄바꿈 허용
                        ),
                      ],
                    ),
                    Divider(
                      color: Color.fromARGB(255, 234, 234, 234),
                      thickness: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "전화번호",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.post['tel']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color.fromARGB(255, 234, 234, 234),
                      thickness: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 42),
              Text(
                "공고 정보",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500]),
              ),
              SizedBox(height: 3),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "서비스명",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.post['name']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color.fromARGB(255, 234, 234, 234),
                      thickness: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "대상",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.post['target'].replaceAll('\\n', '\n')}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true, // 줄바꿈 허용
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color.fromARGB(255, 234, 234, 234),
                      thickness: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "내용",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.post['content'].replaceAll('\\n', '\n')}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true, // 줄바꿈 허용
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color.fromARGB(255, 234, 234, 234),
                      thickness: 2,
                    ),
                    widget.post['note'] != ''
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "비고",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'NotoSansKR',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    widget.post['note'] != ''
                        ? SizedBox(height: 3)
                        : Container(),
                    widget.post['note'] != ''
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${widget.post['note'].replaceAll('\\n', '\n')}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'NotoSansKR',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  softWrap: true, // 줄바꿈 허용
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    Divider(
                      color: Color.fromARGB(255, 234, 234, 234),
                      thickness: 2,
                    ),
                    Row(
                      children: [
                        Text(
                          "기간",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.post['duration']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true, // 줄바꿈 허용
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color.fromARGB(255, 234, 234, 234),
                      thickness: 2,
                    ),
                    Row(
                      children: [
                        Text(
                          "신청하러 가기",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _launchURL(widget.post['url']);
                            },
                            child: Text(
                              '${widget.post['url']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'NotoSansKR',
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                              ),
                              softWrap: true, // 줄바꿈 허용
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color.fromARGB(255, 234, 234, 234),
                      thickness: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            ],
          ),
        ),
      ),
    );
  }
}
