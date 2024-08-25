import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../providers/price_provider.dart';

class PriceGraphScreen extends StatefulWidget {
  @override
  _PriceGraphScreenState createState() => _PriceGraphScreenState();
}

class _PriceGraphScreenState extends State<PriceGraphScreen> {
  List<FlSpot> _portfolioValues = [];
  double _totalBitcoinAmount = 0.0;
  bool _isFetchingData = false;
  String? _errorMessage; // To display errors

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData(); // Fetch data every time the screen is displayed
  }

  Future<void> _fetchData() async {
    if (_isFetchingData) return;
    _isFetchingData = true;

    try {
      print("Fetching data...");
      await Provider.of<PriceProvider>(context, listen: false).fetchBitcoinPrices();
      _calculateTotalPortfolioBalance();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch data: $e';
      });
    } finally {
      _isFetchingData = false;
    }
  }

  Future<void> _calculateTotalPortfolioBalance() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      print("Fetching portfolio data...");
      final portfolioResponse = await http.get(
        Uri.parse('http://app.numerisgroup.xyz/portfolios'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': 'token=$token',
        },
      );

      if (portfolioResponse.statusCode == 200) {
        final portfolios = jsonDecode(portfolioResponse.body) as List;

        _totalBitcoinAmount = portfolios.fold(0.0, (sum, portfolio) {
          return sum + (portfolio['amount'] as num).toDouble();
        });

        print("Total Bitcoin Amount: $_totalBitcoinAmount");

        _calculatePortfolioValues();
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

  void _calculatePortfolioValues() {
    final priceProvider = Provider.of<PriceProvider>(context, listen: false);
    final bitcoinPrices = priceProvider.bitcoinPrices;

    final firstTimestamp = bitcoinPrices.first[0] as int;

    setState(() {
      _portfolioValues = bitcoinPrices.map((price) {
        final normalizedTime = ((price[0] as int) - firstTimestamp).toDouble() / 86400000.0; // Normalize to days
        final portfolioValue = (price[1] as num).toDouble() * _totalBitcoinAmount;
        return FlSpot(normalizedTime, portfolioValue);
      }).toList();

      print("Portfolio Values: $_portfolioValues");
    });
  }

  double _calculateYInterval(double maxY) {
    final intervals = 10; // Calculate intervals for 10 points
    final roughStep = maxY / intervals;

    if (roughStep < 1) {
      return 1.0; // Minimum interval of 1
    } else if (roughStep < 10) {
      return roughStep.roundToDouble(); // Round to the nearest whole number
    } else if (roughStep < 100) {
      return (roughStep / 10).roundToDouble() * 10; // Round to nearest 10
    } else if (roughStep < 1000) {
      return (roughStep / 100).roundToDouble() * 100; // Round to nearest 100
    } else if (roughStep < 10000) {
      return (roughStep / 1000).roundToDouble() * 1000; // Round to nearest 1000
    } else {
      // For very large values, round to nearest large interval but ensure enough points are displayed
      final magnitude = (roughStep / 10000).roundToDouble();
      return magnitude * 10000;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceProvider = Provider.of<PriceProvider>(context);

    double maxY = 0;
    if (priceProvider.bitcoinPrices.isNotEmpty) {
      final double maxPrice = priceProvider.bitcoinPrices.map((e) => (e[1] as num).toDouble()).reduce((a, b) => a > b ? a : b).toDouble();
      final double maxPortfolioValue = _portfolioValues.isNotEmpty
          ? _portfolioValues.map((e) => e.y).reduce((a, b) => a > b ? a : b).toDouble()
          : 0.0;
      maxY = maxPrice > maxPortfolioValue ? maxPrice : maxPortfolioValue;
    }

    final yInterval = _calculateYInterval(maxY);
    final adjustedMaxY = maxY + yInterval; // Ensure there’s an additional point at the top

    return Scaffold(
      appBar: AppBar(
        title: Text('Bitcoin Price & Portfolio Values'),
      ),
      body: Container(
        color: Colors.orange, // Background color
        padding: const EdgeInsets.all(16.0),
        child: _errorMessage != null
            ? Center(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              )
            : priceProvider.bitcoinPrices.isEmpty
                ? Center(child: CircularProgressIndicator())
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitles: (value) {
                            if (value % 3 == 0) { // Show every 3rd value to reduce clutter
                              final date = DateTime.now().subtract(Duration(days: 30 - value.toInt()));
                              return DateFormat('MM/dd').format(date);
                            }
                            return '';
                          },
                          margin: 8,
                          rotateAngle: 90, // Rotate the text to be sideways
                        ),
                        leftTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) {
                            if (value % yInterval == 0 || value == adjustedMaxY) {
                              return '\$${value.toInt()}';
                            }
                            return '';
                          },
                          reservedSize: 40,
                          margin: 8,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.white),
                      ),
                      minX: 0,
                      maxX: 30,  // Showing last 30 days
                      minY: 0,
                      maxY: adjustedMaxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: priceProvider.bitcoinPrices.map((e) {
                            final normalizedTime = ((e[0] as int) - (priceProvider.bitcoinPrices.first[0] as int)).toDouble() / 86400000.0;
                            return FlSpot(normalizedTime, (e[1] as num).toDouble());
                          }).toList(),
                          isCurved: true,
                          colors: [Colors.blue],
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true), // Ensure dots are shown on the graph
                          belowBarData: BarAreaData(show: false),
                        ),
                        if (_portfolioValues.isNotEmpty)
                          LineChartBarData(
                            spots: _portfolioValues,
                            isCurved: true,
                            colors: [Colors.green],
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true), // Ensure dots are shown on the graph
                            belowBarData: BarAreaData(show: false),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
