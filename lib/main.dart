import 'package:flutter/material.dart';
import 'screens/books_screen.dart';
import 'screens/expense_details_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final book = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ExpenseDetailsScreen(book: book),
          );
        }
        return MaterialPageRoute(builder: (context) => BooksScreen());
      },
    );
  }
}
