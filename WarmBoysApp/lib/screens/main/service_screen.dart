import "package:flutter/material.dart";
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_end_drawer.dart';
import '../../utils/firebase_helper.dart';
import '../../screens/post/service_info_screen.dart';

class ServiceScreen extends StatefulWidget {
  ServiceScreen({Key? key}) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  late Future<Map<String, List<Map<String, dynamic>>>> _servicePosts;
  Future<List<Map<String, dynamic>>>? _service_0;
  Future<List<Map<String, dynamic>>>? _service_1;
  Future<List<Map<String, dynamic>>>? _service_2;
  Future<List<Map<String, dynamic>>>? _service_3;
  Future<List<Map<String, dynamic>>>? _service_4;

  @override
  void initState() {
    super.initState();
    _servicePosts = FirebaseHelper.queryServicePosts();
    _initializeServices();
  }

  void _initializeServices() async {
    final posts = await _servicePosts;
    setState(() {
      _service_0 = Future.value(posts['건강생활지원'] ?? []);
      _service_1 = Future.value(posts['노년사회화교육'] ?? []);
      _service_2 = Future.value(posts['문화 및 여가'] ?? []);
      _service_3 = Future.value(posts['사회 참여'] ?? []);
      _service_4 = Future.value(posts['경제적 지원'] ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '서비스',
        leading: null, // '뒤로 가기 버튼' 제거
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("건강생활지원",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 3),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _service_0,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('존재하는 서비스가 없습니다.'));
                } else {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13.0),
                        child: Container(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal, // 횡스크롤로 설정
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data![index];
                              return GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ServiceInfoScreen(post: data),
                                    ),
                                  )
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0, vertical: 8.0),
                                  child: SizedBox(
                                    width: 360, // 카드의 너비를 설정
                                    child: Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 5),
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  data['imgUrl'] as String),
                                              radius: 45,
                                            ),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    data['name'] as String,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    data['inc'] as String,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    (data['duration'] as String)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("노년사회화교육",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 3),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _service_1,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('존재하는 서비스가 없습니다.'));
                } else {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13.0),
                        child: Container(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal, // 횡스크롤로 설정
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data![index];
                              return GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ServiceInfoScreen(post: data),
                                    ),
                                  )
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0, vertical: 8.0),
                                  child: SizedBox(
                                    width: 360, // 카드의 너비를 설정
                                    child: Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 5),
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  data['imgUrl'] as String),
                                              radius: 45,
                                            ),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    data['name'] as String,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    data['inc'] as String,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    (data['duration'] as String)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("문화 및 여가",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 3),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _service_2,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('존재하는 서비스가 없습니다.'));
                } else {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13.0),
                        child: Container(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal, // 횡스크롤로 설정
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data![index];
                              return GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ServiceInfoScreen(post: data),
                                    ),
                                  )
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0, vertical: 8.0),
                                  child: SizedBox(
                                    width: 360, // 카드의 너비를 설정
                                    child: Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 5),
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  data['imgUrl'] as String),
                                              radius: 45,
                                            ),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    data['name'] as String,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontFamily: 'NotoSansKR',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    data['inc'] as String,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    (data['duration'] as String)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("사회 참여",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 3),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _service_3,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('존재하는 서비스가 없습니다.'));
                } else {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13.0),
                        child: Container(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal, // 횡스크롤로 설정
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data![index];
                              return GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ServiceInfoScreen(post: data),
                                    ),
                                  )
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0, vertical: 8.0),
                                  child: SizedBox(
                                    width: 360, // 카드의 너비를 설정
                                    child: Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 5),
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  data['imgUrl'] as String),
                                              radius: 45,
                                            ),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    data['name'] as String,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontFamily: 'NotoSansKR',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    data['inc'] as String,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    (data['duration'] as String)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("경제적 지원",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 3),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _service_4,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('존재하는 서비스가 없습니다.'));
                } else {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13.0),
                        child: Container(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal, // 횡스크롤로 설정
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data![index];
                              return GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ServiceInfoScreen(post: data),
                                    ),
                                  )
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0, vertical: 8.0),
                                  child: SizedBox(
                                    width: 360, // 카드의 너비를 설정
                                    child: Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 5),
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  data['imgUrl'] as String),
                                              radius: 45,
                                            ),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    data['name'] as String,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontFamily: 'NotoSansKR',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    data['inc'] as String,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    (data['duration'] as String)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'NotoSansKR',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          ],
        ),
      ),
      endDrawer: CustomEndDrawer(),
    );
  }
}
