import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:koumi/models/CartItem.dart';
import 'package:koumi/models/Intrant.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/widgets/SnackBar.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> cartItems = [];

  List<CartItem> get cartItem => cartItems;

  // void addToCart( Stock? product, int quantity, String? selectedVariant) {
  // var existingCartItem = cartItem.firstWhereOrNull(
  //   (item) => item.stock != null && item.stock!.idStock == product!.idStock,
  // );

  //   if (existingCartItem != null) {
  //     // existingCartItem.quantiteStock += quantity;
  //   Snack.error(titre:"Alerte", message:existingCartItem.stock!.nomProduit! + " existe déjà au panier");
  //   } else {
  //     cartItem.add(CartItem(stock: product, quantiteStock: quantity, isStock:true ));
  //   Snack.success(titre:"Alerte", message:product!.nomProduit! + " a été ajouté au panier");

  //   }

  //   notifyListeners();
  // }

  void addToCart(Stock? product, int quantity, String? selectedVariant) {
    if (product == null || quantity <= 0) {
      // Gérer le cas où le produit ou la quantité est nulle ou invalide
      Snack.error(titre: "Alerte", message: "Produit ou quantité invalide");
      return;
    }

    var existingCartItem = cartItem.firstWhereOrNull(
      (item) => item.stock != null && item.stock!.idStock == product.idStock,
    );

    if (existingCartItem != null) {
      // Le produit existe déjà dans le panier
      Snack.error(
          titre: "Alerte",
          message:
              "${existingCartItem.stock!.nomProduit!} existe déjà dans le panier");
      return;
    }

    if (cartItem.isEmpty) {
      // Si le panier est vide, ajoutez simplement le produit
      cartItem.add(
          CartItem(stock: product, quantiteStock: quantity, isStock: true));
      Snack.success(
          titre: "Alerte",
          message: "${product.nomProduit!} a été ajouté au panier");
    } else {
      // Vérifiez si le nouveau produit appartient au même acteur que les produits déjà présents dans le panier
      bool sameActor = cartItem.every((item) =>
          item.stock != null &&
          item.stock!.acteur!.idActeur == product.acteur!.idActeur);

      if (sameActor) {
        // Si le nouveau produit appartient au même acteur, ajoutez-le au panier
        cartItem.add(
            CartItem(stock: product, quantiteStock: quantity, isStock: true));
        Snack.success(
            titre: "Alerte",
            message: "${product.nomProduit!} a été ajouté au panier");
      } else {
        // Sinon, affichez un message d'erreur
        Snack.error(
            titre: "Alerte",
            message:
                "Impossible d'ajouter le produit. On ne peut pas commander chez plusieurs personnes à la fois en une seule commande.");
        return;
      }
    }

    notifyListeners();
  }

  void addToCartInt(
      Intrant? intrant, int? quantityInt, String? selectedVariantInt) {
    if (intrant == null || quantityInt == null || quantityInt <= 0) {
      // Gérer le cas où l'intrant ou la quantité est nulle ou invalide
      Snack.error(titre: "Alerte", message: "Intrant ou quantité invalide");
      return;
    }

    var existingCartItem = cartItem.firstWhereOrNull(
      (item) =>
          item.intrant != null &&
          item.intrant!.idIntrant! == intrant.idIntrant!,
    );

    if (existingCartItem != null) {
      // L'intrant existe déjà dans le panier
      Snack.error(
          titre: "Alerte",
          message: "${intrant.nomIntrant!} existe déjà dans le panier");
      return;
    }

    if (cartItem.isEmpty) {
      // Si le panier est vide, ajoutez simplement l'intrant
      cartItem.add(CartItem(
          intrant: intrant, quantiteIntrant: quantityInt, isStock: false));
      Snack.success(
          titre: "Alerte",
          message: "${intrant.nomIntrant!} a été ajouté au panier");
    } else {
      // Vérifiez si le nouveau intrant appartient au même acteur que les intrants déjà présents dans le panier
      bool sameActor = cartItem.every((item) =>
          item.intrant != null &&
          item.intrant!.acteur!.idActeur == intrant.acteur!.idActeur);
      if (sameActor) {
        // Si le nouveau produit appartient au même acteur, ajoutez-le au panier
        cartItem.add(CartItem(
            intrant: intrant, quantiteIntrant: quantityInt, isStock: false));
        Snack.success(
            titre: "Alerte",
            message: "${intrant.nomIntrant!} a été ajouté au panier");
      } else {
        // Sinon, affichez un message d'erreur
        Snack.error(
            titre: "Alerte",
            message: "Veillez d'abord confirmer la commande déjà en cours.");
        return;
      }
    }

    notifyListeners();
  }

//   void addToCartInt(Intrant? intrant, int? quantityInt,String? selectedVariantInt) {

//     var existingCartItemInt = cartItem.firstWhereOrNull(
//   (item) => item.intrant != null && item.intrant!.idIntrant == intrant!.idIntrant,
// );

  // if (existingCartItemInt != null) {
  //   // existingCartItem.quantiteStock += quantity;
  // Snack.error(titre:"Alerte", message:existingCartItemInt.intrant!.nomIntrant + " existe déjà au panier");
  // }
//else {
//       cartItem.add(CartItem(intrant: intrant, quantiteIntrant: quantityInt!, isStock: false));
//     Snack.success(titre:"Alerte", message:intrant!.nomIntrant + " a été ajouté au panier");

//     }

