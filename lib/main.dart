import 'package:flutter/material.dart';
import 'package:gymbuddy/screens/menu.dart';
import 'package:gymbuddy/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy/providers/user_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        Provider(
          create: (_) {
            CookieRequest request = CookieRequest();
            return request;
          },
        ),

        // UserProvider (untuk ID)
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],

      child: MaterialApp(
        title: 'Gymbuddy Mobile',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
              .copyWith(secondary: Colors.blueAccent[400]),
        ),
          home: const LoginPage(),
      ),
    );
  }
}