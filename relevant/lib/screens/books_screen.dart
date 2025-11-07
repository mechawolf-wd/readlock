import 'package:flutter/material.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => BooksScreenState();
}

class BooksScreenState extends State<BooksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MainBody());
  }

  Widget MainBody() {
    return const Center(
      child: Text(
        'Books coming soon!',
        style: TextStyle(fontSize: 20),
      ),
    );
  }

}
