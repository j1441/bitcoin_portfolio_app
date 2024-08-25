import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/price_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/create_portfolio_screen.dart';
import 'screens/about_screen.dart';
import 'screens/price_graph_screen.dart';
import 'screens/home_screen.dart'; // Import the new HomeScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PriceProvider()),
      ],
      child: MaterialApp(
        title: 'Bitcoin Portfolio Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.orange, // Set global background color
        ),
        initialRoute: '/', // Set HomeScreen as the initial route
        routes: {
          '/': (context) => HomeScreen(), // HomeScreen as the initial route
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
          '/portfolio': (context) => PortfolioScreen(),
          '/create_portfolio': (context) => CreatePortfolioScreen(),
          '/about': (context) => AboutScreen(),
          '/price_graph': (context) => PriceGraphScreen(),
        },
      ),
    );
  }
}
