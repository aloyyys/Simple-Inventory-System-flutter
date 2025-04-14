# inventory_system

A Simple Inventory System App built with Flutter that allows users to Create, Read, Update, and Delete (CRUD) inventory items. It features a user-friendly interface with persistent data storage using database with sqflite, ensuring inventory lists remain saved even after closing the app.

[Video Demo Aplikasi](https://youtu.be/9x9UZ_1O154)

<img src="https://github.com/user-attachments/assets/5c610535-97ce-4acb-a4f7-c4c2227377dd" alt="Alt Text" width="486" height="1080">

<img src="https://github.com/user-attachments/assets/59d44656-1c31-449a-9f44-2969d3958d24" alt="Alt Text" width="486" height="1080">

## Update Using from sharedpreferences into Sqflite database
1. run "flutter pub add sqflite" di terminal, dan akan secara otomatis membuat pubspec.yaml
2. item.dart berfungsi untuk Mewakili struktur data dari satu item dalam inventory. Digunakan untuk mempermudah proses
   - konversi antara objek Dart dan data dari database (Map)
   - embuat sistem CRUD yang rapi dan terstruktur
3. database_helper.dart berisi semua fungsi untuk akses database sqflite seperti
   - Membuat database dan tabel
   - Menyimpan data (insert)
   - Mengambil data (getItems)
   - Memperbarui data (update)
   - Menghapus data (delete)
  
   kode ini berfungsi sebagai memastikan hanya satu instance dari class ini digunakan
   ```
   static final DatabaseHelper instance = DatabaseHelper._internal();
   factory DatabaseHelper() => instance;
   ```


   inisialisasi database dengan 
   ```
   Future<Database> _initDB() async {
   final path = join(await getDatabasesPath(), 'inventory.db');
   return await openDatabase(
     path,
     version: 1,
     onCreate: (db, version) {
       return db.execute('''
         CREATE TABLE items (
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           name TEXT,
           quantity INTEGER
          )
        ''');
      },
    );
   }
   ```
   - untuk menentukan path dimana penyimpanan database dan membuat tabel jika belum ada

   penyimpanan data dengan mengonversi Item jadi Map dan simpan ke tabel items
   ```
   Future<void> insertItem(Item item) async {
   final db = await database;
   await db.insert('items', item.toMap());
   }
   ```

   mengambil semua data dari database dan mengubah setiap Map menjadi Item dan kembalikan dalam bentuk 'List<item>'
   ```
   Future<List<Item>> getItems() async {
   final db = await database;
   final result = await db.query('items');
   return result.map((e) => Item.fromMap(e)).toList();
   }
   ```

   mengedit data dengan mengupdate record yang memiliki id yang sesuai
   ```
   Future<void> updateItem(Item item) async {
   final db = await database;
   await db.update(
     'items',
     item.toMap(),
     where: 'id = ?',
     whereArgs: [item.id],
    );
   }
   ```

   menghapus data dengan hapus item berdasarkan id
   ```
   Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
     );
   }
   ```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
