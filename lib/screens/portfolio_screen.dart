import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/price_provider.dart';  // Import the PriceProvider
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_portfolio_screen.dart';
import 'about_screen.dart'; 
import 'price_graph_screen.dart'; 

class PortfolioScreen extends StatefulWidget {
  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List _portfolios = [];
  double _totalValueUSD = 0.0;
  double _totalBitcoinAmount = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // First, fetch the Bitcoin prices and cache them
      await Provider.of<PriceProvider>(context, listen: false).fetchBitcoinPrices();
      // Then, fetch the portfolios
      await _fetchPortfolios();
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while fetching data: $e';
      });
    }
  }

  Future<void> _fetchPortfolios() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await http.get(
        Uri.parse('http://app.numerisgroup.xyz/portfolios'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': 'token=$token',
        },
      );

      if (response.statusCode == 200) {
        final portfolios = jsonDecode(response.body);
        setState(() {
          _portfolios = portfolios;
          _totalBitcoinAmount = _calculateTotalBitcoinAmount(portfolios);
          _totalValueUSD = _calculateTotalValueUSD(portfolios);
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch portfolios. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while fetching portfolios: $e';
      });
    }
  }

  double _calculateTotalBitcoinAmount(List portfolios) {
    double total = 0.0;
    for (var portfolio in portfolios) {
      total += (portfolio['amount'] as num).toDouble(); // Safely convert to double
    }
    return total;
  }

  double _calculateTotalValueUSD(List portfolios) {
    double total = 0.0;
    // Access the cached Bitcoin prices from PriceProvider
    final bitcoinPrices = Provider.of<PriceProvider>(context, listen: false).bitcoinPrices;

    // Use the latest Bitcoin price to calculate the total USD value
    if (bitcoinPrices.isNotEmpty) {
      final latestPrice = (bitcoinPrices.last[1] as num).toDouble();
      for (var portfolio in portfolios) {
        total += (portfolio['amount'] as num).toDouble() * latestPrice;
      }
    }

    return total;
  }

  Future<void> _deletePortfolio(int portfolioId) async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await http.delete(
        Uri.parse('http://app.numerisgroup.xyz/portfolio/delete'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': 'token=$token',
        },
        body: jsonEncode({'id': portfolioId}),
      );

      if (response.statusCode == 204) {
        setState(() {
          _portfolios.removeWhere((p) => p['id'] == portfolioId);
          _totalBitcoinAmount = _calculateTotalBitcoinAmount(_portfolios);
          _totalValueUSD = _calculateTotalValueUSD(_portfolios);
          _errorMessage = null;
        });
      } else {
        _showErrorDialog('Failed to delete portfolio. Please try again later.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while deleting the portfolio: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Portfolio'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PriceGraphScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.orange,
        child: _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchData,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
            : Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total Portfolio Value: \$${_totalValueUSD.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Total Bitcoin: ${_totalBitcoinAmount.toStringAsFixed(8)} BTC',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _portfolios.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_portfolios[index]['name']),
                          subtitle: Text(
                              '${_portfolios[index]['amount']} BTC - \$${_portfolios[index]['value_usd']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              final confirmed = await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Delete Portfolio'),
                                  content: Text(
                                      'Are you sure you want to delete this portfolio?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await _deletePortfolio(
                                    _portfolios[index]['id']);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? portfolioCreated = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CreatePortfolioScreen()),
          );
          if (portfolioCreated == true) {
            _fetchData(); // Refresh the portfolio list
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
