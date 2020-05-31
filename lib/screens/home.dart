import 'package:flutter/material.dart';
import 'package:lockdownmart/screens/custom_drawer.dart';
import 'package:lockdownmart/screens/homescreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomDrawer(
        foreground: Home(),
      ),
    );
  }
}