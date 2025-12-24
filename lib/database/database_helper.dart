import 'package:hw04/models/product.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// [DatabaseHelper] Singleton class for managing SQLite database operations
///
/// This class handles all CRUD operations for the Product table
/// and ensures only one instance of the database exists throughout the app.
class DatabaseHelper {
  /// Factory constructor returns the singleton instance
  factory DatabaseHelper() => _instance;

  /// Private constructor for singleton pattern
  DatabaseHelper._internal();

  /// Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  /// Database instance
  static Database? _database;

  /// Table name in the database
  static const String tableName = 'products';

  /// Get the database instance, creating it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  ///
  /// Creates the database file and the products table
  Future<Database> _initDatabase() async {
    // Get the database path
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'products.db');

    // Open/create the database
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create the products table
  ///
  /// This is called when the database is created for the first time
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        barcodeNo TEXT PRIMARY KEY,
        productName TEXT NOT NULL,
        category TEXT NOT NULL,
        unitPrice REAL NOT NULL,
        taxRate INTEGER NOT NULL,
        price REAL NOT NULL,
        stockInfo INTEGER
      )
    ''');
  }

  /// Insert a new product into the database
  ///
  /// Throws an exception if a product with the same barcode already exists
  /// Returns the barcode of the inserted product
  Future<String> insertProduct(Product product) async {
    final db = await database;

    // Check if product with same barcode already exists
    final existingProduct = await getProductByBarcode(product.barcodeNo);
    if (existingProduct != null) {
      throw Exception(
        'Product with barcode ${product.barcodeNo} already exists',
      );
    }

    await db.insert(
      tableName,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return product.barcodeNo;
  }

  /// Get all products from the database
  ///
  /// Returns a list of all products ordered by product name
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'productName ASC',
    );

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  /// Get a product by its barcode
  ///
  /// Returns the product if found, null otherwise
  Future<Product?> getProductByBarcode(String barcodeNo) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'barcodeNo = ?',
      whereArgs: [barcodeNo],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Product.fromMap(maps.first);
  }

  /// Update an existing product
  ///
  /// Returns the number of rows affected (should be 1 if successful)
  /// Note: Barcode cannot be changed (it's the primary key)
  Future<int> updateProduct(Product product) async {
    final db = await database;
    final result = await db.update(
      tableName,
      product.toMap(),
      where: 'barcodeNo = ?',
      whereArgs: [product.barcodeNo],
    );

    return result;
  }

  /// Delete a product by its barcode
  ///
  /// Returns the number of rows deleted (should be 1 if successful)
  Future<int> deleteProduct(String barcodeNo) async {
    final db = await database;
    final result = await db.delete(
      tableName,
      where: 'barcodeNo = ?',
      whereArgs: [barcodeNo],
    );

    return result;
  }

  /// Close the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete all products from the database (for testing purposes)
  Future<void> deleteAllProducts() async {
    final db = await database;
    await db.delete(tableName);
  }

  /// Get the count of products in the database
  Future<int> getProductCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );

    return count ?? 0;
  }
}
