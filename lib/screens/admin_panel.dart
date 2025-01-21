import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/api.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminPanelScreen extends StatefulWidget {
  final VoidCallback onProductUpdated;
  final VoidCallback onCategoryUpdated;
  const AdminPanelScreen({
    Key? key,
    required this.onProductUpdated,
    required this.onCategoryUpdated,
  }) : super(key: key);

  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _products = [];
  List<String> _categories = [];
  bool _isLoading = true;
  int _selectedIndex = 0; // 0: Ürünler, 1: Kategoriler

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadProducts() async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürünler yüklenirken hata oluştu: $e')),
        );
      }
    }
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

  void _addProduct() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    String selectedCategory = 'Ayakkabı';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Ürün Ekle'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ürün Adı',
                      icon: Icon(CupertinoIcons.tag),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      icon: Icon(CupertinoIcons.text_alignleft),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Fiyat',
                      icon: Icon(CupertinoIcons.money_dollar),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.square_grid_2x2),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          hint: const Text('Kategori Seçin'),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Resim URL',
                      icon: Icon(CupertinoIcons.photo),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final newProduct = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': priceController.text,
                  'category': selectedCategory,
                  'imageUrl': imageUrlController.text,
                };
                
                await _apiService.addProduct(newProduct);
                await _loadProducts();
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ürün başarıyla eklendi')),
                  );
                  widget.onProductUpdated();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata oluştu: $e')),
                  );
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _editProduct(Map<String, dynamic> product) {
    final nameController = TextEditingController(text: product['name']);
    final descriptionController = TextEditingController(text: product['description']);
    final priceController = TextEditingController(text: product['price']);
    final imageUrlController = TextEditingController(text: product['imageUrl']);
    String selectedCategory = product['category'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Düzenle'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ürün Adı',
                      icon: Icon(CupertinoIcons.tag),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      icon: Icon(CupertinoIcons.text_alignleft),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Fiyat',
                      icon: Icon(CupertinoIcons.money_dollar),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.square_grid_2x2),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          hint: const Text('Kategori Seçin'),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Resim URL',
                      icon: Icon(CupertinoIcons.photo),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updatedProduct = {
                  'id': product['id'],
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': priceController.text,
                  'category': selectedCategory,
                  'imageUrl': imageUrlController.text,
                };
                
                await _apiService.updateProduct(product['id'], updatedProduct);
                await _loadProducts();
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ürün başarıyla güncellendi')),
                  );
                  widget.onProductUpdated();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata oluştu: $e')),
                  );
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content: const Text('Bu ürünü silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _apiService.deleteProduct(productId);
                await _loadProducts();
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ürün başarıyla silindi')),
                  );
                  widget.onProductUpdated();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata oluştu: $e')),
                  );
                }
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addCategory() {
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kategori Ekle'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(
            labelText: 'Kategori Adı',
            icon: Icon(CupertinoIcons.tag),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (categoryController.text.isNotEmpty) {
                try {
                  await _apiService.addCategory(categoryController.text);
                  await _loadCategories();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kategori başarıyla eklendi')),
                    );
                    widget.onCategoryUpdated();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata oluştu: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _editCategory(String category, int index) {
    final categoryController = TextEditingController(text: category);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategoriyi Düzenle'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(
            labelText: 'Kategori Adı',
            icon: Icon(CupertinoIcons.tag),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (categoryController.text.isNotEmpty) {
                try {
                  await _apiService.updateCategory(category, categoryController.text);
                  await _loadCategories();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kategori başarıyla güncellendi')),
                    );
                    widget.onCategoryUpdated();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata oluştu: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int index) {
    final category = _categories[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategoriyi Sil'),
        content: const Text('Bu kategoriyi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _apiService.deleteCategory(category);
                await _loadCategories();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kategori başarıyla silindi')),
                  );
                  widget.onCategoryUpdated();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata oluştu: $e')),
                  );
                }
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product['imageUrl'] != null
                  ? CachedNetworkImage(
                      imageUrl: product['imageUrl'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(CupertinoIcons.photo),
                    )
                  : const Icon(CupertinoIcons.photo),
              ),
            ),
            title: Text(product['name'] ?? ''),
            subtitle: Text(
              '${product['price']} - ${product['category']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.pencil),
                  onPressed: () => _editProduct(product),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.delete),
                  onPressed: () => _deleteProduct(product['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(CupertinoIcons.tag),
                  title: Text(category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.pencil),
                        onPressed: () => _editCategory(category, index),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.delete),
                        onPressed: () => _deleteCategory(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _addCategory,
            icon: const Icon(CupertinoIcons.add),
            label: const Text('Yeni Kategori Ekle'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Ürün Yönetimi' : 'Kategori Yönetimi'),
        backgroundColor: isDarkMode ? const Color(0xFF1A237E) : const Color(0xFF1E88E5),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.square_arrow_right),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _selectedIndex = 0),
                    icon: const Icon(CupertinoIcons.cube_box),
                    label: const Text('Ürünler'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndex == 0
                          ? (isDarkMode ? const Color(0xFF1A237E) : const Color(0xFF1E88E5))
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _selectedIndex = 1),
                    icon: const Icon(CupertinoIcons.tag),
                    label: const Text('Kategoriler'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndex == 1
                          ? (isDarkMode ? const Color(0xFF1A237E) : const Color(0xFF1E88E5))
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 0 ? _buildProductList() : _buildCategoryList(),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addProduct,
              backgroundColor: isDarkMode ? const Color(0xFF1A237E) : const Color(0xFF1E88E5),
              child: const Icon(CupertinoIcons.add),
            )
          : null,
    );
  }
} 