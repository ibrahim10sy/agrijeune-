
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koumi/models/Intrant.dart';
import 'package:koumi/models/Stock.dart';
import 'package:provider/provider.dart';

// Modèle de panier
class CartItem {
  final Stock? stock;
  final Intrant? intrant;
  int quantiteIntrant;
  int quantiteStock;
  bool? isStock;
  CartItem({ this.stock, this.intrant, this.quantiteIntrant = 1, this.quantiteStock = 1,  this.isStock});

}

// class CartItemIntrant {
//   final Intrant intrant;
//   int quantiteIntrant;
//   CartItemIntrant({required this.intrant,  this.quantiteIntrant = 1});

// } 