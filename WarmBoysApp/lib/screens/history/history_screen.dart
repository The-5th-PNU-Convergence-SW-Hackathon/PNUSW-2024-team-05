import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../../utils/firebase_helper.dart';
import '../../providers/custom_auth_provider.dart';
import '../../screens/history/history_detailed_screen.dart';
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _activitiesFuture;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    final _uid = customAuthProvider.uid;
    final _memberType = customAuthProvider.userInfo!['memberType'];
    _activitiesFuture = FirebaseHelper.queryActivities(_uid!, _memberType);
  }

  Future<Uint8List?> downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to download image.');
        return null;
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  Future<void> shareExcelFile(String filePath) async {
    Share.shareXFiles([XFile('${filePath}')]);
  }

  Future<String> createExcelWithImages(
      List<Map<String, dynamic>> activities) async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    final xlsio.Style headerStyle = workbook.styles.add('HeaderStyle');
    headerStyle.backColor = '#FFFF00'; // 셀 색상
    headerStyle.fontColor = '#101010'; // 폰트 색상

    sheet.getRangeByName('A1').cellStyle = headerStyle;
    sheet.getRangeByName('B1').cellStyle = headerStyle;
    sheet.getRangeByName('C1').cellStyle = headerStyle;
    sheet.getRangeByName('D1').cellStyle = headerStyle;
    sheet.getRangeByName('E1').cellStyle = headerStyle;
    sheet.getRangeByName('F1').cellStyle = headerStyle;
    sheet.getRangeByName('G1').cellStyle = headerStyle;
    sheet.getRangeByName('H1').cellStyle = headerStyle;
    sheet.getRangeByName('I1').cellStyle = headerStyle;
    sheet.getRangeByName('J1').cellStyle = headerStyle;

    sheet.getRangeByName('A1').setText('시니어 이름');
    sheet.getRangeByName('B1').setText('장소');
    sheet.getRangeByName('C1').setText('날짜');
    sheet.getRangeByName('D1').setText('시작 시간');
    sheet.getRangeByName('E1').setText('종료 시간');
    sheet.getRangeByName('F1').setText('활동 종류');
    sheet.getRangeByName('G1').setText('활동 시작 사진');
    sheet.getRangeByName('H1').setText('활동 종료 사진');
    sheet.getRangeByName('I1').setText('활동 시작 보고서');
    sheet.getRangeByName('J1').setText('활동 종료 보고서');

    for (int i = 0; i < activities.length; i++) {
      var activity = activities[i];
      int rowIndex = i + 2;

      sheet.getRangeByIndex(rowIndex, 1).setText(activity['username']);
      sheet.getRangeByIndex(rowIndex, 2).setText(
          "${activity['activityCity']} ${activity['activityGu']} ${activity['activityDong']}");
      sheet.getRangeByIndex(rowIndex, 3).setText(activity['date']);
      sheet.getRangeByIndex(rowIndex, 4).setText(activity['startTime']);
      sheet.getRangeByIndex(rowIndex, 5).setText(activity['endTime']);
      sheet.getRangeByIndex(rowIndex, 6).setText(activity['activityType']);

      sheet.getRangeByIndex(rowIndex, 1).columnWidth = 15.0;
      sheet.getRangeByIndex(rowIndex, 2).columnWidth = 30.0;
      sheet.getRangeByIndex(rowIndex, 3).columnWidth = 15.0;
      sheet.getRangeByIndex(rowIndex, 4).columnWidth = 15.0;
      sheet.getRangeByIndex(rowIndex, 5).columnWidth = 15.0;
      sheet.getRangeByIndex(rowIndex, 6).columnWidth = 15.0;
      sheet.getRangeByIndex(rowIndex, 7).columnWidth = 35.0;
      sheet.getRangeByIndex(rowIndex, 8).columnWidth = 35.0;
      sheet.getRangeByIndex(rowIndex, 9).columnWidth = 100.0;
      sheet.getRangeByIndex(rowIndex, 10).columnWidth = 100.0;

      sheet.getRangeByIndex(rowIndex, 7).rowHeight = 150.0;
      sheet.getRangeByIndex(rowIndex, 8).rowHeight = 150.0;

      Uint8List? startImageBytes = await downloadImage(activity['startImgUrl']);
      if (startImageBytes != null) {
        final xlsio.Picture picture =
            sheet.pictures.addStream(rowIndex, 7, startImageBytes);
        picture.height = 190;
        picture.width = 250;
      }

      Uint8List? endImageBytes = await downloadImage(activity['endImgUrl']);
      if (endImageBytes != null) {
        final xlsio.Picture picture =
            sheet.pictures.addStream(rowIndex, 8, endImageBytes);
        picture.height = 190;
        picture.width = 250;
      }

      sheet.getRangeByIndex(rowIndex, 9).setText(activity['startReport']);
      sheet.getRangeByIndex(rowIndex, 10).setText(activity['endReport']);
    }

    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory() // Android: 외부 저장소 경로
        : await getApplicationDocumentsDirectory(); // iOS: 응용 프로그램의 문서 디렉토리 사용
    final path = "${directory!.path}/activities_report.xlsx";
    final File file = File(path);
    await file.writeAsBytes(workbook.saveAsStream());
    workbook.dispose();

    print('Excel 파일이 $path 에 저장되었습니다.');

    await shareExcelFile(path);

    return path;
  }

  @override
  Widget build(BuildContext context) {
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    final _memberType = customAuthProvider.userInfo!['memberType'];
    final _credit = customAuthProvider.userInfo!['credit'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "활동 기록",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 25),
        child: Column(
          children: [
            _memberType == '메이트'
                ? Column(
                    children: [
                      Divider(
                        color: Colors.grey[200],
                        thickness: 2,
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "내 크레딧:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(width: 15),
                          Text('$_credit',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              )),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(
                        color: Colors.grey[200],
                        thickness: 2,
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: _isDownloading
                            ? null
                            : () async {
                                setState(() {
                                  _isDownloading = true;
                                });

                                // 활동 기록 다운로드
                                List<Map<String, dynamic>> activities =
                                    await _activitiesFuture;
                                final String path =
                                    await createExcelWithImages(activities);

                                setState(() {
                                  _isDownloading = false;
                                });
                              },
                        child: _isDownloading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("엑셀 파일 변환 중...",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'NotoSansKR',
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(width: 10),
                                  CircularProgressIndicator(
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 205, 207),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color.fromARGB(255, 224, 73, 81)),
                                    strokeWidth: 2.0,
                                  ),
                                ],
                              )
                            : Text("활동 기록 다운로드",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'NotoSansKR',
                                    fontWeight: FontWeight.w500)),
                      ),
                      SizedBox(height: 10),
                    ],
                  )
                : Container(),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _activitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('에러가 발생했습니다.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('활동 기록이 없습니다.'));
                  } else {
                    return SingleChildScrollView(
                      child: Column(
                        children: snapshot.data!.map((activity) {
                          return GestureDetector(
                            child: Card(
                              color: Colors.white,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 20, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          (activity['imgUrl'] != '')
                                              ? GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return Dialog(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: CircleAvatar(
                                                              radius: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.5,
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      activity[
                                                                          'imgUrl']),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 40,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            activity['imgUrl']),
                                                  ),
                                                )
                                              : CircleAvatar(
                                                  radius: 40,
                                                  child: Icon(Icons.person),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activity['username'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "장소: ${activity['activityCity']} ${activity['activityGu']} ${activity['activityDong']}",
                                            style: TextStyle(
                                                fontSize: _memberType == '메이트'
                                                    ? 14
                                                    : 16),
                                          ),
                                          Text(
                                            "날짜: ${activity['date']}",
                                            style: TextStyle(
                                                fontSize: _memberType == '메이트'
                                                    ? 14
                                                    : 16),
                                          ),
                                          Text(
                                            "시간: ${activity['startTime']} ~ ${activity['endTime']}",
                                            style: TextStyle(
                                                fontSize: _memberType == '메이트'
                                                    ? 14
                                                    : 16),
                                          ),
                                          Text(
                                            "활동 종류: ${activity['activityType']}",
                                            style: TextStyle(
                                                fontSize: _memberType == '메이트'
                                                    ? 14
                                                    : 16),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "크레딧: ${activity['credit']}",
                                            style: TextStyle(
                                              fontSize: _memberType == '메이트'
                                                  ? 14
                                                  : 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryDetailedScreen(
                                      memberType: _memberType,
                                      activity: activity),
                                ),
                              )
                            },
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
