import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/custom_auth_provider.dart';

import 'screens/index/register_mate_index.dart';
import 'screens/index/register_senior_index.dart';
import 'screens/index/main_index.dart';
import 'screens/register/register_select_screen_0.dart';
import 'screens/login_screen.dart';
import 'screens/main/education_screen.dart';
import 'screens/post/post_screen.dart';
import 'screens/activity/activity_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeDateFormatting('ko_KR');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CustomAuthProvider>(
      create: (context) => CustomAuthProvider(),
      child: MaterialApp(
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          if (settings.name == '/post_screen') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => PostScreen(
                memberType: args['memberType'],
                myUid: args['myUid'],
                postId: args['postId'],
                seniorUid: args['seniorUid'],
                seniorName: args['seniorName'],
                imgUrl: args['imgUrl'],
                city: args['city'],
                gu: args['gu'],
                dong: args['dong'],
                dependentType: args['dependentType'],
                withPet: args['withPet'],
                withCam: args['withCam'],
                symptom: args['symptom'],
                petInfo: args['petInfo'],
                symptomInfo: args['symptomInfo'],
                walkingType: args['walkingType'],
                rating: args['rating'],
                ratingCount: args['ratingCount'],
                activityType: args['activityType'],
                startTime: args['startTime'],
                endTime: args['endTime'],
                addInfo: args['addInfo'],
              ),
            );
          } else if (settings.name == '/activity_screen') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ActivityScreen(
                postId: args['postId'],
                currentStatus: args['currentStatus'],
                seniorUid: args['seniorUid'],
                seniorPhoneNum2: args['seniorPhoneNum2'],
                mateUid: args['mateUid'],
              ),
            );
          }
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('Unknown Route')),
              body:
                  Center(child: Text('No route defined for ${settings.name}')),
            ),
          );
        },
        routes: {
          '/register': (context) => RegisterSelectScreen0(),
          '/registerMate': (context) => RegisterMateIndex(),
          '/registerSenior': (context) => RegisterSeniorIndex(),
          '/login': (context) => LoginScreen(),
          '/education': (context) => EducationScreen(),
          '/main': (context) => MainIndex(),
        },
      ),
    );
  }
}
