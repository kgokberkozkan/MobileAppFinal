import 'package:flutter/material.dart';

class BasketProvider with ChangeNotifier {
  // List to hold basket items
  List<Map<String, dynamic>> _basketItems = [];

  // Getter for basket items
  List<Map<String, dynamic>> get basketItems => _basketItems;

  // Add item to basket
  void addItem(Map<String, dynamic> item) {
    _basketItems.add(item);
    notifyListeners();
  }

  // Remove item from basket
  void removeItem(Map<String, dynamic> item) {
    _basketItems.remove(item);
    notifyListeners();
  }
}