import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Container(
        color: Colors.orange, // Background color
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'About This App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'This Bitcoin Portfolio Tracker app was built as part of a job application for a software developer position. The app showcases my ability to develop a full-stack mobile application using the following technologies:',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                '- **Flutter**: Used for building the mobile application and UI.\n'
                '- **Go (Golang)**: Used for developing the backend server, handling API requests, user authentication, and portfolio management.\n'
                '- **PostgreSQL**: Utilized as the database for storing user data, portfolios, and transactions.\n'
                '- **Next.js and TypeScript**: Used for building the web frontend available at web.numerisgroup.xyz/.\n'
                '- **Heroku**: Deployed the backend server and database on Heroku for ease of setup and 24/7 availability.\n'
                '- **Coingecko API**: Integrated to fetch real-time Bitcoin prices.\n',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Purpose',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'The purpose of this app is to demonstrate my skills in building a modern, responsive, and secure mobile application. It serves as a proof of concept for my capability to handle full-stack development tasks, from designing and implementing a backend API to building a mobile frontend and deploying the entire stack to a production environment.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Thank you for considering my application! Source code can be found at https://github.com/j1441/',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
