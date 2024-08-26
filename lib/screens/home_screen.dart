import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bitcoin Portfolio Tracker'),
      ),
      body: Container(
        color: Colors.black, // Background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset(
              'assets/bitcoin.png',
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to the Bitcoin Portfolio Tracker!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Track your Bitcoin portfolio and stay updated with the latest Bitcoin prices. '
              'This app is built to showcase the use of Flutter, Go, PostgreSQL, and other technologies.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('Sign Up'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/about');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 20.0), // Increase vertical padding
                textStyle: TextStyle(
                  fontSize: 20, // Increase font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text('About The Author and Project'),
            ),
          ],
        ),
      ),
    );
  }
}
