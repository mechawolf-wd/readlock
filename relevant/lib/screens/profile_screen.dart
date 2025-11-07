import 'package:flutter/material.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MainBody());
  }

  Widget MainBody() {
    return const Div.column(
      [
        Text('Profile Screen'),

        Spacing.height(20),

        Div.column(
          [
            Text('Hello - BorderRadius Tests'),

            Spacing.height(10),

            Div.row(
              [Text('Double: 10.0')],
              radius: [25, 25],
              color: Colors.green,
              padding: 8,
            ),

            Spacing.height(10),

            Div.row(
              [Text('Integer: 15')],
              radius: 15,
              color: Colors.orange,
              padding: 8,
            ),

            Spacing.height(10),

            Div.row(
              [Text('BorderRadius object')],
              radius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(35),
              ),
              color: Colors.red,
              padding: 8,
            ),
          ],
          color: Colors.blue,
          padding: 24,
        ),
      ],
      padding: [8, 24],
      margin: 20,
      color: 'blue',
      width: 'full',
      radius: [4, 24],
    );
  }
}
