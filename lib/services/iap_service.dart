import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'persistence_service.dart';

class IapService extends ChangeNotifier {
  IapService._();
  static final IapService instance = IapService._();

  static const String _kFullGameUnlock = 'full_game_unlock';
  static const String _kFullGamePurchasedKey = 'settings.iap.full_game_purchased';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  bool _isFullGamePurchased = false;
  bool get isFullGamePurchased => _isFullGamePurchased;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  Future<void> init() async {
    _isFullGamePurchased = PersistenceService.instance.getBool(_kFullGamePurchasedKey);
    
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint('IAP Error: $error');
    });

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) return;

    final Set<String> kIds = {_kFullGameUnlock};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(kIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }
    _products = response.productDetails;
    notifyListeners();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      // Show pending UI if needed
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('Purchase Error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        if (purchaseDetails.productID == _kFullGameUnlock) {
          _isFullGamePurchased = true;
          PersistenceService.instance.setBool(_kFullGamePurchasedKey, true);
          notifyListeners();
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> buyFullGame() async {
    if (_products.isEmpty) {
      debugPrint('IAP Error: No products loaded.');
      return;
    }
    try {
      final ProductDetails productDetails =
          _products.firstWhere((p) => p.id == _kFullGameUnlock);
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('IAP Error during purchase: $e');
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('IAP Error during restore: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
