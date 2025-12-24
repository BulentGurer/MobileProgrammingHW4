import 'package:flutter/foundation.dart';
import 'package:hw04/database/database_helper.dart';
import 'package:hw04/models/product.dart';

/// [ProductProvider] State management class for products
///
/// This class extends ChangeNotifier to provide reactive state management
/// for all product-related operations. It acts as a bridge between the UI
/// and the database layer.
class ProductProvider extends ChangeNotifier {
  /// Constructor - loads products on initialization
  ProductProvider() {
    if (kDebugMode) {
      print('[ProductProvider] Initializing ProductProvider...');
    }
    loadProducts();
  }

  /// Database helper instance for performing database operations
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// List of all products currently loaded from the database
  List<Product> _products = [];

  /// Product currently being searched/highlighted
  Product? _selectedProduct;

  /// Loading state indicator
  bool _isLoading = false;

  /// Error message if any operation fails
  String? _errorMessage;

  /// Getter for the products list
  List<Product> get products => _products;

  /// Getter for the selected product
  Product? get selectedProduct => _selectedProduct;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Getter for error message
  String? get errorMessage => _errorMessage;

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message and notify listeners
  void _setError(String? error) {
    _errorMessage = error;
    if (error != null) {
      if (kDebugMode) {
        print('[ProductProvider] Error: $error');
      }
    }
    notifyListeners();
  }

  /// Load all products from the database
  ///
  /// This method fetches all products and updates the UI
  Future<void> loadProducts() async {
    if (kDebugMode) {
      print('[ProductProvider] Loading all products...');
    }

    _setLoading(true);
    _setError(null);

    try {
      _products = await _databaseHelper.getAllProducts();
      if (kDebugMode) {
        print('[ProductProvider] Loaded ${_products.length} products');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[ProductProvider] Error loading products: $e');
      }
      _setError('Failed to load products: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Search for a product by its barcode
  ///
  /// Returns the product if found, null otherwise
  /// Also sets the selectedProduct for highlighting in the UI
  Future<Product?> searchProductByBarcode(String barcodeNo) async {
    if (kDebugMode) {
      print('[ProductProvider] Searching for product: $barcodeNo');
    }

    _setError(null);

    if (barcodeNo.trim().isEmpty) {
      _selectedProduct = null;
      notifyListeners();
      return null;
    }

    try {
      final product =
          await _databaseHelper.getProductByBarcode(barcodeNo.trim());
      _selectedProduct = product;

      if (product != null) {
        if (kDebugMode) {
          print('[ProductProvider] Product found: ${product.productName}');
        }
      } else {
        if (kDebugMode) {
          print('[ProductProvider] Product not found');
        }
      }

      notifyListeners();
      return product;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[ProductProvider] Error searching product: $e');
      }
      _setError('Failed to search product: $e');
      return null;
    }
  }

  /// Add a new product to the database
  ///
  /// Returns true if successful, false otherwise
  /// Automatically reloads the products list after insertion
  Future<bool> addProduct(Product product) async {
    if (kDebugMode) {
      print('[ProductProvider] Adding product: ${product.barcodeNo}');
    }

    _setLoading(true);
    _setError(null);

    try {
      await _databaseHelper.insertProduct(product);
      if (kDebugMode) {
        print('[ProductProvider] Product added successfully');
      }

      // Reload products to update the UI
      await loadProducts();

      // Set the newly added product as selected
      _selectedProduct = product;

      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[ProductProvider] Error adding product: $e');
      }
      _setError('Failed to add product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing product in the database
  ///
  /// Returns true if successful, false otherwise
  /// Automatically reloads the products list after update
  Future<bool> updateProduct(Product product) async {
    if (kDebugMode) {
      print('[ProductProvider] Updating product: ${product.barcodeNo}');
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _databaseHelper.updateProduct(product);

      if (result > 0) {
        if (kDebugMode) {
          print('[ProductProvider] Product updated successfully');
        }

        // Reload products to update the UI
        await loadProducts();

        // Update selected product if it's the one being edited
        if (_selectedProduct?.barcodeNo == product.barcodeNo) {
          _selectedProduct = product;
        }

        return true;
      } else {
        if (kDebugMode) {
          print('[ProductProvider] No product was updated');
        }
        _setError('Product not found');
        return false;
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[ProductProvider] Error updating product: $e');
      }
      _setError('Failed to update product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a product from the database
  ///
  /// Returns true if successful, false otherwise
  /// Automatically reloads the products list after deletion
  Future<bool> deleteProduct(String barcodeNo) async {
    if (kDebugMode) {
      print('[ProductProvider] Deleting product: $barcodeNo');
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _databaseHelper.deleteProduct(barcodeNo);

      if (result > 0) {
        if (kDebugMode) {
          print('[ProductProvider] Product deleted successfully');
        }

        // Clear selected product if it's the one being deleted
        if (_selectedProduct?.barcodeNo == barcodeNo) {
          _selectedProduct = null;
        }

        // Reload products to update the UI
        await loadProducts();

        return true;
      } else {
        if (kDebugMode) {
          print('[ProductProvider] No product was deleted');
        }
        _setError('Product not found');
        return false;
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('[ProductProvider] Error deleting product: $e');
      }
      _setError('Failed to delete product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear the selected product
  void clearSelection() {
    if (kDebugMode) {
      print('[ProductProvider] Clearing selection');
    }
    _selectedProduct = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _setError(null);
  }

  /// Get product count
  Future<int> getProductCount() async {
    return _databaseHelper.getProductCount();
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('[ProductProvider] Disposing ProductProvider');
    }
    super.dispose();
  }
}
