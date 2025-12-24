/// [Product] Model class representing a product in the store
///
/// This model contains all the necessary fields for managing products
/// including barcode, pricing, tax, and stock information.
///
/// The [barcodeNo] serves as the primary key in the database.
class Product {
  /// Constructor for creating a Product instance
  Product({
    required this.barcodeNo,
    required this.productName,
    required this.category,
    required this.unitPrice,
    required this.taxRate,
    required this.price,
    this.stockInfo,
  });

  /// Factory constructor to create a Product from a database map
  ///
  /// This is used when reading products from the SQLite database
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      barcodeNo: map['barcodeNo'] as String,
      productName: map['productName'] as String,
      category: map['category'] as String,
      unitPrice: map['unitPrice'] as double,
      taxRate: map['taxRate'] as int,
      price: map['price'] as double,
      stockInfo: map['stockInfo'] as int?,
    );
  }

  /// Primary key - unique barcode identifier for the product
  final String barcodeNo;

  /// Name of the product
  final String productName;

  /// Category of the product (e.g., "Electronics", "Food", etc.)
  final String category;

  /// Unit price before tax
  final double unitPrice;

  /// Tax rate as a percentage (e.g., 18 for 18%)
  final int taxRate;

  /// Final price including tax (calculated)
  final double price;

  /// Stock quantity - can be null if stock info is not mandatory
  final int? stockInfo;

  /// Convert Product instance to a Map for database insertion
  ///
  /// This is used when inserting or updating products in the SQLite database
  Map<String, dynamic> toMap() {
    return {
      'barcodeNo': barcodeNo,
      'productName': productName,
      'category': category,
      'unitPrice': unitPrice,
      'taxRate': taxRate,
      'price': price,
      'stockInfo': stockInfo,
    };
  }

  /// Helper method to calculate price from unit price and tax rate
  ///
  /// Formula: price = unitPrice * (1 + taxRate/100)
  static double calculatePrice(double unitPrice, int taxRate) {
    return unitPrice * (1 + taxRate / 100);
  }

  /// Create a copy of this Product with modified fields
  ///
  /// This is useful for updating products while maintaining immutability
  Product copyWith({
    String? barcodeNo,
    String? productName,
    String? category,
    double? unitPrice,
    int? taxRate,
    double? price,
    int? stockInfo,
  }) {
    return Product(
      barcodeNo: barcodeNo ?? this.barcodeNo,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      price: price ?? this.price,
      stockInfo: stockInfo ?? this.stockInfo,
    );
  }

  @override
  String toString() {
    return 'Product(barcodeNo: $barcodeNo, productName: $productName, '
        'category: $category, unitPrice: $unitPrice, taxRate: $taxRate%, '
        'price: $price, stockInfo: $stockInfo)';
  }
}
