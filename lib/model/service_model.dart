import 'calificacion_model.dart';

class ServiceModel {
  String id;
  String name;
  String description;
  String category;
  String schedule;
  List<String> availableDays;
  List<String> images;
  int price;
  double ratingAvg;
  int ratingCount;
  bool state;
  List<CalificacionModel> calificaciones = [];

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.schedule,
    required this.availableDays,
    required this.images,
    required this.price,
    required this.ratingAvg,
    required this.ratingCount,
    required this.state,
    required this.calificaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'schedule': schedule,
      'availableDays': availableDays,
      'images': images,
      'price': price,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'state': state,
      'calificaciones': calificaciones.map((e) => e.toMap()).toList(),
    };
  }
}
