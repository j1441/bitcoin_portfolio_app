import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PriceProvider with ChangeNotifier {
  List<dynamic> _cachedBitcoinPrices = [];
  DateTime? _cacheExpiry;

  List<dynamic> get bitcoinPrices => _cachedBitcoinPrices;

  Future<void> fetchBitcoinPrices() async {
    if (_cachedBitcoinPrices.isNotEmpty && _cacheExpiry != null && DateTime.now().isBefore(_cacheExpiry!)) {
      // Use cached data if it hasn't expired
      print("Using cached Bitcoin prices");
      return;
    }

    try {
      print("Fetching Bitcoin prices...");
      final btcResponse = await http.get(
        Uri.parse(
            'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=30&interval=daily'),
      );

      if (btcResponse.statusCode == 200) {
        final btcData = jsonDecode(btcResponse.body);
        _cachedBitcoinPrices = btcData['prices'];
        _cacheExpiry = DateTime.now().add(Duration(minutes: 10)); // Cache expires in 10 minutes
        notifyListeners();
        print("Fetched and cached new Bitcoin prices");
      } else if (btcResponse.statusCode == 429) {
        print("Rate limit exceeded. Handling rate limit...");
        await _handleRateLimit(btcResponse);
      } else {
        print("Error fetching Bitcoin price: unexpected status code ${btcResponse.statusCode}");
      }
    } catch (e) {
      print("Error occurred while fetching Bitcoin prices: $e");
    }
  }

  Future<void> _handleRateLimit(http.Response response) async {
    final retryAfter = response.headers['retry-after'];
    if (retryAfter != null) {
      final waitTime = int.tryParse(retryAfter) ?? 60;
      await Future.delayed(Duration(seconds: waitTime));
    } else {
      await Future.delayed(Duration(seconds: 60));
    }
  }
}
