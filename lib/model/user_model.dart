import 'product_model.dart';
import 'service_model.dart';

class UserModel {
  String id;
  String imgProfile;
  String userName;
  String email;
  String password;
  String name;
  String type;
  String location;
  List<ProductModel> products;
  List<ServiceModel> services;

  // Crear un constructor vacío
  UserModel.empty()
      : id = '',
        imgProfile = '',
        userName = '',
        email = '',
        password = '',
        name = '',
        type = '',
        location = '',
        products = [],
        services = [];

  UserModel.newUser({
    required this.name,
    required this.userName,
    required this.email,
    required this.password,
    required this.type,
  })  : id = '',
        imgProfile = '',
        location = '',
        products = [],
        services = [];

  UserModel({
    required this.id,
    this.imgProfile = '',
    required this.userName,
    required this.email,
    required this.password,
    required this.name,
    required this.type,
    required this.location,
    required this.products,
    required this.services,
  });

  /// Verificar si el usuario no tiene datos
  bool get isEmpty => id == '';
}
