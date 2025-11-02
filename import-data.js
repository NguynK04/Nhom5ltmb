const admin = require('firebase-admin');
const fs = require('fs');

// Khởi tạo Firebase Admin
const serviceAccount = require('./serviceAccountKey.json'); // Bạn cần tải file này từ Firebase Console

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function importData() {
  try {
    // Đọc file JSON
    const data = JSON.parse(fs.readFileSync('./sample_data.json', 'utf8'));
    
    console.log('🚀 Bắt đầu import dữ liệu...');
    
    // Import categories
    console.log('📂 Import categories...');
    const categoryIds = {};
    
    for (let i = 0; i < data.categories.length; i++) {
      const category = data.categories[i];
      const docRef = await db.collection('categories').add({
        ...category,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      categoryIds[category.name] = docRef.id;
      console.log(`✅ Category: ${category.name} - ${docRef.id}`);
    }
    
    // Import products
    console.log('🍽️ Import products...');
    
    for (let i = 0; i < data.products.length; i++) {
      const product = data.products[i];
      const categoryId = categoryIds[product.categoryName];
      
      if (categoryId) {
        const docRef = await db.collection('products').add({
          ...product,
          categoryId: categoryId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        
        console.log(`✅ Product: ${product.name} - ${docRef.id}`);
      }
    }
    
    console.log('🎉 HOÀN THÀNH! Import dữ liệu thành công!');
    console.log(`📊 Đã import: ${data.categories.length} categories, ${data.products.length} products`);
    
  } catch (error) {
    console.error('❌ Lỗi:', error);
  }
}

importData();