import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:warm_boys/providers/custom_auth_provider.dart';
import 'shared_preferences_helper.dart';
import 'package:intl/intl.dart';
import '../providers/custom_auth_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class FirebaseHelper {
  static final Map<String, DateTime> stringToDate = {
    '오전 9시': DateTime(1, 1, 1, 9),
    '오전 10시': DateTime(1, 1, 1, 10),
    '오전 11시': DateTime(1, 1, 1, 11),
    '정오': DateTime(1, 1, 1, 12),
    '오후 1시': DateTime(1, 1, 1, 13),
    '오후 2시': DateTime(1, 1, 1, 14),
    '오후 3시': DateTime(1, 1, 1, 15),
    '오후 4시': DateTime(1, 1, 1, 16),
    '오후 5시': DateTime(1, 1, 1, 17),
    '오후 6시': DateTime(1, 1, 1, 18),
    '오후 7시': DateTime(1, 1, 1, 19),
    '오후 8시': DateTime(1, 1, 1, 20),
    '오후 9시': DateTime(1, 1, 1, 21),
  };

  static final Map<DateTime, String> dateToString = {
    DateTime(1, 1, 1, 9): '오전 9시',
    DateTime(1, 1, 1, 10): '오전 10시',
    DateTime(1, 1, 1, 11): '오전 11시',
    DateTime(1, 1, 1, 12): '정오',
    DateTime(1, 1, 1, 13): '오후 1시',
    DateTime(1, 1, 1, 14): '오후 2시',
    DateTime(1, 1, 1, 15): '오후 3시',
    DateTime(1, 1, 1, 16): '오후 4시',
    DateTime(1, 1, 1, 17): '오후 5시',
    DateTime(1, 1, 1, 18): '오후 6시',
    DateTime(1, 1, 1, 19): '오후 7시',
    DateTime(1, 1, 1, 20): '오후 8시',
    DateTime(1, 1, 1, 21): '오후 9시',
  };

  static String dateDifferenceToString(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}달 전';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}년 전';
    }
  }

  static int calculateCredit(DateTime startTime, DateTime endTime) {
    Duration difference = endTime.difference(startTime);

    double hours = difference.inMinutes / 60.0;

    int credit = (hours.floor()) * 5;

    return credit;
  }

  // 이메일이 등록되어 있는지 확인
  static Future<bool> checkEmail(String email) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot result = await firestore
          .collection('user')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return result.docs.isEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // '시니어' 회원 정보 저장
  static Future<void> saveSenior(
      String uid, CustomAuthProvider customAuthProvider) async {
    final prefs = await SharedPreferencesHelper.getAll();

    bool withPet = await SharedPreferencesHelper.getBool('_withPet') ?? false;
    bool withCam = await SharedPreferencesHelper.getBool('_withCam') ?? false;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String imgUrl = "";
    if (customAuthProvider.profileImage != null) {
      final ref = FirebaseStorage.instance.ref().child('프로필 사진/$uid.jpg');
      await ref.putFile(customAuthProvider.profileImage!);
      imgUrl = await ref.getDownloadURL();
    }

    final Map<String, dynamic> userData = {
      'username': prefs['_username'] ?? '',
      'email': prefs['_email'] ?? '',
      'password': prefs['_password'] ?? '',
      'memberType': prefs['_memberType'] ?? '',
      'isVerified': false,
      'age': prefs['_age'] ?? '',
      'gender': prefs['_gender'] ?? '',
      'imgUrl': imgUrl,
      'imgEmbd': prefs['_imgEmbd'],
      'phoneNum': prefs['_phoneNum'] ?? '',
      'phoneNum2': prefs['_phoneNum2'] ?? '',
      'residentNumber': prefs['_residentNumber'] ?? '',
      'city': prefs['_city'] ?? '',
      'gu': prefs['_gu'] ?? '',
      'dong': prefs['_dong'] ?? '',
      'detailedAddress': prefs['_detailedAddress'] ?? '',
      'activityType': prefs['_activityType'] ?? '',
      'symptom': prefs['_symptom'] ?? '',
      'withPet': withPet,
      'withCam': withCam,
      'dependentType': prefs['_dependentType'] ?? '',
      'walkingType': prefs['_walkingType'] ?? '',
      'symptomInfo': prefs['_symptomInfo'] ?? '',
      'petInfo': prefs['_petInfo'] ?? '',
      'addInfo': prefs['_addInfo'] ?? '',
      'rating': 0.0,
      'ratingCount': 0,
    };

    await firestore.collection('user').doc(uid).set(userData);
  }

  // '메이트' 회원 정보 저장
  static Future<void> saveMate(
      String uid, CustomAuthProvider customAuthProvider) async {
    final prefs = await SharedPreferencesHelper.getAll();

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    String imgUrl = "";
    String schoolCertImgUrl = "";
    if (customAuthProvider.profileImage != null) {
      final ref = FirebaseStorage.instance.ref().child('프로필 사진/$uid.jpg');
      await ref.putFile(customAuthProvider.profileImage!);
      imgUrl = await ref.getDownloadURL();
    }
    if (customAuthProvider.schoolCertImage != null) {
      final ref = FirebaseStorage.instance.ref().child('학생증 사진/$uid.jpg');
      await ref.putFile(customAuthProvider.schoolCertImage!);
      schoolCertImgUrl = await ref.getDownloadURL();
    }

    final Map<String, dynamic> userData = {
      'username': prefs['_username'] ?? '',
      'email': prefs['_email'] ?? '',
      'password': prefs['_password'] ?? '',
      'memberType': prefs['_memberType'] ?? '',
      'isVerified': false,
      'age': prefs['_age'] ?? '',
      'gender': prefs['_gender'] ?? '',
      'imgUrl': imgUrl,
      'imgEmbd': prefs['_imgEmbd'],
      'university': prefs['_university'] ?? '',
      'department': prefs['_department'] ?? '',
      'schoolCertImgUrl': schoolCertImgUrl,
      'phoneNum': prefs['_phoneNum'] ?? '',
      'residentNumber': prefs['_residentNumber'] ?? '',
      'city': prefs['_city'] ?? '',
      'gu': prefs['_gu'] ?? '',
      'dong': prefs['_dong'] ?? '',
      'detailedAddress': prefs['_detailedAddress'] ?? '',
      'activityType': prefs['_activityType'] ?? '',
      'dayTime': prefs['_dayTime'] ?? '',
      'residentCert': false,
      'schoolCert': false,
      'addInfo': prefs['_addInfo'] ?? '',
      'credit': 0,
      'rating': 0.0,
      'ratingCount': 0,
    };

    await firestore.collection('user').doc(uid).set(userData);
  }

  // 기간과 지역에 따라 포스트카드 쿼리(홍 화면 전용)
  static Future<List<Map<String, dynamic>>> queryPostcardsByDurLocStat(
      DateTime startTime, DateTime endTime, String dong, String sortBy) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    DateTime startOfDay =
        DateTime(startTime.year, startTime.month, startTime.day);
    DateTime endOfDay =
        DateTime(endTime.year, endTime.month, endTime.day, 23, 59, 59, 999);

    Query postsQuery;

    if (dong == '전체') {
      postsQuery = firestore
          .collection('posts')
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: ['posted', 'notMatched']);
    } else {
      postsQuery = firestore
          .collection('posts')
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('dong', isEqualTo: dong)
          .where('status', whereIn: ['posted', 'notMatched']);
    }

    QuerySnapshot postsSnapshot = await postsQuery.get();

    List<Map<String, dynamic>> results = [];

    for (var postDoc in postsSnapshot.docs) {
      var postData = postDoc.data() as Map<String, dynamic>;
      var seniorUid = postData['seniorUid'];

      DocumentSnapshot userSnapshot =
          await firestore.collection('user').doc(seniorUid).get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;

        results.add({
          'seniorUid': seniorUid,
          'seniorName': userData['username'] ?? '',
          'imgUrl': userData['imgUrl'] ?? '',
          'rating': userData['rating'] ?? 0.0,
          'ratingCount': userData['ratingCount'] ?? 0,
          'dependentType': userData['dependentType'] ?? '',
          'withPet': userData['withPet'] ?? false,
          'withCam': userData['withCam'] ?? false,
          'symptom': userData['symptom']?.cast<String>() ?? [],
          'walkingType': userData['walkingType'] ?? '',
          'petInfo': userData['petInfo'] ?? '',
          'symptomInfo': userData['symptomInfo'] ?? '',
          'postId': postDoc.id,
          'city': postData['city'] ?? '', // 시
          'gu': postData['gu'] ?? '', // 구
          'dong': postData['dong'] ?? '', // 동
          'status': postData['status'] ?? '', // posted
          'activityType': postData['activityType'] ?? '',
          'startTime': (postData['startTime'] as Timestamp).toDate(),
          'endTime': (postData['endTime'] as Timestamp).toDate(),
          'credit': postData['credit'] ?? 0,
          'addInfo': userData['addInfo'] ?? '',
        });
      }
    }

    // print('Fetched ${results.length} posts:');
    // for (var result in results) {
    //   print('--- Post ---');
    //   result.forEach((key, value) {
    //     print('$key: $value\n');
    //   });
    // }

    if (sortBy == "오름차순") {
      results.sort((a, b) => a['startTime'].compareTo(b['startTime']));
    } else if (sortBy == "내림차순") {
      results.sort((a, b) => b['startTime'].compareTo(a['startTime']));
    }

    return results;
  }

  // 내 공고 쿼리(시니어)
  static Future<List<Map<String, dynamic>>> queryMyPost(String myUid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    Query postsQuery = firestore
        .collection('posts')
        .where('seniorUid', isEqualTo: myUid)
        .where('status', whereIn: ['posted', 'notMatched']); // 조건 추가

    QuerySnapshot postsSnapshot = await postsQuery.get();

    List<Map<String, dynamic>> results = [];

    for (var postDoc in postsSnapshot.docs) {
      var postData = postDoc.data() as Map<String, dynamic>;
      results.add({
        'postId': postDoc.id,
        'status': postData['status'] ??
            '', // posted, notMatched, matched, activated, finished, failed
        'mateUid': postData['mateUid'] ?? '',
        'activityType': postData['activityType'] ?? '',
        'startTime': (postData['startTime'] as Timestamp).toDate(),
        'endTime': (postData['endTime'] as Timestamp).toDate(),
      });
    }

    results.sort((a, b) => a['startTime'].compareTo(b['startTime']));

    return results;
  }

  // 공고 화면: 내 공고 올리기(시니어)
  static Future<bool> postMyPost(Map<String, dynamic> postInfo) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    print('seniorUid: ${postInfo['seniorUid']}');
    print('city: ${postInfo['city']}');
    print('gu: ${postInfo['gu']}');
    print('dong: ${postInfo['dong']}');
    print('activityType: ${postInfo['activityType']}');
    print('startTime: ${postInfo['startTime']}');
    print('endTime: ${postInfo['endTime']}');

    final int credit =
        calculateCredit(postInfo['startTime'], postInfo['endTime']);

    try {
      await firestore.collection('posts').add({
        'seniorUid': postInfo['seniorUid'],
        'city': postInfo['city'],
        'gu': postInfo['gu'],
        'dong': postInfo['dong'],
        'activityType': postInfo['activityType'],
        'startTime': Timestamp.fromDate(postInfo['startTime']),
        'endTime': Timestamp.fromDate(postInfo['endTime']),
        'credit': credit,
        'status': 'posted',
        'startImgUrl': null,
        'startReport': null,
        'endImgUrl': null,
        'endReport': null,
        'ratingByMate': null,
        'reviewByMate': null,
        'ratingBySenior': null,
        'reviewBySenior': null,
        'volunteer1365': 'notApplied',
        'volunteerUniv': 'notApplied',
      });
      print('Post added successfully');
      return true; // 성공 시 true 반환
    } catch (e) {
      print('Failed to add post: $e');
      return false; // 에러 발생 시 false 반환
    }
  }

  static Future<bool> deleteMyPost(String postId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('posts').doc(postId).delete();
      print("Post with ID: $postId has been successfully deleted.");
      return true; // 성공 시 true 반환
    } catch (e) {
      print("Error deleting post: $e");
      return false; // 에러 발생 시 false 반환
    }
  }

  // 지원 가능 여부 확인 (메이트)
  static Future<String> checkApply(String postId, String myUid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      // 'posts' 컬렉션 내의 doc id가 postId와 일치하는 문서를 찾음
      DocumentSnapshot postSnapshot =
          await firestore.collection('posts').doc(postId).get();

      if (!postSnapshot.exists) {
        // postId에 해당하는 문서가 존재하지 않으면 true를 반환
        return 'postNotExists';
      }

      // 'mates' 서브 컬렉션을 체크
      CollectionReference matesCollection =
          firestore.collection('posts').doc(postId).collection('mates');
      QuerySnapshot matesSnapshot = await matesCollection.get();

      if (matesSnapshot.docs.isEmpty) {
        // 'mates' 서브 컬렉션이 존재하지 않으면 true를 반환
        return 'canApply';
      }

      // 'mates' 서브 컬렉션 내의 모든 문서를 검사
      for (var mateDoc in matesSnapshot.docs) {
        var mateData = mateDoc.data() as Map<String, dynamic>;
        if (mateData['mateUid'] == myUid) {
          // 'mateUid' 필드가 myUid와 동일한 문서가 존재하면 false를 반환
          return 'alreadyApplied';
        }
      }

      // 'mateUid' 필드가 myUid와 동일한 문서가 존재하지 않으면 true를 반환
      return 'canApply';
    } catch (e) {
      print("Error in checkApply: $e");
      return 'error'; // 에러 발생 시 false 반환
    }
  }

  // 지원하기 (메이트)
  static Future<bool> applyMatching(String postId, String myUid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference postRef = firestore.collection('posts').doc(postId);

    try {
      DocumentSnapshot postSnapshot = await postRef.get();

      if (!postSnapshot.exists) {
        print('공고가 존재하지 않습니다.');
        return false;
      }

      var postData = postSnapshot.data() as Map<String, dynamic>;
      String status = postData['status'];
      print("-------applyInfo--------");
      print("postId: ${postId}");
      print("myUid: ${myUid}");
      print("status: ${status}");

      if (status == 'posted') {
        await postRef.update({'status': 'notMatched'});

        CollectionReference matesRef = postRef.collection('mates');
        await matesRef.add({
          'mateUid': myUid,
          'applyTime': Timestamp.now(),
        });
        print("신청이 완료되었습니다.");
        return true;
      } else if (status == 'notMatched') {
        CollectionReference matesRef = postRef.collection('mates');
        await matesRef.add({
          'mateUid': myUid,
          'applyTime': Timestamp.now(),
        });
        print("신청이 완료되었습니다.");
        return true;
      } else {
        print("신청할 수 없습니다.");
        return false;
      }
    } catch (e) {
      print('Error applying for matching: $e');
      return false;
    }
  }

  // 지원 취소 (메이트)
  static Future<bool> cancelApply(String postId, String myUid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      // 'posts' 컬렉션 내의 doc id가 postId와 일치하는 문서를 찾음
      DocumentSnapshot postSnapshot =
          await firestore.collection('posts').doc(postId).get();

      if (!postSnapshot.exists) {
        // postId에 해당하는 문서가 존재하지 않으면 false 반환
        return false;
      }

      // 'mates' 서브 컬렉션 내의 mateUid가 myUid와 동일한 문서를 찾음
      QuerySnapshot matesSnapshot = await firestore
          .collection('posts')
          .doc(postId)
          .collection('mates')
          .where('mateUid', isEqualTo: myUid)
          .get();

      if (matesSnapshot.docs.isEmpty) {
        // mateUid가 myUid와 동일한 문서가 존재하지 않으면 false 반환
        return false;
      }

      // mateUid가 myUid와 동일한 문서를 삭제
      for (var mateDoc in matesSnapshot.docs) {
        await mateDoc.reference.delete();
      }

      // 'mates' 서브 컬렉션 내의 문서가 남아있는지 확인
      QuerySnapshot remainingMatesSnapshot = await firestore
          .collection('posts')
          .doc(postId)
          .collection('mates')
          .get();

      if (remainingMatesSnapshot.docs.isEmpty) {
        // mates 서브 컬렉션 내의 문서가 남아있지 않으면 'status' 필드를 'posted'로 변경
        await firestore
            .collection('posts')
            .doc(postId)
            .update({'status': 'posted'});
      }

      print("삭제에 성공했습니다. [postId: $postId / myUid: $myUid]");
      return true; // 성공 시 true 반환
    } catch (e) {
      print("Error in cancelApply: $e");
      return false; // 에러 발생 시 false 반환
    }
  }

  // 매칭화면의 '매칭 전' 텝 정보 쿼리 (메이트)
  static Future<List<Map<String, dynamic>>> queryNotMatchedByMate(
      String myUid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 1. status가 'notMatched'인 posts를 검색
    QuerySnapshot postsSnapshot = await firestore
        .collection('posts')
        .where('status', isEqualTo: 'notMatched')
        .get();

    List<Map<String, dynamic>> results = [];

    // Step 2: posts 순회
    for (var postDoc in postsSnapshot.docs) {
      var postData = postDoc.data() as Map<String, dynamic>;
      String postId = postDoc.id;

      // Step 3: Check mates sub-collection
      QuerySnapshot matesSnapshot = await firestore
          .collection('posts')
          .doc(postId)
          .collection('mates')
          .where('mateUid', isEqualTo: myUid)
          .get();

      // If there are matching mates documents
      if (matesSnapshot.docs.isNotEmpty) {
        var mateData = matesSnapshot.docs.first.data() as Map<String, dynamic>;

        // Get senior data
        DocumentSnapshot seniorSnapshot =
            await firestore.collection('user').doc(postData['seniorUid']).get();

        if (seniorSnapshot.exists) {
          var seniorData = seniorSnapshot.data() as Map<String, dynamic>;

          // Compile the result
          results.add({
            'imgUrl': seniorData['imgUrl'] ?? '',
            'username': seniorData['username'] ?? '',
            'rating': seniorData['rating'] ?? 0.0,
            'ratingCount': seniorData['ratingCount'] ?? 0,
            'dependentType': seniorData['dependentType'] ?? '',
            'withPet': seniorData['withPet'] ?? false,
            'withCam': seniorData['withCam'] ?? false,
            'petInfo': seniorData['petInfo'] ?? '',
            'symptom': List<String>.from(seniorData['symptom'] ?? []),
            'symptomInfo': seniorData['symptomInfo'] ?? '',
            'walkingType': seniorData['walkingType'] ?? '',
            'addInfo': seniorData['addInfo'] ?? '',
            'uid': postData['seniorUid'] ?? '',
            'postId': postId,
            'city': postData['city'] ?? '',
            'gu': postData['gu'] ?? '',
            'dong': postData['dong'] ?? '',
            'date':
                '${DateFormat('yy.M.d').format((postData['startTime'] as Timestamp).toDate())}' ??
                    '',
            'startTime': (postData['startTime'] as Timestamp).toDate(),
            'endTime': (postData['endTime'] as Timestamp).toDate(),
            'activityType': postData['activityType'] ?? '',
            'applyTime': (mateData['applyTime'] as Timestamp).toDate(),
            'applyTimeText': dateDifferenceToString(
                (mateData['applyTime'] as Timestamp).toDate()),
            'credit': postData['credit'] ?? 0,
          });
        }
      }
    }
    results.sort((a, b) => a['startTime'].compareTo(b['startTime']));

    return results;
  }

  // 매칭화면의 '매칭 전' 텝 정보 쿼리 (시니어)
  static Future<List<Map<String, dynamic>>> queryNotMatchedBySenior(
      String myUid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> results = [];

    try {
      // 'posts' 컬렉션에서 'seniorUid'가 myUid와 같고 'status'가 'notMatched'인 문서를 가져옴
      QuerySnapshot postsSnapshot = await firestore
          .collection('posts')
          .where('seniorUid', isEqualTo: myUid)
          .where('status', isEqualTo: 'notMatched')
          .get();

      for (var postDoc in postsSnapshot.docs) {
        var postData = postDoc.data() as Map<String, dynamic>;

        // 'mates' 서브 컬렉션을 순회
        QuerySnapshot matesSnapshot = await firestore
            .collection('posts')
            .doc(postDoc.id)
            .collection('mates')
            .get();

        for (var mateDoc in matesSnapshot.docs) {
          var mateData = mateDoc.data() as Map<String, dynamic>;
          String mateUid = mateData['mateUid'];

          // 'user' 컬렉션에서 mateUid와 같은 문서를 가져옴
          DocumentSnapshot userSnapshot =
              await firestore.collection('user').doc(mateUid).get();

          if (userSnapshot.exists) {
            var userData = userSnapshot.data() as Map<String, dynamic>;

            results.add({
              'uid': mateUid ?? '',
              'username': userData['username'] ?? '',
              'imgUrl': userData['imgUrl'] ?? '',
              'rating': userData['rating'] ?? 0.0,
              'ratingCount': userData['ratingCount'] ?? 0,
              'city': userData['city'] ?? '',
              'gu': userData['gu'] ?? '',
              'dong': userData['dong'] ?? '',
              'age': userData['age'] ?? '',
              'gender': userData['gender'] ?? '',
              'mateActivityType': userData['activityType'] ?? '',
              'dayTime': userData['dayTime'] ?? '',
              'addInfo': userData['addInfo'] ?? '',
              'residentCert': userData['residentCert'] ?? false,
              'schoolCert': userData['schoolCert'] ?? false,
              'applyTime': (mateData['applyTime'] as Timestamp).toDate(),
              'applyTimeText': dateDifferenceToString(
                  (mateData['applyTime'] as Timestamp).toDate()),
              'postId': postDoc.id,
              'date':
                  '${DateFormat('yy.M.d').format((postData['startTime'] as Timestamp).toDate())}',
              'startTime': (postData['startTime'] as Timestamp).toDate(),
              'endTime': (postData['endTime'] as Timestamp).toDate(),
              'activityType': postData['activityType'] ?? '',
            });
          }
        }
      }
    } catch (e) {
      print("Error in queryNotMatchedBySenior: $e");
    }

    results.sort((a, b) => b['applyTime'].compareTo(a['applyTime']));

    return results;
  }

  // 매칭화면의 '매칭 후' 텝 정보 쿼리 (메이트)
  static Future<List<Map<String, dynamic>>> queryMatchedByMate(
      String myUid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 1. status가 'matched', 'activated', 'finished', 'failed'인 posts를 검색
    QuerySnapshot postsSnapshot =
        await firestore.collection('posts').where('status', whereIn: [
      'matched',
      'activated',
      'failed',
    ]).get();

    List<Map<String, dynamic>> results = [];

    // Step 2: posts 순회
    for (var postDoc in postsSnapshot.docs) {
      var postData = postDoc.data() as Map<String, dynamic>;
      String postId = postDoc.id;

      // Step 3: Check mates sub-collection
      QuerySnapshot matesSnapshot = await firestore
          .collection('posts')
          .doc(postId)
          .collection('mates')
          .where('mateUid', isEqualTo: myUid)
          .get();

      // If there are matching mates documents
      if (matesSnapshot.docs.isNotEmpty) {
        var mateData = matesSnapshot.docs.first.data() as Map<String, dynamic>;

        // Get senior data
        DocumentSnapshot seniorSnapshot =
            await firestore.collection('user').doc(postData['seniorUid']).get();

        if (seniorSnapshot.exists) {
          var seniorData = seniorSnapshot.data() as Map<String, dynamic>;

          // Compile the result
          results.add({
            'imgUrl': seniorData['imgUrl'] ?? '',
            'username': seniorData['username'] ?? '',
            'rating': seniorData['rating'] ?? 0.0,
            'ratingCount': seniorData['ratingCount'] ?? 0,
            'dependentType': seniorData['dependentType'] ?? '',
            'withPet': seniorData['withPet'] ?? false,
            'withCam': seniorData['withCam'] ?? false,
            'petInfo': seniorData['petInfo'] ?? '',
            'symptom': List<String>.from(seniorData['symptom'] ?? []),
            'symptomInfo': seniorData['symptomInfo'] ?? '',
            'walkingType': seniorData['walkingType'] ?? '',
            'addInfo': seniorData['addInfo'] ?? '',
            'phoneNum2': seniorData['phoneNum2'] ?? '',
            'uid': postData['seniorUid'] ?? '',
            'postId': postId,
            'city': postData['city'] ?? '',
            'gu': postData['gu'] ?? '',
            'dong': postData['dong'] ?? '',
            'detailedAddress': seniorData['detailedAddress'] ?? '',
            'date':
                '${DateFormat('yy.MM.dd').format((postData['startTime'] as Timestamp).toDate())}' ??
                    '',
            'startTime': (postData['startTime'] as Timestamp).toDate(),
            'endTime': (postData['endTime'] as Timestamp).toDate(),
            'activityType': postData['activityType'] ?? '',
            'acceptTime': (mateData['acceptTime'] as Timestamp).toDate(),
            'acceptTimeText': dateDifferenceToString(
                (mateData['acceptTime'] as Timestamp).toDate()),
            'status': postData['status'],
            'credit': postData['credit'],
          });
        }
      }
    }
    results.sort((a, b) => a['acceptTime'].compareTo(b['acceptTime']));

    return results;
  }

  // 매칭화면의 '매칭 후' 텝 정보 쿼리 (시니어)
  static Future<List<Map<String, dynamic>>> queryMatchedBySenior(
      String myUid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> results = [];

    try {
      // 'posts' 컬렉션에서 'seniorUid'가 myUid와 같고 'status'가 'matched', 'activated', 'finished', 'failed'인 문서를 가져옴
      QuerySnapshot postsSnapshot = await firestore
          .collection('posts')
          .where('seniorUid', isEqualTo: myUid)
          .where('status', whereIn: [
        'matched',
        'activated',
        'notReviewedBySenior',
        'failed',
      ]).get();

      for (var postDoc in postsSnapshot.docs) {
        var postData = postDoc.data() as Map<String, dynamic>;

        // 'mates' 서브 컬렉션을 순회
        QuerySnapshot matesSnapshot = await firestore
            .collection('posts')
            .doc(postDoc.id)
            .collection('mates')
            .get();

        for (var mateDoc in matesSnapshot.docs) {
          var mateData = mateDoc.data() as Map<String, dynamic>;
          String mateUid = mateData['mateUid'];

          // 'user' 컬렉션에서 mateUid와 같은 문서를 가져옴
          DocumentSnapshot userSnapshot =
              await firestore.collection('user').doc(mateUid).get();

          if (userSnapshot.exists) {
            var userData = userSnapshot.data() as Map<String, dynamic>;

            results.add({
              'uid': mateUid ?? '',
              'username': userData['username'] ?? '',
              'imgUrl': userData['imgUrl'] ?? '',
              'rating': userData['rating'] ?? 0.0,
              'ratingCount': userData['ratingCount'] ?? 0,
              'city': userData['city'] ?? '',
              'gu': userData['gu'] ?? '',
              'dong': userData['dong'] ?? '',
              'age': userData['age'] ?? '',
              'gender': userData['gender'] ?? '',
              'mateActivityType': userData['activityType'] ?? '',
              'dayTime': userData['dayTime'] ?? '',
              'addInfo': userData['addInfo'] ?? '',
              'residentCert': userData['residentCert'] ?? false,
              'schoolCert': userData['schoolCert'] ?? false,
              'acceptTime': (mateData['acceptTime'] as Timestamp).toDate(),
              'acceptTimeText': dateDifferenceToString(
                  (mateData['acceptTime'] as Timestamp).toDate()),
              'postId': postDoc.id,
              'date':
                  '${DateFormat('yy.MM.dd').format((postData['startTime'] as Timestamp).toDate())}',
              'startTime': (postData['startTime'] as Timestamp).toDate(),
              'endTime': (postData['endTime'] as Timestamp).toDate(),
              'activityType': postData['activityType'] ?? '',
              'status': postData['status'] ?? '',
            });
          }
        }
      }
    } catch (e) {
      print("Error in queryNotMatchedBySenior: $e");
    }

    results.sort((a, b) => b['acceptTime'].compareTo(a['acceptTime']));

    return results;
  }

  // 매칭 승인 (시니어)
  static Future<void> acceptMatching(String mateUid, String postId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // 1. posts 컬렉션 내의 doc id 중 postUid와 같은 것을 찾아 가져옴
      DocumentSnapshot postSnapshot =
          await firestore.collection('posts').doc(postId).get();

      if (!postSnapshot.exists) {
        throw Exception("Post with ID $postId does not exist.");
      }

      // 2. 문서 내의 'mates' 서브 컬렉션의 문서들의 'mateUid' 필드와 mateUid 인자가 일치하는 mates 문서를 찾음
      QuerySnapshot matesSnapshot = await firestore
          .collection('posts')
          .doc(postId)
          .collection('mates')
          .where('mateUid', isEqualTo: mateUid)
          .get();

      if (matesSnapshot.docs.isEmpty) {
        throw Exception(
            "메이트 Uid $mateUid 가 해당 포스트의 mates 서브 컬렉션 내에 존재하지 않습니다.");
      }

      // 3. mateUid가 user 컬렉션 내의 문서 uid 중 존재하는지 찾음
      DocumentSnapshot userSnapshot =
          await firestore.collection('user').doc(mateUid).get();

      if (!userSnapshot.exists) {
        throw Exception("메이트 유저 $mateUid 가 존재하지 않습니다.");
      }

      // 4. WriteBatch를 사용하여 일괄 작업 수행
      WriteBatch batch = firestore.batch();

      // mateUid와 일치하는 mates 문서를 찾아 acceptTime 추가
      var targetMateDocRef;
      for (var doc in matesSnapshot.docs) {
        if (doc['mateUid'] == mateUid) {
          targetMateDocRef = doc.reference;
          batch.update(targetMateDocRef,
              {'acceptTime': Timestamp.fromDate(DateTime.now())});
        }
      }

      // mateUid와 일치하지 않는 나머지 mates 문서 삭제
      QuerySnapshot allMatesSnapshot = await firestore
          .collection('posts')
          .doc(postId)
          .collection('mates')
          .get();

      for (var doc in allMatesSnapshot.docs) {
        if (doc.reference != targetMateDocRef) {
          batch.delete(doc.reference);
        }
      }

      // 5. posts 문서의 'status' 필드를 'matched'로 변경
      batch.update(postSnapshot.reference, {'status': 'matched'});

      await batch.commit();

      print("매칭 수락 성공. [메이트 Uid: $mateUid , 포스트 Id: $postId]");
    } catch (e) {
      print("Error in acceptMatching: $e");
      throw e;
    }
  }

  // 채팅 목록 가져오기
  static Stream<QuerySnapshot> getChatsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots();
  }

  // 채팅방 메시지 확인 여부 업데이트
  static Future<void> markMessageAsRead(String chatId, String userId) async {
    final chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    final List<dynamic> lastMessageReadBy = chatDoc['lastMessageReadBy'] ?? [];

    if (!lastMessageReadBy.contains(userId)) {
      lastMessageReadBy.add(userId);
      await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'lastMessageReadBy': lastMessageReadBy,
      });
    }
  }

  static Future<String?> getChatRoomWithUserId(String otherUserId) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // 현재 사용자 ID
      String currentUserId = _auth.currentUser!.uid;

      // 현재 사용자와 상대방 사용자가 포함된 채팅방 검색
      QuerySnapshot chatSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      // 채팅방에서 상대방 사용자가 포함된 채팅방이 있는지 확인
      for (var doc in chatSnapshot.docs) {
        List<dynamic> participants = doc['participants'];

        if (participants.contains(otherUserId)) {
          // 상대방 사용자와 함께 있는 채팅방을 찾으면 해당 채팅방 ID 반환
          return doc.id;
        }
      }

      // 상대방 사용자와 함께 있는 채팅방이 없으면 null 반환
      return null;
    } catch (e) {
      print('Error checking chat room: $e');
      return null;
    }
  }

