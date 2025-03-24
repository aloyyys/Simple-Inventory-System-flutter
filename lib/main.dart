import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

class Item {
  String name;
  int quantity;

  Item(this.name, this.quantity);

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
  };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(json['name'], json['quantity']);
  }
}

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<Item> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedItems = prefs.getStringList('inventory');
    if (storedItems != null) {
      setState(() {
        _items.addAll(storedItems.map((e) => Item.fromJson(jsonDecode(e))));
      });
    }
  }

  Future<void> _saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedItems = _items.map((e) => jsonEncode(e.toJson())).toList();
    prefs.setStringList('inventory', storedItems);
  }

  void _addItem() {
    setState(() {
      _items.add(Item(_nameController.text, int.parse(_quantityController.text)));
      _nameController.clear();
      _quantityController.clear();
    });
    _saveItems();
  }

  void _editItem(int index) {
    _nameController.text = _items[index].name;
    _quantityController.text = _items[index].quantity.toString();
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
              onPressed: () {
                setState(() {
                  _items[index].name = _nameController.text;
                  _items[index].quantity = int.parse(_quantityController.text);
                });
                _saveItems();
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            )
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _saveItems();
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
                  onEdit: () => _editItem(index),
                  onDelete: () => _deleteItem(index),
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
