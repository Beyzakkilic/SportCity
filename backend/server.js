const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const app = express();

app.use(cors());
app.use(express.json());

const dataFilePath = path.join(__dirname, 'products.json');
const categoriesFilePath = path.join(__dirname, 'categories.json');

// Kategorileri dosyadan oku
function loadCategories() {
  try {
    if (fs.existsSync(categoriesFilePath)) {
      const data = fs.readFileSync(categoriesFilePath, 'utf8');
      return JSON.parse(data);
    }
    return ['Ayakkabı', 'Giyim', 'Ekipman'];
  } catch (error) {
    console.error('Kategori okuma hatası:', error);
    return ['Ayakkabı', 'Giyim', 'Ekipman'];
  }
}

// Kategorileri dosyaya kaydet
function saveCategories(categories) {
  try {
    fs.writeFileSync(categoriesFilePath, JSON.stringify(categories, null, 2));
  } catch (error) {
    console.error('Kategori yazma hatası:', error);
  }
}

// İlk çalıştırmada örnek kategoriler
let categories = loadCategories();

// Verileri dosyadan oku
function loadProducts() {
  try {
    if (fs.existsSync(dataFilePath)) {
      const data = fs.readFileSync(dataFilePath, 'utf8');
      return JSON.parse(data);
    }
    return [];
  } catch (error) {
    console.error('Veri okuma hatası:', error);
    return [];
  }
}

// Verileri dosyaya kaydet
function saveProducts(products) {
  try {
    fs.writeFileSync(dataFilePath, JSON.stringify(products, null, 2));
  } catch (error) {
    console.error('Veri yazma hatası:', error);
  }
}

// İlk çalıştırmada örnek veriler
let products = loadProducts();
if (products.length === 0) {
  products = [
    {
      id: '1',
      name: 'Nike Air Max',
      description: 'Spor Ayakkabı, Siyah/Beyaz',
      price: '4.999 TL',
      category: 'Ayakkabı',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=500&q=80'
    },
    {
      id: '2',
      name: 'Adidas Tiro Eşofman',
      description: 'Erkek Eşofman Takımı',
      price: '2.499 TL',
      category: 'Giyim',
      imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=500&q=80'
    },
    {
      id: '3',
      name: 'Under Armour T-Shirt',
      description: 'Nefes Alabilir Kumaş',
      price: '899 TL',
      category: 'Giyim',
      imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=500&q=80'
    },
    {
      id: '4',
      name: 'Wilson Basketbol Topu',
      description: 'NBA Resmi Maç Topu',
      price: '1.999 TL',
      category: 'Ekipman',
      imageUrl: 'https://images.unsplash.com/photo-1519861155730-0b5fbf0dd889?auto=format&fit=crop&w=500&q=80'
    },
    {
      id: '5',
      name: 'Puma Futbol Topu',
      description: 'FIFA Onaylı Maç Topu',
      price: '1.499 TL',
      category: 'Ekipman',
      imageUrl: 'https://images.unsplash.com/photo-1614632537190-23e4146777db?auto=format&fit=crop&w=500&q=80'
    },
    {
      id: '6',
      name: 'Nike Pro Şort',
      description: 'Erkek Spor Şortu',
      price: '699 TL',
      category: 'Giyim',
      imageUrl: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&w=500&q=80'
    }
  ];
  saveProducts(products);
}

// Ana sayfa
app.get('/', (req, res) => {
  res.json({
    message: 'Sport City API',
    endpoints: {
      getAllProducts: '/products',
      getProductsByCategory: '/products/category/:category',
      searchProducts: '/products/search?q=query',
      getProductDetails: '/products/:id'
    }
  });
});

// Tüm ürünleri getir
app.get('/products', (req, res) => {
  res.json(products);
});

// Kategoriye göre ürünleri getir
app.get('/products/category/:category', (req, res) => {
  const category = req.params.category;
  const filteredProducts = products.filter(product => 
    product.category.toLowerCase() === category.toLowerCase()
  );
  res.json(filteredProducts);
});

// Ürün ara
app.get('/products/search', (req, res) => {
  const query = req.query.q ? req.query.q.toLowerCase() : '';
  const searchResults = products.filter(product => 
    product.name.toLowerCase().includes(query) ||
    product.description.toLowerCase().includes(query) ||
    product.category.toLowerCase().includes(query)
  );
  res.json(searchResults);
});

// Tek bir ürünün detaylarını getir
app.get('/products/:id', (req, res) => {
  const product = products.find(p => p.id === req.params.id);
  if (product) {
    res.json(product);
  } else {
    res.status(404).json({ message: 'Ürün bulunamadı' });
  }
});

// Ürün güncelle
app.put('/products/:id', (req, res) => {
  const productId = req.params.id;
  const updatedProduct = req.body;
  
  const index = products.findIndex(p => p.id === productId);
  if (index !== -1) {
    products[index] = { ...products[index], ...updatedProduct };
    saveProducts(products); // Değişiklikleri kaydet
    res.json(products[index]);
  } else {
    res.status(404).json({ message: 'Ürün bulunamadı' });
  }
});

// Yeni ürün ekleme
app.post('/products', (req, res) => {
  const newProduct = {
    id: (products.length + 1).toString(),
    name: req.body.name,
    description: req.body.description,
    price: req.body.price,
    category: req.body.category,
    imageUrl: req.body.imageUrl,
  };

  products.push(newProduct);
  saveProducts(products); // Değişiklikleri kaydet
  res.status(201).json(newProduct);
});

// Ürün silme
app.delete('/products/:id', (req, res) => {
  const productId = req.params.id;
  const index = products.findIndex(p => p.id === productId);
  
  if (index !== -1) {
    products.splice(index, 1);
    saveProducts(products); // Değişiklikleri kaydet
    res.json({ message: 'Ürün başarıyla silindi' });
  } else {
    res.status(404).json({ message: 'Ürün bulunamadı' });
  }
});

// Tüm kategorileri getir
app.get('/categories', (req, res) => {
  res.json(categories);
});

// Yeni kategori ekle
app.post('/categories', (req, res) => {
  const newCategory = req.body.name;
  if (!categories.includes(newCategory)) {
    categories.push(newCategory);
    saveCategories(categories);
    res.status(201).json({ message: 'Kategori başarıyla eklendi' });
  } else {
    res.status(400).json({ message: 'Bu kategori zaten mevcut' });
  }
});

// Kategori güncelle
app.put('/categories/:oldCategory', (req, res) => {
  const oldCategory = req.params.oldCategory;
  const newCategory = req.body.name;
  const index = categories.indexOf(oldCategory);
  
  if (index !== -1) {
    categories[index] = newCategory;
    
    // İlgili ürünlerin kategorilerini de güncelle
    products.forEach(product => {
      if (product.category === oldCategory) {
        product.category = newCategory;
      }
    });
    
    saveCategories(categories);
    saveProducts(products);
    res.json({ message: 'Kategori başarıyla güncellendi' });
  } else {
    res.status(404).json({ message: 'Kategori bulunamadı' });
  }
});

// Kategori sil
app.delete('/categories/:category', (req, res) => {
  const categoryToDelete = req.params.category;
  const index = categories.indexOf(categoryToDelete);
  
  if (index !== -1) {
    categories.splice(index, 1);
    
    // İlgili kategorideki ürünleri de sil
    products = products.filter(product => product.category !== categoryToDelete);
    
    saveCategories(categories);
    saveProducts(products);
    res.json({ message: 'Kategori başarıyla silindi' });
  } else {
    res.status(404).json({ message: 'Kategori bulunamadı' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
}); 