//uid를 통한 채팅방 생성
  static Future<String?> CreateChatRoomWithUserId(String otherUserId) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      String currentUserId = _auth.currentUser!.uid;

      QuerySnapshot chatSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      // 채팅방에서 상대방 사용자가 포함된 채팅방이 있는지 확인
      for (var doc in chatSnapshot.docs) {
        List<dynamic> participants = doc['participants'];

        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }

      // 상대방 사용자와 함께 있는 채팅방이 없으면 새 채팅방 생성
      DocumentReference chatDocRef = await _firestore.collection('chats').add({
        'participants': [currentUserId, otherUserId],
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
        'lastMessageSender': currentUserId,
        'lastMessageReadBy': [],
      });

      return chatDocRef.id;
    } catch (e) {
      print('Error creating chat: $e');
      return null;
    }
  }

//이메일을 통한 채팅방 생성
  static Future<String?> createChatWithEmail(String email) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // 상대방 사용자 정보를 이메일로 찾기
      QuerySnapshot userSnapshot = await _firestore
          .collection('user')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        return null; // 상대방 사용자를 찾을 수 없음
      }

      String otherUserId = userSnapshot.docs.first.id;

      // 현재 사용자 ID
      String currentUserId = _auth.currentUser!.uid;

      // 채팅방 생성
      DocumentReference chatDocRef = await _firestore.collection('chats').add({
        'participants': [currentUserId, otherUserId],
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
        'lastMessageSender': currentUserId,
        'lastMessageReadBy': [],
      });

      return chatDocRef.id;
    } catch (e) {
      print('Error creating chat: $e');
      return null;
    }
  }

  // 채팅보내기
  static Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
  }) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': text,
      'createdAt': Timestamp.now(),
      'senderId': senderId,
    });
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': Timestamp.now(),
      'lastMessageSender': senderId,
      'lastMessageReadBy': [senderId], // 메시지를 보낸 사용자로 초기화
    });
  }

  // 채팅방 날짜 포맷
  static String formatDate(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String formattedDate = dateFormat.format(dateTime);
    String todayFormatted = dateFormat.format(now);
    String yesterdayFormatted =
        dateFormat.format(now.subtract(Duration(days: 1)));

    if (formattedDate == todayFormatted) {
      return '오늘';
    } else if (formattedDate == yesterdayFormatted) {
      return '어제';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE', 'ko_KR').format(dateTime);
    } else if (now.difference(dateTime).inDays < 14) {
      return '지난주 ' + DateFormat('EEEE', 'ko_KR').format(dateTime);
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  // 채팅방 시간 포맷
  static String formatTime(DateTime dateTime) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  //알림 기능 메소드
  static void listenForStatusChanges(String userId) {
    FirebaseFirestore.instance
        .collection('posts')
        .where('seniorUid', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.modified) {
          var postData = docChange.doc.data() as Map<String, dynamic>;
          _saveAlarm(userId, postData['status'], postData['activityType'],
              postData['startTime']);
        }
      }
    });

    FirebaseFirestore.instance
        .collection('posts')
        .where('mates', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.modified) {
          var postData = docChange.doc.data() as Map<String, dynamic>;
          _saveAlarm(userId, postData['status'], postData['activityType'],
              postData['startTime']);
        }
      }
    });
  }

  static Future<void> _saveAlarm(String userId, String status,
      String activityType, Timestamp startTime) async {
    await FirebaseFirestore.instance
        .collection('alarms')
        .doc(userId)
        .collection('userAlarms')
        .add({
      'status': status,
      'activityType': activityType,
      'startTime': startTime,
      'timestamp': Timestamp.now(),
    });
  }

  static Future<List<Map<String, String>>> getAllEmbd() async {
    List<Map<String, String>> embdList = [];

    try {
      // Firestore 인스턴스 가져오기
      final firestore = FirebaseFirestore.instance;

      // 'user' 컬렉션의 모든 문서를 가져옴
      QuerySnapshot querySnapshot = await firestore.collection('user').get();

      // 각 문서를 순회하면서 uid와 imgEmbd를 Map으로 저장
      for (var doc in querySnapshot.docs) {
        // doc.data()는 Map<String, dynamic>을 반환하므로 타입 캐스팅 필요
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        String uid = doc.id; // 문서의 id를 uid로 사용
        String imgEmbd = data['imgEmbd'] as String; // imgEmbd 필드를 가져옴

        // uid와 imgEmbd를 매핑한 Map<String, String>을 리스트에 추가
        embdList.add({
          'uid': uid,
          'username': data['username'],
          'memberType': data['memberType'],
          'imgEmbd': imgEmbd
        });
      }
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }

    return embdList;
  }

  static Future<bool> submitStartReport({
    required String postId,
    required File startImg,
    required String startReport,
  }) async {
    try {
      print("postId: ${postId}, startReport: ${startReport}");
      // 1. Firebase Storage에 이미지를 업로드하고 URL 가져오기
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = '${postId}_startImg.jpg';
      Reference storageRef = storage.ref().child('보고서 사진').child(fileName);

      UploadTask uploadTask = storageRef.putFile(startImg);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 2. Firestore에서 postId에 해당하는 문서 업데이트
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference postDocRef = firestore.collection('posts').doc(postId);

      await postDocRef.update({
        'startImgUrl': downloadUrl, // 'startImgUrl' 필드 업데이트
        'startReport': startReport, // 'startReport' 필드 업데이트
        'status': 'activated', // 'status' 필드를 'activated'로 업데이트
      });

      print('보고서가 성공적으로 제출되었습니다.');
      return true;
    } catch (e) {
      print('보고서 제출 중 오류 발생: $e');
      return false;
    }
  }

  static Future<bool> submitEndReport({
    required String postId,
    required File endImg,
    required String endReport,
    required int ratingByMate,
    required String reviewByMate,
  }) async {
    try {
      print("postId: ${postId}, startReport: ${endReport}");
      // 1. Firebase Storage에 이미지를 업로드하고 URL 가져오기
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = '${postId}_endImg.jpg';
      Reference storageRef = storage.ref().child('보고서 사진').child(fileName);

      UploadTask uploadTask = storageRef.putFile(endImg);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 2. Firestore에서 postId에 해당하는 문서 업데이트
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference postDocRef = firestore.collection('posts').doc(postId);

      await postDocRef.update({
        'endImgUrl': downloadUrl, // 'endImgUrl' 필드 업데이트
        'endReport': endReport, // 'endReport' 필드 업데이트
        'ratingByMate': ratingByMate,
        'reviewByMate': reviewByMate,
        'status':
            'notReviewedBySenior', // 'status' 필드를 'notReviewedBySenior'로 업데이트
      });

      print('보고서가 성공적으로 제출되었습니다.');
      return true;
    } catch (e) {
      print('보고서 제출 중 오류 발생: $e');
      return false;
    }
  }

  static Future<void> getCredit(String postId, String mateUid) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // posts 컬렉션에서 postId와 일치하는 문서 찾기
      DocumentSnapshot postDoc =
          await firestore.collection('posts').doc(postId).get();

      if (postDoc.exists) {
        // posts 문서의 credit 값 가져오기
        int postCredit = postDoc.get('credit');

        // user 컬렉션에서 mateUid와 일치하는 문서 찾기
        DocumentReference userDocRef =
            firestore.collection('user').doc(mateUid);
        DocumentSnapshot userDoc = await userDocRef.get();

        if (userDoc.exists) {
          // users 문서의 현재 credit 값 가져오기
          int userCredit = userDoc.get('credit');

          // posts의 credit 값을 users의 credit 값에 더하여 업데이트
          await userDocRef.update({
            'credit': userCredit + postCredit,
          });
        } else {
          print('User document not found.');
        }
      } else {
        print('Post document not found.');
      }
    } catch (e) {
      print('Error updating credit: $e');
    }
  }

  static Future<bool> submitRatingBySenior(
      String postId, int ratingBySenior, String reviewBySenior) async {
    try {
      // Firestore 인스턴스 생성
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 해당 문서 참조
      DocumentReference postRef = firestore.collection('posts').doc(postId);

      // 문서 업데이트
      await postRef.update({
        'ratingBySenior': ratingBySenior,
        'reviewBySenior': reviewBySenior,
        'status': 'finished',
      });

      return true; // 성공 시 true 반환
    } catch (e) {
      print('Error submitting review by senior: $e');
      return false; // 실패 시 false 반환
    }
  }

