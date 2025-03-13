// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'screens/registration_screen.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Beauty Salon',
//       theme: ThemeData(
//         primarySwatch: Colors.pink,
//         scaffoldBackgroundColor: Color(0xFFF5F5F5),
//         fontFamily: 'Poppins',
//       ),
//       home: RegistrationScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:salon_management/screens/registration_screen.dart';
import 'package:salon_management/screens/customer_screen.dart';
import 'package:salon_management/screens/customer_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salon Management',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: Color(0xFF7E57C2),
        hintColor: Color(0xFFE91E63),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/customers',
      getPages: [
        GetPage(name: '/customers', page: () => CustomerScreen()),
        GetPage(name: '/registration', page: () => RegistrationScreen()),
        GetPage(name: '/customer_details', page: () => CustomerDetailsScreen()),
        // Add more routes as needed
      ],
    );
  }
}