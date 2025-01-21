import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';
import 'admin_login.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = false;
  String? eposta;
  String? sifre;
  int _selectedIndex = 0;
  Set<String> _selectedCategories = {};
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _cartItems = [];
  final ApiService _apiService = ApiService();
  List<String> _categories = [];

  List<Map<String, dynamic>> get filteredProducts {
    if (_selectedCategories.isEmpty) {
      return _products;
    }
    return _products.where((product) => 
      _selectedCategories.contains(product['category'])
    ).toList();
  }

  List<Map<String, dynamic>> get searchResults {
    if (_searchQuery.isEmpty) {
      return _products;
    }
    return _products.where((product) {
      final name = product['name'].toString().toLowerCase();
      final description = product['description'].toString().toLowerCase();
      final category = product['category'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return name.contains(query) || 
             description.contains(query) || 
             category.contains(query);
    }).toList();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürünler yüklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _loadProductsByCategory(String category) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _apiService.getProductsByCategory(category);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kategori ürünleri yüklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      _loadProducts();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _apiService.searchProducts(query);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arama yapılırken hata oluştu: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadUserData();
    _loadCategories();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      eposta = prefs.getString('eposta');
      sifre = prefs.getString('sifre');
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategoriler yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  void ClearPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final isDarkMode = preferences.getBool('isDarkMode') ?? false;
    await preferences.remove('eposta');
    await preferences.remove('sifre');
    await preferences.setBool('isDarkMode', isDarkMode);
    context.go("/login");
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _cartItems.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} sepete eklendi')),
    );
  }

  void _navigateToAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminLoginScreen(
          onProductUpdated: () {
            setState(() {
              _loadProducts();
            });
          },
          onCategoryUpdated: () {
            setState(() {
              _loadCategories();
            });
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategoriler
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Kategoriler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategories.contains(category);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(category),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    backgroundColor: Colors.grey[200],
                    selectedColor: _isDarkMode ? const Color(0xFF1A237E) : const Color(0xFF1E88E5),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                          _loadProductsByCategory(category);
                        } else {
                          _selectedCategories.remove(category);
                          if (_selectedCategories.isEmpty) {
                            _loadProducts();
                          }
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Öne Çıkan Ürünler
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Öne Çıkan Ürünler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                if (_selectedCategories.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategories.clear();
                        _loadProducts();
                      });
                    },
                    child: const Text('Filtreyi Temizle'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  elevation: 2,
                  color: _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _isDarkMode ? const Color(0xFF1A237E) : const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product['imageUrl'] != null
                                ? CachedNetworkImage(
                                    imageUrl: product['imageUrl'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        color: _isDarkMode ? Colors.white70 : Colors.blue,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Center(
                                      child: Icon(
                                        CupertinoIcons.photo,
                                        size: 40,
                                        color: _isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      CupertinoIcons.photo,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product['name'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode ? Colors.white : const Color(0xFF2962FF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['description'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isDarkMode ? Colors.white70 : const Color(0xFF757575),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product['price'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isDarkMode ? Colors.white : const Color(0xFF1E88E5),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.cart_badge_plus,
                                color: _isDarkMode ? Colors.white : const Color(0xFF1E88E5),
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _addToCart(product),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _searchProducts(value);
              });
            },
            decoration: InputDecoration(
              hintText: 'Ürün ara...',
              hintStyle: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.black54,
              ),
              prefixIcon: Icon(
                CupertinoIcons.search,
                color: _isDarkMode ? Colors.white70 : Colors.black54,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isDarkMode ? Colors.white24 : Colors.black12,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isDarkMode ? Colors.white24 : Colors.black12,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isDarkMode ? Colors.white : Colors.blue,
                ),
              ),
              filled: true,
              fillColor: _isDarkMode ? Colors.grey[850] : Colors.grey[200],
            ),
          ),
        ),
        if (_isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else
          Expanded(
            child: searchResults.isEmpty
                ? Center(
                    child: Text(
                      'Ürün bulunamadı',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final product = searchResults[index];
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product['imageUrl'] != null
                                ? Image.network(
                                    product['imageUrl'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    alignment: Alignment.center,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          CupertinoIcons.photo,
                                          size: 24,
                                          color: _isDarkMode ? Colors.white : Colors.black,
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(
                                      CupertinoIcons.photo,
                                      size: 24,
                                      color: _isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                        title: Text(
                          product['name'] ?? '',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          product['description'] ?? '',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product['price'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.cart_badge_plus,
                                color: _isDarkMode ? Colors.white : Colors.black,
                              ),
                              onPressed: () => _addToCart(product),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }

  Widget _buildCartContent() {
    return _cartItems.isEmpty
        ? Center(
            child: Text(
              'Sepetiniz boş',
              style: TextStyle(
                fontSize: 18,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          )
        : ListView.builder(
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final product = _cartItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product['imageUrl'] != null
                        ? CachedNetworkImage(
                            imageUrl: product['imageUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: _isDarkMode ? Colors.white70 : Colors.blue,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              CupertinoIcons.photo,
                              color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                            ),
                          )
                        : Icon(
                            CupertinoIcons.photo,
                            color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                          ),
                    ),
                  ),
                  title: Text(
                    product['name'] ?? '',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    product['description'] ?? '',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  trailing: Text(
                    product['price'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? const Color(0xFF1E88E5) : Colors.blue,
                    ),
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sport City',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _isDarkMode ? const Color(0xFF1A237E) : const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bell, color: Colors.white),
            onPressed: _navigateToAdminLogin,
          ),
        ],
      ),
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      drawer: Drawer(
        elevation: 0,
        backgroundColor: _isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        child: Column(
          children: [
            Container(
              height: 200,
              color: _isDarkMode ? const Color(0xFF121212) : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isDarkMode ? Colors.white.withOpacity(0.5) : Colors.blue.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      CupertinoIcons.person_circle,
                      size: 80,
                      color: _isDarkMode ? Colors.white : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    eposta ?? "Kullanıcı",
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.settings,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
              title: Text(
                'Ayarlar',
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              ),
              onTap: () {
                context.go("/settings");
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.moon,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
              title: Text(
                'Karanlık Tema',
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              ),
              onTap: _toggleTheme,
            ),
            CustomSizedBox(560),
            ListTile(
              leading: Icon(
                CupertinoIcons.arrow_left_square,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
              title: Text(
                'Çıkış Yap',
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              ),
              onTap: () {
                ClearPref();
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          _buildSearchContent(),
          _buildCartContent(),
        ],
      ),
      bottomNavigationBar: Container(
        color: _isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                CupertinoIcons.home,
                color: _selectedIndex == 0 
                    ? (_isDarkMode ? Colors.white : Colors.blue)
                    : (_isDarkMode ? Colors.white54 : Colors.black54),
              ),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            IconButton(
              icon: Icon(
                CupertinoIcons.search,
                color: _selectedIndex == 1 
                    ? (_isDarkMode ? Colors.white : Colors.blue)
                    : (_isDarkMode ? Colors.white54 : Colors.black54),
              ),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            IconButton(
              icon: Icon(
                CupertinoIcons.cart,
                color: _selectedIndex == 2 
                    ? (_isDarkMode ? Colors.white : Colors.blue)
                    : (_isDarkMode ? Colors.white54 : Colors.black54),
              ),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}

Widget CustomSizedBox(double $deger) => SizedBox(
  height: $deger,
);
