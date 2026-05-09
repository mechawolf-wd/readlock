// StoreKit integration for iOS auto-renewable subscriptions.
//
// Wraps the in_app_purchase plugin into the same static-service pattern
// used by ConnectivityService: one initialize() call in main.dart wires
// the purchase stream for the lifetime of the app. Surfaces available
// products via a ValueNotifier so the Feathers sheet can show real App
// Store prices when they exist, and falls back gracefully when products
// have not been created in App Store Connect yet.
//
// The Completer pattern bridges the stream-based purchase API back to an
// imperative Future so PurchaseService.creditFeathers can await the
// result and report success/failure to the UI caller.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:readlock/services/LoggingService.dart';
import 'package:readlock/services/purchases/PurchaseConstants.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';
import 'package:readlock/services/auth/UserService.dart';

// Purchase status reported back to PurchaseService.
enum StoreKitPurchaseStatus {
  success,
  cancelled,
  pending,
  failed,
  storeUnavailable,
}

class StoreKitService {
  static final ServiceLogger logger = ServiceLogger.forService('StoreKitService');

  // Products fetched from the App Store. Empty until initialize() resolves
  // or when products have not been created in ASC yet. The Feathers sheet
  // reads this to show real prices when available.
  static final ValueNotifier<Map<String, ProductDetails>> productsNotifier =
      ValueNotifier<Map<String, ProductDetails>>(const {});

  static StreamSubscription<List<PurchaseDetails>>? purchaseSubscription;
  static bool isInitialized = false;

  // Bridges the stream-based purchase result back to the imperative
  // buyProduct() caller. Set when a purchase starts, completed when the
  // stream delivers a terminal status for that product.
  static Completer<StoreKitPurchaseStatus>? activePurchaseCompleter;

  // * Initialization

  static Future<void> initialize() async {
    final bool alreadyInitialized = isInitialized;

    if (alreadyInitialized) {
      return;
    }

    final bool isStoreAvailable = await InAppPurchase.instance.isAvailable();

    if (!isStoreAvailable) {
      logger.warning('initialize', 'Store is not available');
      isInitialized = true;
      return;
    }

    // Listen to the purchase update stream. This fires for every
    // purchase and restore event for the lifetime of the app.
    purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      handlePurchaseUpdates,
      onError: handlePurchaseStreamError,
    );

    await fetchProducts();

    isInitialized = true;

    logger.success('initialize');
  }

  // * Product loading

  static Future<void> fetchProducts() async {
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(
      PurchaseConstants.SUBSCRIPTION_PRODUCT_IDS,
    );

    final bool hasErrors = response.error != null;

    if (hasErrors) {
      logger.failure('fetchProducts', '${response.error}');
      return;
    }

    final bool hasNoProducts = response.productDetails.isEmpty;

    if (hasNoProducts) {
      logger.warning('fetchProducts', 'No products found in the store');
      return;
    }

    final Map<String, ProductDetails> productMap = {};

    for (final ProductDetails product in response.productDetails) {
      productMap[product.id] = product;
    }

    productsNotifier.value = productMap;

    logger.success('fetchProducts', 'Loaded ${productMap.length} products');
  }

  // * Purchase flow

  static Future<StoreKitPurchaseStatus> buyProduct(String productId) async {
    final Map<String, ProductDetails> products = productsNotifier.value;
    final ProductDetails? product = products[productId];
    final bool productNotLoaded = product == null;

    if (productNotLoaded) {
      logger.failure('buyProduct', 'Product $productId not loaded from store');
      return StoreKitPurchaseStatus.storeUnavailable;
    }

    activePurchaseCompleter = Completer<StoreKitPurchaseStatus>();

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    // iOS auto-renewable subscriptions are treated as non-consumable
    // by the in_app_purchase plugin.
    final bool initiated = await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: purchaseParam,
    );

    final bool didNotInitiate = !initiated;

    if (didNotInitiate) {
      activePurchaseCompleter?.complete(StoreKitPurchaseStatus.failed);
      activePurchaseCompleter = null;

      logger.failure('buyProduct', 'Purchase did not initiate');

      return StoreKitPurchaseStatus.failed;
    }

    // Wait for the stream listener to resolve the purchase.
    final StoreKitPurchaseStatus result = await activePurchaseCompleter!.future;

    activePurchaseCompleter = null;

    return result;
  }

  // * Purchase stream handler

  static Future<void> handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final PurchaseDetails purchase in purchases) {
      await handleSinglePurchase(purchase);
    }
  }

  static Future<void> handleSinglePurchase(PurchaseDetails purchase) async {
    final PurchaseStatus status = purchase.status;

    switch (status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored: {
        await handleSuccessfulPurchase(purchase);
      }
      case PurchaseStatus.error: {
        logger.failure('handleSinglePurchase', '${purchase.error}');
        activePurchaseCompleter?.complete(StoreKitPurchaseStatus.failed);
      }
      case PurchaseStatus.canceled: {
        logger.info('handleSinglePurchase', 'User cancelled');
        activePurchaseCompleter?.complete(StoreKitPurchaseStatus.cancelled);
      }
      case PurchaseStatus.pending: {
        logger.info('handleSinglePurchase', 'Purchase pending');
      }
    }

    // Always mark the purchase as complete so StoreKit clears the
    // transaction from its queue. Required for both success and failure
    // to avoid the "unfinished transaction" dialog on next launch.
    final bool needsCompletion = purchase.pendingCompletePurchase;

    if (needsCompletion) {
      await InAppPurchase.instance.completePurchase(purchase);
    }
  }

  static Future<void> handleSuccessfulPurchase(PurchaseDetails purchase) async {
    final String productId = purchase.productID;
    final int? feathersToCredit = PurchaseConstants.FEATHERS_PER_PRODUCT[productId];
    final bool isUnknownProduct = feathersToCredit == null;

    if (isUnknownProduct) {
      logger.warning('handleSuccessfulPurchase', 'Unknown product: $productId');
      activePurchaseCompleter?.complete(StoreKitPurchaseStatus.failed);
      return;
    }

    // Credit feathers optimistically, then persist.
    final int previousBalance = userBalanceNotifier.value;
    userBalanceNotifier.value = previousBalance + feathersToCredit;

    final bool wrote = await UserService.incrementBalance(feathersToCredit);

    if (!wrote) {
      userBalanceNotifier.value = previousBalance;
      logger.failure('handleSuccessfulPurchase', 'Firestore balance write failed');
      activePurchaseCompleter?.complete(StoreKitPurchaseStatus.failed);
      return;
    }

    logger.success('handleSuccessfulPurchase', '+$feathersToCredit feathers for $productId');
    activePurchaseCompleter?.complete(StoreKitPurchaseStatus.success);
  }

  // * Restore purchases (App Store requirement)

  static Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();

    // Restored transactions flow through the same purchaseStream listener
    // and are handled by handleSinglePurchase with PurchaseStatus.restored.
  }

  // * Stream error handler

  static void handlePurchaseStreamError(Object error) {
    logger.failure('purchaseStream', '$error');
  }

  // * Cleanup

  static Future<void> dispose() async {
    await purchaseSubscription?.cancel();
    purchaseSubscription = null;
    isInitialized = false;
  }
}
