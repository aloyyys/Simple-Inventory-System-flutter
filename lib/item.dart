class Item {
  int? id;
  String name;
  int quantity;

  Item(this.name, this.quantity, {this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(map['name'], map['quantity'], id: map['id']);
  }
}
