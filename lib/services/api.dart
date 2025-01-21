import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://172.31.14.110:3000';

  // Tüm ürünleri getir
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'id': item['id'],
          'name': item['name'],
          'description': item['description'],
          'price': item['price'],
          'category': item['category'],
          'imageUrl': item['imageUrl'],
        }).toList();
      } else {
        throw Exception('Ürünler yüklenirken hata oluştu');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Kategoriye göre ürünleri getir
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?category=$category')
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'id': item['id'],
          'name': item['name'],
          'description': item['description'],
          'price': item['price'],
          'category': item['category'],
          'imageUrl': item['imageUrl'],
        }).toList();
      } else {
        throw Exception('Kategori ürünleri yüklenirken hata oluştu');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Ürün ara
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search?q=$query')
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'id': item['id'],
          'name': item['name'],
          'description': item['description'],
          'price': item['price'],
          'category': item['category'],
          'imageUrl': item['imageUrl'],
        }).toList();
      } else {
        throw Exception('Arama yapılırken hata oluştu');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Tek bir ürünün detaylarını getir
  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId')
      );
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return {
          'id': data['id'],
          'name': data['name'],
          'description': data['description'],
          'price': data['price'],
          'category': data['category'],
          'imageUrl': data['imageUrl'],
          'details': data['details'],
          'specifications': data['specifications'],
        };
      } else {
        throw Exception('Ürün detayları yüklenirken hata oluştu');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Ürün güncelle
  Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> updatedProduct) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedProduct),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Ürün güncellenirken hata oluştu');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ürün eklenirken hata oluştu');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Ürün sil
  Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Ürün silinirken hata oluştu');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Kategorileri getir
  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<String>.from(data);
      } else {
        throw Exception('Kategoriler yüklenirken hata oluştu');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Kategori ekle
  Future<void> addCategory(String category) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': category}),
      );
      
      if (response.statusCode != 201) {
        throw Exception('Kategori eklenirken hata oluştu');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Kategori güncelle
  Future<void> updateCategory(String oldCategory, String newCategory) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/categories/$oldCategory'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newCategory}),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Kategori güncellenirken hata oluştu');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Kategori sil
  Future<void> deleteCategory(String category) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$category'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Kategori silinirken hata oluştu');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
