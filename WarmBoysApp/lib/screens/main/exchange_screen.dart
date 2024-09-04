import 'package:flutter/material.dart';
import 'package:warm_boys/widgets/custom_app_bar.dart';
import '../../widgets/custom_end_drawer.dart';
import 'package:provider/provider.dart';
import '../../providers/custom_auth_provider.dart';
import '../../utils/firebase_helper.dart';
import '../post/exchange_goods_info_screen.dart';
import '../post/exchange_donation_info_screen.dart';
import '../post/exchange_volunteer_info_screen.dart';

class ExchangeScreen extends StatefulWidget {
  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, List<Map<String, dynamic>>>> _exchangePosts;
  Future<List<Map<String, dynamic>>>? _exchange_0;
  Future<List<Map<String, dynamic>>>? _exchange_1;

  @override
  void initState() {
    super.initState();
    _exchangePosts = FirebaseHelper.queryExchangePosts();
    _initializeExchanges();
  }

  void _initializeExchanges() async {
    final posts = await _exchangePosts;
    setState(() {
      _exchange_0 = Future.value(posts['기관장학금'] ?? []);
      _exchange_1 = Future.value(posts['기업상품'] ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customAuthProvider = Provider.of<CustomAuthProvider>(context);
    final userInfo = customAuthProvider.userInfo;
    final uid = customAuthProvider.uid!;
    final myCredit = userInfo!['credit'] ?? 0;
    final memberType = userInfo['memberType'];
    final university =
        userInfo['university'].substring(0, userInfo['university'].length - 2);

    return Scaffold(
      appBar: CustomAppBar(title: "교환"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                          bottomLeft: Radius.circular(12.0),
                          bottomRight: Radius.circular(12.0),
                        ),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.435,
                        width: MediaQuery.of(context).size.width * 0.435,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 255, 204, 128),
                              Colors.orange,
                              Color.fromARGB(255, 224, 73, 81),
                              Color.fromARGB(255, 224, 42, 51),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // 세로 가운데 정렬
                            children: [
                              Text(
                                "1365",
                                style: TextStyle(
                                  fontSize: 34,
                                  color: Colors.white,
                                  fontFamily: 'Tenada',
                                ),
                              ),
                              Text(
                                "봉사시간\n신청하기",
                                style: TextStyle(
                                    fontSize: 20,
                                    height: 1.5,
                                    color: Colors.white,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExchangeVolunteerInfoScreen(
                            inc: '1365',
                          ),
                        ),
                      )
                    },
                  ),
                  GestureDetector(
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                          bottomLeft: Radius.circular(12.0),
                          bottomRight: Radius.circular(12.0),
                        ),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.435,
                        width: MediaQuery.of(context).size.width * 0.435,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 90, 173, 240),
                              Color.fromARGB(255, 3, 129, 231),
                              Color.fromARGB(255, 59, 75, 255),
                              Color.fromARGB(255, 71, 93, 233),
                              Color.fromARGB(255, 59, 75, 255),
                              Color.fromARGB(255, 3, 129, 231),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // 세로 가운데 정렬
                            children: [
                              Text(
                                "${university}",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 34,
                                  color: Colors.white,
                                  fontFamily: 'Tenada',
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "봉사시간\n신청하기",
                                style: TextStyle(
                                    fontSize: 20,
                                    height: 1.5,
                                    color: Colors.white,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExchangeVolunteerInfoScreen(
                            inc: userInfo['university'],
                          ),
                        ),
                      )
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 1,
                color: Color.fromARGB(255, 50, 50, 50).withOpacity(0.8),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${userInfo['username']}" 님의 크레딧',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontFamily: 'NotoSansKR',
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  myCredit.toString(),
                                  style: TextStyle(
                                    fontSize: 44,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontFamily: 'NotoSansKR',
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("복지재단 후원",
                  style: TextStyle(
                      color: const Color.fromARGB(137, 4, 4, 4),
                      fontSize: 21,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _exchange_0,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('존재하는 교환이 없습니다.'));
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        setState(
                          () {
                            _exchangePosts = FirebaseHelper
                                .queryExchangePosts(); // 새로고침 시 queryExchangePosts 다시 호출
                          },
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var data = snapshot.data![index];
                                return GestureDetector(
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      data['goodsName']
                                                          as String,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontFamily:
                                                            'NotoSansKR',
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
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    Text(
                                                      '${data['needCredit']} 크레딧  (${data['currentHeadcounts']} / ${data['maxHeadcounts']})',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'NotoSansKR',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.black54),
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
                                  onTap: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ExchangeDonationInfoScreen(
                                                uid: uid,
                                                myCredit: myCredit,
                                                memberType: memberType,
                                                post: data),
                                      ),
                                    )
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("협력기업 상품",
                  style: TextStyle(
                      color: const Color.fromARGB(137, 4, 4, 4),
                      fontSize: 21,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 30),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _exchange_1,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('존재하는 교환이 없습니다.'));
                } else {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        setState(
                          () {
                            _exchangePosts = FirebaseHelper
                                .queryExchangePosts(); // 새로고침 시 queryExchangePosts 다시 호출
                          },
                        );
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var data = snapshot.data![index];
                                return GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Card(
                                      color: Colors.white,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(data['goodsImgUrl']),
                                          radius: 30,
                                        ),
                                        title: Text(
                                          data['goodsName'],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(data['inc'],
                                                style: TextStyle(
                                                    color: Colors.black54)),
                                            Text(
                                              data['supportReason'],
                                              style: TextStyle(
                                                  color: Colors.black54),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        trailing: Column(
                                          children: [
                                            Text(
                                              '${data['needCredit']} 크레딧',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              '(${data['currentHeadcounts']} / ${data['maxHeadcounts']})',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ExchangeGoodsInfoScreen(
                                                uid: uid,
                                                myCredit: myCredit,
                                                memberType: memberType,
                                                post: data),
                                      ),
                                    )
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      endDrawer: CustomEndDrawer(),
    );
  }
}
