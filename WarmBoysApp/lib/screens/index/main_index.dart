import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../main/home_screen.dart';
import '../main/matching_screen.dart';
import '../main/chatting_screen.dart';
import '../main/exchange_screen.dart';
import '../main/service_screen.dart';
import '../../providers/custom_auth_provider.dart';

class MainIndex extends StatefulWidget {
  static final GlobalKey<_MainIndexState> globalKey =
      GlobalKey<_MainIndexState>();

  MainIndex({Key? key}) : super(key: globalKey);
  @override
  _MainIndexState createState() => _MainIndexState();
}

class _MainIndexState extends State<MainIndex> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    MatchingScreen(),
    ChattingScreen(),
    ExchangeScreen(),
  ];

  void navigateToHomeScreen() {
    setState(() {
      _currentIndex = 0; // HomeScreen의 인덱스
    });
  }

  void navigateToMatchingScreen() {
    setState(() {
      _currentIndex = 1; // MatchingScreen의 인덱스
    });
  }

  void navigateToChattingScreen() {
    setState(() {
      _currentIndex = 2; // ChattingScreen의 인덱스
    });
  }

  void navigateToExchangeScreen() {
    setState(() {
      _currentIndex = 3; // ExchangeScreen의 인덱스
    });
  }

  bool _hasNewMessages = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late StreamSubscription<DocumentSnapshot> _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToNewMessages();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _subscribeToNewMessages() {
    _subscription = _firestore
        .collection('alarms')
        .doc(_currentUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _hasNewMessages = snapshot.data()?['hasNewChat'] ?? false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    final _memberType = customAuthProvider.userInfo!['memberType'];
    if (_memberType == '시니어') {
      _pages[3] = ServiceScreen();
    }
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.handshake,
              size: 30,
            ),
            label: '매칭',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(
                  Icons.chat,
                  size: 30,
                ),
                if (_hasNewMessages)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 224, 73, 81),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 6,
                        minHeight: 6,
                      ),
                    ),
                  ),
              ],
            ),
            label: '채팅',
          ),
          _memberType == '메이트'
              ? BottomNavigationBarItem(
                  icon: Icon(
                    Icons.card_giftcard,
                    size: 30,
                  ),
                  label: '교환',
                )
              : BottomNavigationBarItem(
                  icon: Icon(
                    Icons.volunteer_activism,
                    size: 30,
                  ),
                  label: '서비스',
                ),
        ],
        selectedItemColor: Color.fromARGB(255, 224, 73, 81),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
