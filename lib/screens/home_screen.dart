import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hw04/models/product.dart';
import 'package:hw04/providers/product_provider.dart';
import 'package:hw04/screens/product_form_screen.dart';
import 'package:provider/provider.dart';

/// [HomeScreen] Main screen of the application
///
/// This screen displays a search bar for barcode lookup and a beautiful
/// grid view of all products with edit/delete functionality.
///
/// Design follows Apple's Human Interface Guidelines for a clean,
/// modern, and intuitive user experience with smooth animations.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  /// Text controller for the barcode search field
  final TextEditingController _barcodeController = TextEditingController();

  /// Focus node for the barcode search field
  final FocusNode _barcodeFocusNode = FocusNode();

  /// Animation controller for smooth transitions
  late AnimationController _animationController;

  /// Fade animation for search results
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('[HomeScreen] Initializing HomeScreen');
    }

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Setup fade animation
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('[HomeScreen] Disposing HomeScreen');
    }
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Handle search button press
  ///
  /// Searches for a product by barcode and shows a dialog if not found
  Future<void> _handleSearch() async {
    if (kDebugMode) {
      print('[HomeScreen] Search button pressed');
    }

    final barcodeNo = _barcodeController.text.trim();

    if (barcodeNo.isEmpty) {
      _showSnackBar('Please enter a barcode', isError: true);
      return;
    }

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final product = await provider.searchProductByBarcode(barcodeNo);

    if (product == null) {
      // Product not found - show dialog to add new product
      _showAddProductDialog(barcodeNo);
    } else {
      // Product found - show success message
      _showSnackBar('Product found: ${product.productName}');
    }
  }

  /// Show dialog asking if user wants to add a new product
  void _showAddProductDialog(String barcodeNo) {
    if (kDebugMode) {
      print('[HomeScreen] Showing add product dialog for barcode: $barcodeNo');
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Product Not Found',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Would you like to add a new product with this barcode?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                if (kDebugMode) {
                  print('[HomeScreen] Add product dialog cancelled');
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),

            // Add button
            TextButton(
              onPressed: () {
                if (kDebugMode) {
                  print('[HomeScreen] Navigating to add product form');
                }
                Navigator.of(context).pop();
                _navigateToProductForm(barcodeNo: barcodeNo);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Add Product',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Navigate to product form screen
  ///
  /// If [barcodeNo] is provided, it's for adding a new product
  /// If [product] is provided, it's for editing an existing product
  Future<void> _navigateToProductForm({
    String? barcodeNo,
    Product? product,
  }) async {
    if (kDebugMode) {
      print('[HomeScreen] Navigating to product form');
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => ProductFormScreen(
          barcodeNo: barcodeNo,
          product: product,
        ),
      ),
    );

    // Clear search and selection after returning
    if (result ?? false) {
      _barcodeController.clear();
      if (mounted) {
        Provider.of<ProductProvider>(context, listen: false).clearSelection();
      }
    }
  }

  /// Show a confirmation dialog before deleting a product
  Future<void> _showDeleteConfirmation(Product product) async {
    if (kDebugMode) {
      print(
        '[HomeScreen] Showing delete confirmation for: ${product.barcodeNo}',
      );
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Product',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${product.productName}"?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                if (kDebugMode) {
                  print('[HomeScreen] Delete cancelled');
                }
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),

            // Delete button
            TextButton(
              onPressed: () {
                if (kDebugMode) {
                  print('[HomeScreen] Delete confirmed');
                }
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final success = await provider.deleteProduct(product.barcodeNo);

      if (success) {
        _showSnackBar('Product deleted successfully');
      } else {
        _showSnackBar('Failed to delete product', isError: true);
      }
    }
  }

  /// Show a snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (kDebugMode) {
      print('[HomeScreen] Showing snackbar: $message');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern gradient background inspired by Apple's design
      backgroundColor: Colors.grey[50],

      // App bar with clean design
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Product Manager',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search section with modern card design
            _buildSearchSection(),

            // Products grid
            Expanded(
              child: _buildProductsGrid(),
            ),
          ],
        ),
      ),

      // Floating action button to add new product
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToProductForm,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Product',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
    );
  }

  /// Build the search section with barcode input
  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'Search Product',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Search field and button
          Row(
            children: [
              // Barcode text field
              Expanded(
                child: TextField(
                  controller: _barcodeController,
                  focusNode: _barcodeFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Enter barcode number',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _handleSearch(),
                ),
              ),

              const SizedBox(width: 12),

              // Search button
              ElevatedButton(
                onPressed: _handleSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the products grid
  Widget _buildProductsGrid() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No products yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first product',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            final product = provider.products[index];
            final isSelected =
                provider.selectedProduct?.barcodeNo == product.barcodeNo;

            return _buildProductCard(product, isSelected);
          },
        );
      },
    );
  }

  /// Build a single product card with modern design
  Widget _buildProductCard(Product product, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.black12,
            offset: const Offset(0, 2),
            blurRadius: isSelected ? 12 : 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (kDebugMode) {
              print('[HomeScreen] Product card tapped: ${product.barcodeNo}');
            }
            _barcodeController.text = product.barcodeNo;
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name and actions
                Row(
                  children: [
                    // Product icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Product name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edit button
                    IconButton(
                      onPressed: () => _navigateToProductForm(product: product),
                      icon: const Icon(Icons.edit_outlined),
                      color: Colors.blue[700],
                      tooltip: 'Edit',
                    ),

                    // Delete button
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(product),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red[700],
                      tooltip: 'Delete',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Product details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Barcode', product.barcodeNo),
                      _buildDetailRow(
                        'Unit Price',
                        '\$${product.unitPrice.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow('Tax Rate', '${product.taxRate}%'),
                      _buildDetailRow(
                        'Final Price',
                        '\$${product.price.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                      _buildDetailRow(
                        'Stock',
                        product.stockInfo != null
                            ? '${product.stockInfo} units'
                            : 'Not tracked',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build a detail row for product information
  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
