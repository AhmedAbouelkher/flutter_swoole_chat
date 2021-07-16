import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swoole_chat/Helpers/shared_prefs_utils.dart';
import 'package:flutter_swoole_chat/Screens/home/home_screen.dart';
import 'package:provider/provider.dart';

import 'Controllers/Providers/auth_provider.dart';
import 'Controllers/Providers/chat_provider.dart';
import 'Controllers/Repositories/auth_repository.dart';
import 'Screens/auth/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceUtils.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthRepository _authRepository;
  late final ChatRepository _chatRepository;
  late final Dio _dio;

  @override
  void initState() {
    _dio = Dio();
    _authRepository = AuthRepository(dio: _dio);
    _chatRepository = ChatRepository(dio: _dio, authRepository: _authRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: _authRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            chatRepository: _chatRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Material App',
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      final _provider = AuthProvider.get(context);
      if (_provider.userToken == null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => AuthScreen()));
      } else {
        try {
          await _provider.fetchUserData();
          Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } catch (e) {
          print(e);
          Navigator.push(context, MaterialPageRoute(builder: (_) => AuthScreen()));
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