//     notifyListeners();
//   }

  int getProductQuantity(int productId) {
    int quantity = 0;
    for (CartItem item in cartItem) {
      if (item.stock!.idStock == productId) {
        quantity += item.quantiteStock;
      }
    }
    return quantity;
  }

  int getIntrantQuantity(int intrantId) {
    int quantity = 0;
    for (CartItem item in cartItem) {
      if (item.intrant!.idIntrant == intrantId) {
        quantity += item.quantiteIntrant;
      }
    }
    return quantity;
  }

  int get cartCount {
    return cartItem.fold(
        0, (sum, item) => sum + item.quantiteStock + item.quantiteIntrant);
  }

  // double get totalPrice {
  //   return cartItem.fold(
  //       0.0, (sum, item) => sum + (item.stock!.prix! * item.quantiteStock) + (item.intrant!.prixIntrant * item.quantiteIntrant));
  // }
  double get totalPrice {
    return cartItem.fold(
        0.0,
        (sum, item) =>
            sum +
            ((item.stock != null ? item.stock!.prix! * item.quantiteStock : 0) +
                (item.intrant != null
                    ? item.intrant!.prixIntrant! * item.quantiteIntrant
                    : 0)));
  }

  void updateCartItemQuantity(int index, int newQuantity) {
    if (index >= 0 && index < cartItem.length) {
      cartItem[index].quantiteStock = newQuantity;

      notifyListeners();
    }
  }

  void updateCartItemIntQuantity(int index, int newQuantity) {
    if (index >= 0 && index < cartItem.length) {
      cartItem[index].quantiteIntrant = newQuantity;

      notifyListeners();
    }
  }

  void increaseCartItemQuantity(int index) {
    if (index >= 0 && index < cartItem.length) {
      cartItem[index].quantiteStock++;
      notifyListeners();
    }
  }

  void increaseCartItemIntQuantity(int index) {
    if (index >= 0 && index < cartItem.length) {
      cartItem[index].quantiteIntrant++;
      notifyListeners();
    }
  }

  void decreaseCartItemQuantity(int index) {
    if (index >= 0 && index < cartItem.length) {
      if (cartItem[index].quantiteStock > 1) {
        cartItem[index].quantiteStock--;
        notifyListeners();
      } else {
        // If the quantity is 1, remove the item from the cart
        cartItem.removeAt(index);
        notifyListeners();
      }
    }
  }

  void decreaseCartItemIntQuantity(int index) {
    if (index >= 0 && index < cartItem.length) {
      if (cartItem[index].quantiteIntrant > 1) {
        cartItem[index].quantiteIntrant--;
        notifyListeners();
      } else {
        // If the quantity is 1, remove the item from the cart
        cartItem.removeAt(index);
        notifyListeners();
      }
    }
  }

  void removeCartItem(int index) {
    if (index >= 0 && index < cartItem.length) {
      cartItem.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    cartItem.clear();
    notifyListeners();
  }

  List<CartItem> getCartItemsList() {
    return List<CartItem>.from(cartItem);
  }

  // List<CartItem> get cartItemInt => cartItemInt;

  // void addToCartInt(Intrant intrant, int quantity, String selectedVariant) {
  //   var existingCartItemInt = cartItemInt.firstWhereOrNull(
  //     (item) => item.intrant!.idIntrant == intrant.idIntrant,
  //   );

  //   if (existingCartItemInt != null) {
  //     // existingCartItem.quantiteStock += quantity;
  //   Snack.error(titre:"Alerte", message:existingCartItemInt.intrant!.nomIntrant + " existe déjà au panier");
  //   } else {
  //     cartItemInt.add(CartItem(intrant: intrant, quantiteIntrant: quantity));
  //   Snack.success(titre:"Alerte", message:intrant.nomIntrant + " a été ajouté au panier");

  //   }

  //   notifyListeners();
  // }

  // int getIntrantQuantity(int intrantId) {
  //   int quantity = 0;
  //   for (CartItem item in cartItemInt) {
  //     if (item.intrant!.idIntrant == intrantId) {
  //       quantity += item.quantiteIntrant;
  //     }
  //   }
  //   return quantity;
  // }

  // int get cartCountInt {
  //   return cartItemInt.fold(0, (sum, item) => sum + item.quantiteIntrant);
  // }

  // double get totalPriceInt {
  //   return cartItemInt.fold(
  //       0.0, (sum, item) => sum + (item.intrant!.prixIntrant * item.quantiteIntrant));
  // }

  // void updateCartItemQuantityInt(int index, int newQuantity) {
  //   if (index >= 0 && index < cartItemInt.length) {
  //     cartItemInt[index].quantiteIntrant = newQuantity;
  //     notifyListeners();
  //   }
  // }

  // void increaseCartItemQuantityInt(int index) {
  //   if (index >= 0 && index < cartItemInt.length) {
  //     cartItemInt[index].quantiteIntrant++;
  //     notifyListeners();
  //   }
  // }

  // void decreaseCartItemQuantityInt(int index) {
  //   if (index >= 0 && index < cartItemInt.length) {
  //     if (cartItemInt[index].quantiteIntrant > 1) {
  //       cartItemInt[index].quantiteIntrant--;
  //       notifyListeners();
  //     } else {
  //       // If the quantity is 1, remove the item from the cart
  //       cartItemInt.removeAt(index);
  //       notifyListeners();
  //     }
  //   }
  // }

  // void removeCartItemInt(int index) {
  //   if (index >= 0 && index < cartItemInt.length) {
  //     cartItemInt.removeAt(index);
  //     notifyListeners();
  //   }
  // }

  // void clearCartInt() {
  //   cartItemInt.clear();
  //   notifyListeners();
  // }

  // List<CartItem> getCartItemsListInt() {
  //   return List<CartItem>.from(cartItemInt);
  // }
}
