import 'package:flutter/material.dart';
import 'dart:convert';
import 'database_helper.dart';
import 'item.dart';

void main() {
  runApp(InventoryApp());
}

class InventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InventoryScreen(),
    );
  }
}

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Item> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await DatabaseHelper.instance.getItems();
    setState(() {
      _items = items;
    });
  }

  void _addItem() async {
    final item = Item(_nameController.text, int.parse(_quantityController.text));
    await DatabaseHelper.instance.insertItem(item);
    _nameController.clear();
    _quantityController.clear();
    _loadItems();
  }

  void _editItem(Item item) async {
    _nameController.text = item.name;
    _quantityController.text = item.quantity.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Item Name')),
              TextField(controller: _quantityController, decoration: InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                item.name = _nameController.text;
                item.quantity = int.parse(_quantityController.text);
                await DatabaseHelper.instance.updateItem(item);
                Navigator.of(context).pop();
                _loadItems();
              },
              child: Text("Save"),
            )
          ],
        );
      },
    );
  }

  void _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
    _loadItems();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventory System')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
          ),
          ElevatedButton(onPressed: _addItem, child: Text("Add Item")),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ItemCard(
                  item: _items[index],
                  onEdit: () => _editItem(_items[index]),
                  onDelete: () => _deleteItem(_items[index].id!),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ItemCard({required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('Quantity: ${item.quantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
