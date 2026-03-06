import 'package:flutter/material.dart';

class CardModel {
  final int id;           // Her kartın benzersiz kimliği (Grid'de bulmak için)
  final Color color;      // Kartın ana rengi
  final IconData icon;    // Kartın ortasındaki ikon
  bool isFlipped;         // Kart şu an dönük mü?
  bool isMatched;         // Eşleşti mi? (Eşleştiyse ekrandan sileceğiz)

  CardModel({
    required this.id,
    required this.color,
    required this.icon,
    this.isFlipped = false, 
    this.isMatched = false,
  });
}