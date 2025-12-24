import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hw04/models/product.dart';
import 'package:hw04/providers/product_provider.dart';
import 'package:provider/provider.dart';

/// [ProductFormScreen] Screen for adding or editing a product
///
/// This screen provides a beautiful form with validation following
/// Apple's Human Interface Guidelines for clean, intuitive data entry.
///
/// When [product] is provided, the form is in edit mode.
/// When [barcodeNo] is provided, the form is in add mode with pre-filled barcode.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({
    super.key,
    this.barcodeNo,
    this.product,
  });

  /// Barcode for a new product (add mode)
  final String? barcodeNo;

  /// Product to edit (edit mode)
  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen>
    with SingleTickerProviderStateMixin {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Text controllers for form fields
  late final TextEditingController _barcodeController;
  late final TextEditingController _productNameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _taxRateController;
  late final TextEditingController _stockInfoController;

  /// Animation controller for smooth entrance
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  /// Indicates if we're in edit mode
  bool get isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data or empty
    _barcodeController = TextEditingController(
      text: widget.product?.barcodeNo ?? widget.barcodeNo ?? '',
    );
    _productNameController = TextEditingController(
      text: widget.product?.productName ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.product?.category ?? '',
    );
    _unitPriceController = TextEditingController(
      text: widget.product != null ? widget.product!.unitPrice.toString() : '',
    );
    _taxRateController = TextEditingController(
      text: widget.product != null ? widget.product!.taxRate.toString() : '',
    );
    _stockInfoController = TextEditingController(
      text: widget.product?.stockInfo?.toString() ?? '',
    );

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _productNameController.dispose();
    _categoryController.dispose();
    _unitPriceController.dispose();
    _taxRateController.dispose();
    _stockInfoController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Validate and save the form
  Future<void> _handleSave() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fix the errors in the form', isError: true);
      return;
    }

    // Parse form values
    final barcodeNo = _barcodeController.text.trim();
    final productName = _productNameController.text.trim();
    final category = _categoryController.text.trim();
    final unitPrice = double.parse(_unitPriceController.text);
    final taxRate = int.parse(_taxRateController.text);
    final stockInfo = _stockInfoController.text.trim().isEmpty
        ? null
        : int.parse(_stockInfoController.text);

    // Calculate final price
    final price = Product.calculatePrice(unitPrice, taxRate);

    // Create product object
    final product = Product(
      barcodeNo: barcodeNo,
      productName: productName,
      category: category,
      unitPrice: unitPrice,
      taxRate: taxRate,
      price: price,
      stockInfo: stockInfo,
    );

    // Save to database
    final provider = Provider.of<ProductProvider>(context, listen: false);
    bool success;

    if (isEditMode) {
      success = await provider.updateProduct(product);
    } else {
      success = await provider.addProduct(product);
    }

    if (success) {
      _showSnackBar(
        isEditMode
            ? 'Product updated successfully'
            : 'Product added successfully',
      );

      // Return to previous screen
      Navigator.of(context).pop(true);
    } else {
      final errorMessage = provider.errorMessage ?? 'Failed to save product';
      _showSnackBar(errorMessage, isError: true);
    }
  }

  /// Show a snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      // App bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        title: Text(
          isEditMode ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),

      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barcode field
                  _buildTextField(
                    controller: _barcodeController,
                    label: 'Barcode Number',
                    hint: 'Enter unique barcode',
                    icon: Icons.qr_code,
                    enabled:
                        !isEditMode, // Barcode cannot be changed in edit mode
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Barcode is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Product name field
                  _buildTextField(
                    controller: _productNameController,
                    label: 'Product Name',
                    hint: 'Enter product name',
                    icon: Icons.inventory_2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Product name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Category field
                  _buildTextField(
                    controller: _categoryController,
                    label: 'Category',
                    hint: 'e.g., Electronics, Food, Clothing',
                    icon: Icons.category,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Category is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Unit price field
                  _buildTextField(
                    controller: _unitPriceController,
                    label: 'Unit Price',
                    hint: 'Enter price before tax',
                    icon: Icons.attach_money,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Unit price is required';
                      }
                      final price = double.tryParse(value);
                      if (price == null) {
                        return 'Please enter a valid number';
                      }
                      if (price <= 0) {
                        return 'Price must be greater than 0';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tax rate field
                  _buildTextField(
                    controller: _taxRateController,
                    label: 'Tax Rate (%)',
                    hint: 'e.g., 18 for 18%',
                    icon: Icons.percent,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tax rate is required';
                      }
                      final taxRate = int.tryParse(value);
                      if (taxRate == null) {
                        return 'Please enter a valid number';
                      }
                      if (taxRate < 0 || taxRate > 100) {
                        return 'Tax rate must be between 0 and 100';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Stock info field (optional)
                  _buildTextField(
                    controller: _stockInfoController,
                    label: 'Stock Quantity (Optional)',
                    hint: 'Enter stock quantity',
                    icon: Icons.inventory,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final stock = int.tryParse(value);
                        if (stock == null) {
                          return 'Please enter a valid number';
                        }
                        if (stock < 0) {
                          return 'Stock cannot be negative';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Save button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isEditMode ? 'Update' : 'Save',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Info card with price calculation preview
                  if (_unitPriceController.text.isNotEmpty &&
                      _taxRateController.text.isNotEmpty)
                    _buildPricePreview(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build a text field with modern design
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        // Text field
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            prefixIcon: Icon(
              icon,
              color: enabled ? Colors.grey[600] : Colors.grey[400],
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// Build price calculation preview
  Widget _buildPricePreview() {
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final taxRate = int.tryParse(_taxRateController.text) ?? 0;
    final finalPrice = Product.calculatePrice(unitPrice, taxRate);

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: Colors.blue[700], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Price Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Calculation details
          _buildPreviewRow('Unit Price', '\$${unitPrice.toStringAsFixed(2)}'),
          _buildPreviewRow('Tax Rate', '$taxRate%'),
          _buildPreviewRow(
            'Tax Amount',
            '\$${(finalPrice - unitPrice).toStringAsFixed(2)}',
          ),

          const Divider(height: 24),

          _buildPreviewRow(
            'Final Price',
            '\$${finalPrice.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  /// Build a preview row
  Widget _buildPreviewRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
