class Store {
  final int id;
  final String name;
  final String? ownerName;
  final String? phone;
  final String? address;
  final String? area;
  final double? lat;
  final double? lng;

  Store({
    required this.id,
    required this.name,
    this.ownerName,
    this.phone,
    this.address,
    this.area,
    this.lat,
    this.lng,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      ownerName: json['owner_name'],
      phone: json['phone'],
      address: json['address'],
      area: json['area'],
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_name': ownerName,
      'phone': phone,
      'address': address,
      'area': area,
      'lat': lat,
      'lng': lng,
    };
  }
}
