# Hướng dẫn tạo tài khoản Admin thủ công

## 🔐 Tại sao tạo Admin thủ công?

Vì tài khoản Admin có quyền cao nhất trong hệ thống, việc tạo tài khoản Admin được thực hiện thủ công qua cơ sở dữ liệu để đảm bảo bảo mật cao nhất.

## 📋 Bước 1: Tạo tài khoản Firebase Authentication

### Cách 1: Sử dụng Firebase Console
1. **Truy cập Firebase Console**: https://console.firebase.google.com
2. **Chọn project** Korderr
3. **Vào Authentication** > **Users**
4. **Nhấn "Add user"**
5. **Điền thông tin:**
   - Email: admin@korderr.com (hoặc email thật)
   - Password: tạo mật khẩu mạnh
6. **Lưu User ID** được tạo (ví dụ: `abc123xyz789`)

### Cách 2: Sử dụng Firebase Admin SDK
```javascript
// Node.js script
const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./path/to/serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Create admin user
async function createAdminUser() {
  try {
    const userRecord = await admin.auth().createUser({
      email: 'admin@korderr.com',
      password: 'YourStrongPassword123!',
      displayName: 'System Administrator'
    });
    
    console.log('Successfully created admin user:', userRecord.uid);
    return userRecord.uid;
  } catch (error) {
    console.log('Error creating admin user:', error);
  }
}

createAdminUser();
```

## 📋 Bước 2: Tạo document trong Firestore

### Sử dụng Firebase Console:
1. **Vào Firestore Database** > **Data**
2. **Vào collection "users"**
3. **Nhấn "Add document"**
4. **Document ID**: Sử dụng User ID từ bước 1
5. **Fields**:
   ```
   avatar: [string] null
   createdAt: [timestamp] <current time>
   email: [string] admin@korderr.com
   fullName: [string] System Administrator
   isActive: [boolean] true
   phone: [string] +84901234567
   role: [string] admin
   updatedAt: [timestamp] <current time>
   ```

### Sử dụng code:
```javascript
// Tiếp tục script trên
async function createAdminDocument(uid) {
  try {
    await admin.firestore().collection('users').doc(uid).set({
      email: 'admin@korderr.com',
      fullName: 'System Administrator',
      phone: '+84901234567',
      role: 'admin',
      isActive: true,
      avatar: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('Successfully created admin document');
  } catch (error) {
    console.log('Error creating admin document:', error);
  }
}
```

## 📋 Bước 3: Kiểm tra tài khoản

### Test đăng nhập:
1. **Mở ứng dụng Korderr**
2. **Đăng nhập** với email và password đã tạo
3. **Kiểm tra** có vào được Admin Dashboard không
4. **Xác nhận role** hiển thị đúng "Admin"

### Kiểm tra quyền:
- ✅ Truy cập Staff Management
- ✅ Truy cập Password Management  
- ✅ Truy cập tất cả chức năng admin
- ✅ Tạo/sửa/xóa staff accounts
- ✅ Xem thống kê dashboard

## 🔧 Template tạo nhanh

### Script hoàn chỉnh:
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function createCompleteAdminAccount() {
  const adminData = {
    email: 'admin@korderr.com',
    password: 'Admin123!@#',
    displayName: 'System Administrator',
    fullName: 'System Administrator',
    phone: '+84901234567'
  };

  try {
    // 1. Create Firebase Auth user
    const userRecord = await admin.auth().createUser({
      email: adminData.email,
      password: adminData.password,
      displayName: adminData.displayName
    });

    console.log('✅ Created Firebase Auth user:', userRecord.uid);

    // 2. Create Firestore document
    await admin.firestore().collection('users').doc(userRecord.uid).set({
      email: adminData.email,
      fullName: adminData.fullName,
      phone: adminData.phone,
      role: 'admin',
      isActive: true,
      avatar: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log('✅ Created Firestore document');
    console.log('🎉 Admin account created successfully!');
    console.log('📧 Email:', adminData.email);
    console.log('🔑 Password:', adminData.password);
    console.log('🆔 UID:', userRecord.uid);

  } catch (error) {
    console.error('❌ Error:', error);
  }
}

createCompleteAdminAccount();
```

## 🛡️ Bảo mật

### Best Practices:
- **Sử dụng mật khẩu mạnh** (tối thiểu 12 ký tự, có chữ hoa, số, ký tự đặc biệt)
- **Email thật** để có thể reset password
- **Số điện thoại thật** để liên hệ
- **.Backup thông tin** đăng nhập an toàn
- **Đổi mật khẩu định kỳ**

### Lưu ý:
- Chỉ tạo **TỐI ĐA 2-3 tài khoản Admin**
- **Không share** thông tin đăng nhập admin
- **Monitor hoạt động** của admin account
- **Deactivate** admin không còn sử dụng

## 📱 Sau khi tạo xong

1. **Test đăng nhập** ngay lập tức
2. **Đổi password** từ ứng dụng (Settings > Password Management)
3. **Cập nhật thông tin** cá nhân nếu cần
4. **Tạo staff accounts** cho nhân viên
5. **Backup thông tin** đăng nhập

---

**⚠️ QUAN TRỌNG**: Lưu giữ thông tin đăng nhập admin ở nơi an toàn và chỉ chia sẻ với người có thẩm quyền!