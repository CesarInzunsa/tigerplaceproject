import 'calificacion_model.dart';

class ProductModel {
  String id;
  String name;
  String description;
  String category;
  List<String> images;
  int price;
  double ratingAvg;
  int ratingCount;
  bool state;
  List<CalificacionModel> calificaciones;

  ProductModel({
    this.id = '',
    required this.name,
    required this.description,
    required this.category,
    required this.images,
    required this.price,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    required this.state,
    required this.calificaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'images': images,
      'price': price,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'state': state,
      'calificaciones': calificaciones.map((e) => e.toMap()).toList(),
    };
  }
}
