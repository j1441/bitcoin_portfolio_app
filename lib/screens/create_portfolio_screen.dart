import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import 'about_screen.dart';

class CreatePortfolioScreen extends StatefulWidget {
  @override
  _CreatePortfolioScreenState createState() => _CreatePortfolioScreenState();
}

class _CreatePortfolioScreenState extends State<CreatePortfolioScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createPortfolio() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final response = await http.post(
      Uri.parse('http://app.numerisgroup.xyz/portfolio'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'token=$token',
      },
      body: jsonEncode(<String, dynamic>{
        'name': _nameController.text,
        'amount': double.tryParse(_amountController.text) ?? 0,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true); // Return true to refresh the portfolio list
    } else {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to create portfolio.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Portfolio'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Portfolio Name'),
            ),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createPortfolio,
                    child: Text('Create Portfolio'),
                  ),
          ],
        ),
      ),
    );
  }
}
