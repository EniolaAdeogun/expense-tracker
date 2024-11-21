import 'package:expense_tracker/Pages/homePage.dart';
import 'package:expense_tracker/database/expense_dartbase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ExpenseDataBase.initialize();
  runApp(
    
    ChangeNotifierProvider(
      create: (context) => ExpenseDataBase(),
      child: const MyApp(),
    )
    
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const  MaterialApp(
     debugShowCheckedModeBanner: false,
      home:  HomePage(),
    );
  }
}