// 리뷰 쿼리
  static Future<List<Map<String, dynamic>>> queryReview(
      String uid, String memberType) async {
    List<Map<String, dynamic>> reviews = [];

    if (memberType == '메이트') {
      // 'status'가 'finished'인 문서들 가져오기
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('status', isEqualTo: 'finished')
          .get();

      int index = 1; // 익명 번호를 위한 인덱스

      for (var doc in postsSnapshot.docs) {
        // 'mates' 서브 컬렉션 내의 첫 번째 문서 가져오기
        QuerySnapshot matesSnapshot =
            await doc.reference.collection('mates').limit(1).get();

        if (matesSnapshot.docs.isNotEmpty) {
          DocumentSnapshot mateDoc = matesSnapshot.docs.first;

          if (mateDoc['mateUid'] == uid) {
            // 조건에 맞는 데이터를 Map으로 저장
            reviews.add({
              'username': '익명의 시니어 $index',
              'activityType': doc['activityType'],
              'ratingBySenior': doc['ratingBySenior'],
              'reviewBySenior': doc['reviewBySenior'],
            });
            index++; // 다음 익명 번호로 증가
          }
        }
      }
    } else if (memberType == '시니어') {
      // 'status'가 'notReviewedBySenior' 또는 'finished'인 문서들 가져오기
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('status', whereIn: ['notReviewedBySenior', 'finished'])
          .where('seniorUid', isEqualTo: uid)
          .get();

      int index = 1; // 익명 번호를 위한 인덱스

      for (var doc in postsSnapshot.docs) {
        // 조건에 맞는 데이터를 Map으로 저장
        reviews.add({
          'username': '익명의 메이트 $index',
          'activityType': doc['activityType'],
          'ratingByMate': doc['ratingByMate'],
          'reviewByMate': doc['reviewByMate'],
        });
        index++; // 다음 익명 번호로 증가
      }
    }

    return reviews;
  }

  static Future<List<Map<String, dynamic>>> queryActivities(
      String uid, String memberType) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> results = [];

    try {
      // posts 컬렉션에서 status가 notReviewedBySenior 또는 finished인 문서들을 가져옴
      QuerySnapshot postsSnapshot = await _firestore
          .collection('posts')
          .where('status', whereIn: ['notReviewedBySenior', 'finished']).get();

      for (var postDoc in postsSnapshot.docs) {
        final postData = postDoc.data() as Map<String, dynamic>;

        // 시니어의 경우
        if (memberType == '시니어') {
          if (postData['seniorUid'] == uid) {
            // mates 서브 컬렉션에서 첫 번째 문서 가져오기
            final matesSnapshot =
                await postDoc.reference.collection('mates').limit(1).get();

            if (matesSnapshot.docs.isNotEmpty) {
              DocumentSnapshot matesDoc = matesSnapshot.docs.first;
              final mateUid = matesDoc['mateUid'];

              // mateUid로 user 컬렉션에서 해당 유저의 정보를 가져오기
              final mateSnapshot =
                  await _firestore.collection('user').doc(mateUid).get();

              // 기본 유저 정보
              Map<String, dynamic> mateData = {
                'mateUid': null,
                'imgUrl': null,
                'username': null,
                'city': null,
                'gu': null,
                'dong': null,
                'rating': null,
                'ratingCount': null,
              };

              if (mateSnapshot.exists) {
                DocumentSnapshot mateDoc = mateSnapshot;
                mateData = {
                  'uid': mateUid,
                  'imgUrl': mateDoc['imgUrl'],
                  'username': mateDoc['username'],
                  'city': mateDoc['city'],
                  'gu': mateDoc['gu'],
                  'dong': mateDoc['dong'],
                  'rating': mateDoc['rating'],
                  'ratingCount': mateDoc['ratingCount'],
                };
              }
              DateTime startTimeTemp = DateTime(1, 1, 1,
                  ((postData['startTime'] as Timestamp).toDate()).hour);
              DateTime endTimeTemp = DateTime(
                  1, 1, 1, ((postData['endTime'] as Timestamp).toDate()).hour);

              // posts 문서의 정보
              mateData.addAll({
                'timeDiff': dateDifferenceToString(
                    (postData['endTime'] as Timestamp).toDate()),
                'date': DateFormat('yy.MM.dd')
                    .format((postData['startTime'] as Timestamp).toDate()),
                'startTime': dateToString[startTimeTemp],
                'endTime': dateToString[endTimeTemp],
                'activityCity': postData['city'],
                'activityGu': postData['gu'],
                'activityDong': postData['dong'],
                'activityType': postData['activityType'],
                'startImgUrl': postData['startImgUrl'],
                'endImgUrl': postData['endImgUrl'],
                'startReport': postData['startReport'],
                'endReport': postData['endReport'],
                'credit': postData['credit'],
                'sort': (postData['endTime'] as Timestamp).toDate(),
              });

              results.add(mateData);
            }
          }
        } else if (memberType == '메이트') {
          // 메이트의 경우
          final matesSnapshot =
              await postDoc.reference.collection('mates').limit(1).get();

          if (matesSnapshot.docs.isNotEmpty) {
            DocumentSnapshot matesDoc = matesSnapshot.docs.first;
            final mateUid = matesDoc['mateUid'];

            if (mateUid == uid) {
              final seniorUid = postData['seniorUid'];

              // seniorUid로 user 컬렉션에서 해당 유저의 정보를 가져오기
              final seniorSnapshot =
                  await _firestore.collection('user').doc(seniorUid).get();

              // 기본 시니어 정보
              Map<String, dynamic> seniorData = {
                'uid': seniorUid,
                'imgUrl': null,
                'username': null,
                'city': null,
                'gu': null,
                'dong': null,
                'rating': null,
                'ratingCount': null,
              };

              if (seniorSnapshot.exists) {
                DocumentSnapshot seniorDoc = seniorSnapshot;
                seniorData = {
                  'uid': seniorUid,
                  'imgUrl': seniorDoc['imgUrl'],
                  'username': seniorDoc['username'],
                  'city': seniorDoc['city'],
                  'gu': seniorDoc['gu'],
                  'dong': seniorDoc['dong'],
                  'rating': seniorDoc['rating'],
                  'ratingCount': seniorDoc['ratingCount'],
                };
              }

              DateTime startTimeTemp = DateTime(1, 1, 1,
                  ((postData['startTime'] as Timestamp).toDate()).hour);
              DateTime endTimeTemp = DateTime(
                  1, 1, 1, ((postData['endTime'] as Timestamp).toDate()).hour);

              int hourDiff =
                  ((postData['endTime'] as Timestamp).toDate()).hour -
                      ((postData['startTime'] as Timestamp).toDate()).hour;

              // posts 문서의 정보
              seniorData.addAll({
                'postId': postDoc.id,
                'status': postData['status'],
                'timeDiff': dateDifferenceToString(
                    (postData['endTime'] as Timestamp).toDate()),
                'date': DateFormat('yy.MM.dd')
                    .format((postData['startTime'] as Timestamp).toDate()),
                'startTime': dateToString[startTimeTemp],
                'endTime': dateToString[endTimeTemp],
                'hourDiff': hourDiff,
                'activityCity': postData['city'],
                'activityGu': postData['gu'],
                'activityDong': postData['dong'],
                'activityType': postData['activityType'],
                'startImgUrl': postData['startImgUrl'],
                'endImgUrl': postData['endImgUrl'],
                'startReport': postData['startReport'],
                'endReport': postData['endReport'],
                'credit': postData['credit'],
                'sort': (postData['endTime'] as Timestamp).toDate(),
                'volunteer1365': postData['volunteer1365'],
                'volunteerUniv': postData['volunteerUniv'],
              });

              results.add(seniorData);
            }
          }
        }
      }
    } catch (e) {
      print('Error querying activities: $e');
    }
    results.sort((a, b) => b['sort'].compareTo(a['sort']));

    return results;
  }

  static Future<Map<String, List<Map<String, dynamic>>>>
      queryExchangePosts() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    Map<String, List<Map<String, dynamic>>> results = {};

    try {
      QuerySnapshot exchangeSnapshot =
          await _firestore.collection('exchanges').get();

      for (var doc in exchangeSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        String category = data['category'] as String;

        Map<String, dynamic> exchangeData = {
          'docId': doc.id,
          'goodsName': data['goodsName'] as String,
          'goodsImgUrl': data['goodsImgUrl'] as String ?? '',
          'maxHeadcounts': data['maxHeadcounts'] as int,
          'currentHeadcounts': data['currentHeadcounts'] as int,
          'needCredit': data['needCredit'] as int,
          'imgUrl': data['imgUrl'] as String,
          'incIntroduction': data['incIntroduction'] as String,
          'inc': data['inc'] as String,
          'incUrl': data['incUrl'] as String,
          'supportReason': data['supportReason'] as String,
        };
        if (!results.containsKey(category)) {
          results[category] = [];
        }

        results[category]!.add(exchangeData);
      }
    } catch (e) {
      print('Error querying exchange posts: $e');
    }
    return results;
  }

  static Future<Map<String, List<Map<String, dynamic>>>>
      queryServicePosts() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    Map<String, List<Map<String, dynamic>>> results = {};

    try {
      QuerySnapshot serviceSnapshot =
          await _firestore.collection('services').get();

      for (var doc in serviceSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        String category = data['category'] as String;

        Map<String, dynamic> serviceData = {
          'docId': doc.id,
          'content': data['content'] as String,
          'duration': data['duration'] as String,
          'imgUrl': data['imgUrl'] as String,
          'inc': data['inc'] as String,
          'location': data['location'] as String,
          'name': data['name'] as String,
          'note': data['note'] as String,
          'target': data['target'] as String,
          'tel': data['tel'] as String,
          'url': data['url'] as String,
        };

        if (!results.containsKey(category)) {
          results[category] = [];
        }

        results[category]!.add(serviceData);
      }
    } catch (e) {
      print('Error querying service posts: $e');
    }

    return results;
  }

  static Future<bool> applyExchange(
      String uid, int myCredit, String exchangeId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // 'exchanges' 컬렉션에서 doc id가 exchangeId와 같은 문서를 찾는다.
      DocumentReference exchangeRef =
          _firestore.collection('exchanges').doc(exchangeId);
      DocumentSnapshot exchangeDoc = await exchangeRef.get();

      if (!exchangeDoc.exists) {
        return false; // 문서가 존재하지 않으면 false 반환
      }

      Map<String, dynamic> exchangeData =
          exchangeDoc.data() as Map<String, dynamic>;

      int needCredit = exchangeData['needCredit'];
      int currentHeadcounts = exchangeData['currentHeadcounts'];
      int maxHeadcounts = exchangeData['maxHeadcounts'];

      // myCredit이 필요 크레딧보다 작거나, 현재 인원이 최대 인원과 같거나 많으면 false 반환
      if (myCredit < needCredit || currentHeadcounts >= maxHeadcounts) {
        return false;
      }

      // 'applicants' 서브 컬렉션이 있는지 확인하고 없다면 생성
      CollectionReference applicantsRef = exchangeRef.collection('applicants');
      QuerySnapshot applicantSnapshot = await applicantsRef.get();

      bool alreadyApplied = false;

      for (var applicant in applicantSnapshot.docs) {
        if (applicant['applicantUid'] == uid) {
          alreadyApplied = true;
          break;
        }
      }

      if (alreadyApplied) {
        return false; // 이미 신청한 경우 false 반환
      }

      // 신청자 수 증가
      await exchangeRef.update({'currentHeadcounts': FieldValue.increment(1)});

      // 'applicants' 서브 컬렉션에 새로운 신청자 추가
      await applicantsRef.add({
        'applicantUid': uid,
        'applyTime': Timestamp.now(),
      });

      // 'user' 컬렉션에서 uid에 해당하는 문서의 크레딧 감소
      DocumentReference userRef = _firestore.collection('user').doc(uid);
      await userRef.update({'credit': FieldValue.increment(-needCredit)});

      return true; // 성공 시 true 반환
    } catch (e) {
      print('Error applying for exchange: $e');
      return false; // 오류 발생 시 false 반환
    }
  }

  static Future<bool> checkApplyExchange(String exchangeId, String uid) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // exchanges 컬렉션의 doc id가 exchangeId인 문서를 찾음
      final docSnapshot =
          await _firestore.collection('exchanges').doc(exchangeId).get();

      if (!docSnapshot.exists) {
        return true; // 해당 문서가 없으면 true 반환
      }

      // applicants 서브 컬렉션의 문서들을 확인
      final applicantsSnapshot =
          await docSnapshot.reference.collection('applicants').get();

      if (applicantsSnapshot.docs.isEmpty) {
        return true; // applicants 서브 컬렉션이 없거나 비어있으면 true 반환
      }

      // applicants 서브 컬렉션 내의 문서들을 순회하면서 applicantUid가 uid와 동일한지 확인
      for (var doc in applicantsSnapshot.docs) {
        if (doc.data()['applicantUid'] == uid) {
          return false; // 동일한 uid를 찾으면 false 반환
        }
      }

      return true; // 동일한 uid를 찾지 못했으면 true 반환
    } catch (e) {
      print('Error checking apply exchange: $e');
      return false; // 오류 발생 시 false 반환
    }
  }

  static Future<bool> applyVolunteerTime(
      List<Map<String, String>> dataList) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      for (var data in dataList) {
        String postId = data['postId']!;
        String inc = data['inc']!;

        DocumentReference postRef = _firestore.collection('posts').doc(postId);

        if (inc == '1365') {
          await postRef.update({'volunteer1365': 'applied'});
        } else if (inc == 'univ') {
          await postRef.update({'volunteerUniv': 'applied'});
        }
      }
      return true;
    } catch (e) {
      print('Error applying volunteer time: $e');
      return false;
    }
  }
}
