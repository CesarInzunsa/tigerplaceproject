import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tigerplaceproject/controller/login_controller.dart';

import '../model/calificacion_model.dart';
import '../model/product_model.dart';
import '../model/service_model.dart';
import '../model/user_model.dart';

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class UserController {
  static FirebaseFirestore baseRemota = FirebaseFirestore.instance;
  static var carpetaRemota = FirebaseStorage.instance;

  Future<bool> isCurrentUser(String userId) async {
    User? user = LoginController.autenticar.currentUser;
    return user!.uid == userId;
  }

  Future<bool> rateProduct(
      String userId, String prodServId, int rating, String myId) async {
    try {
      // Buscar el documento del usuario que tiene el producto
      UserModel res = await getUserById(userId);

      // Filtrar el producto que se quiere calificar
      ProductModel product =
          res.products.firstWhere((element) => element.id == prodServId);

      // Filtrar la calificación del usuario actual
      CalificacionModel? calificacion = product.calificaciones
          .firstWhere((element) => element.usuarioId == myId, orElse: () {
        return CalificacionModel.empty();
      });

      // Si la calificación no existe, se crea una nueva
      if (calificacion.id == '') {
        calificacion = CalificacionModel(
          id: const Uuid().v4(),
          usuarioId: myId,
          puntuacion: rating,
        );
        product.calificaciones.add(calificacion);
      } else {
        // Si la calificación ya existe, se actualiza
        calificacion.puntuacion = rating;
      }

      // Actualizar la calificación promedio del producto
      product.ratingAvg = product.calificaciones
              .map((e) => e.puntuacion)
              .reduce((value, element) => value + element) /
          product.calificaciones.length;

      // Actualizar la cantidad de calificaciones del producto
      product.ratingCount = product.calificaciones.length;

      // Actualizar el documento del usuario con la nueva lista de productos
      await baseRemota.collection('users').doc(userId).update(
        {
          'products': [
            ...res.products.where((p) => p.id != prodServId),
            {
              'id': product.id,
              'name': product.name,
              'description': product.description,
              'category': product.category,
              'images': product.images,
              'price': product.price,
              'ratingAvg': product.ratingAvg,
              'ratingCount': product.ratingCount,
              'state': product.state,
              'calificaciones': [
                ...product.calificaciones
                    .map((calificacion) => calificacion.toMap())
              ],
            },
          ]
              .map((product) =>
                  product is ProductModel ? product.toMap() : product)
              .toList(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rateService(
      String userId, String prodServId, int rating, String myId) async {
    try {
      // Buscar el documento del usuario que tiene el producto
      UserModel res = await getUserById(userId);

      // Filtrar el producto que se quiere calificar
      ServiceModel service =
          res.services.firstWhere((element) => element.id == prodServId);

      // Filtrar la calificación del usuario actual
      CalificacionModel? calificacion = service.calificaciones
          .firstWhere((element) => element.usuarioId == myId, orElse: () {
        return CalificacionModel.empty();
      });

      // Si la calificación no existe, se crea una nueva
      if (calificacion.id == '') {
        calificacion = CalificacionModel(
          id: const Uuid().v4(),
          usuarioId: myId,
          puntuacion: rating,
        );
        service.calificaciones.add(calificacion);
      } else {
        // Si la calificación ya existe, se actualiza
        calificacion.puntuacion = rating;
      }

      // Actualizar la calificación promedio del producto
      service.ratingAvg = service.calificaciones
              .map((e) => e.puntuacion)
              .reduce((value, element) => value + element) /
          service.calificaciones.length;

      // Actualizar la cantidad de calificaciones del producto
      service.ratingCount = service.calificaciones.length;

      // Actualizar el documento del usuario con la nueva lista de productos
      await baseRemota.collection('users').doc(userId).update(
        {
          'services': [
            ...res.services.where((p) => p.id != prodServId),
            {
              'id': service.id,
              'name': service.name,
              'description': service.description,
              'category': service.category,
              'schedule': service.schedule,
              'availableDays': service.availableDays,
              'images': service.images,
              'price': service.price,
              'ratingAvg': service.ratingAvg,
              'ratingCount': service.ratingCount,
              'state': service.state,
              'calificaciones': [
                ...service.calificaciones
                    .map((calificacion) => calificacion.toMap())
              ],
            },
          ]
              .map((service) =>
                  service is ServiceModel ? service.toMap() : service)
              .toList(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changeLocation(String selectedLocation) async {
    try {
      User? user = LoginController.autenticar.currentUser;
      await baseRemota.collection('users').doc(user!.uid).update({
        'location': selectedLocation,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  String getMyProfileId() {
    User? user = LoginController.autenticar.currentUser;
    return user!.uid;
  }

  Future<UserModel> getMyProfileData() async {
    User? user = LoginController.autenticar.currentUser;
    return await getMyUser(user!.uid);
  }

  Future<bool> isEmailAlreadyInUse(String email) async {
    var consulta = await baseRemota
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase())
        .get();
    return consulta.docs.isNotEmpty;
  }

  Future<bool> isUserNameAlreadyInUse(String userName) async {
    var consulta = await baseRemota
        .collection('users')
        .where('userName', isEqualTo: userName.toLowerCase())
        .get();
    return consulta.docs.isNotEmpty;
  }

  Future<List<UserModel>> getUsers() async {
    List<UserModel> users = [];
    var consulta = await baseRemota.collection('users').get();

    for (var doc in consulta.docs) {
      Map<String, dynamic> data = doc.data();
      users.add(
        UserModel(
          id: doc.id,
          userName: data['userName'],
          email: data['email'],
          password: data['password'],
          name: data['name'],
          type: data['type'],
          location: data['location'],
          products: List<ProductModel>.from(
            data['products'].map(
              (product) => ProductModel(
                id: product['id'],
                name: product['name'],
                description: product['description'],
                category: product['category'],
                images: List<String>.from(product['images']),
                price: product['price'],
                ratingAvg:
                    product['ratingAvg'] == 0 ? 0.0 : product['ratingAvg'],
                ratingCount: product['ratingCount'],
                state: product['state'],
                calificaciones: product['calificaciones'] != null &&
                        product['calificaciones'].isNotEmpty
                    ? List<CalificacionModel>.from(
                        product['calificaciones'].map(
                          (calificacion) {
                            return CalificacionModel(
                              id: calificacion['id'],
                              usuarioId: calificacion['usuarioId'],
                              puntuacion: calificacion['puntuacion'],
                            );
                          },
                        ),
                      )
                    : [],
              ),
            ),
          ),
          services: List<ServiceModel>.from(
            data['services'].map(
              (service) => ServiceModel(
                id: service['id'],
                name: service['name'],
                description: service['description'],
                category: service['category'],
                schedule: service['schedule'],
                availableDays: List<String>.from(service['availableDays']),
                images: List<String>.from(service['images']),
                price: service['price'],
                ratingAvg:
                    service['ratingAvg'] == 0 ? 0.0 : service['ratingAvg'],
                ratingCount: service['ratingCount'],
                state: service['state'],
                calificaciones: service['calificaciones'] != null &&
                        service['calificaciones'].isNotEmpty
                    ? List<CalificacionModel>.from(
                        service['calificaciones'].map(
                          (calificacion) {
                            return CalificacionModel(
                              id: calificacion['id'],
                              usuarioId: calificacion['usuarioId'],
                              puntuacion: calificacion['puntuacion'],
                            );
                          },
                        ),
                      )
                    : [],
              ),
            ),
          ),
        ),
      );
    }

    return users;
  }

  Future<UserModel> getMyUser(String id) async {
    var doc = await baseRemota.collection('users').doc(id).get();

    if (!doc.exists) return UserModel.empty();

    Map<String, dynamic>? data = doc.data();
    return UserModel(
      id: doc.id,
      imgProfile: data?['imgProfile'],
      userName: data?['userName'],
      email: data?['email'],
      password: data?['password'],
      name: data?['name'],
      type: data?['type'],
      location: data?['location'],
      products: List<ProductModel>.from(
        data?['products'].map(
          (product) => ProductModel(
            id: product['id'],
            name: product['name'],
            description: product['description'],
            category: product['category'],
            images: List<String>.from(product['images']),
            price: product['price'],
            ratingAvg: product['ratingAvg'] == 0 ? 0.0 : product['ratingAvg'],
            ratingCount: product['ratingCount'],
            state: product['state'],
            calificaciones: product['calificaciones'] != null &&
                    product['calificaciones'].isNotEmpty
                ? List<CalificacionModel>.from(
                    product['calificaciones'].map(
                      (calificacion) {
                        return CalificacionModel(
                          id: calificacion['id'],
                          usuarioId: calificacion['usuarioId'],
                          puntuacion: calificacion['puntuacion'],
                        );
                      },
                    ),
                  )
                : [],
          ),
        ),
      ),
      services: List<ServiceModel>.from(
        data?['services'].map(
          (service) => ServiceModel(
            id: service['id'],
            name: service['name'],
            description: service['description'],
            category: service['category'],
            schedule: service['schedule'],
            availableDays: List<String>.from(service['availableDays']),
            images: List<String>.from(service['images']),
            price: service['price'],
            ratingAvg: service['ratingAvg'] == 0 ? 0.0 : service['ratingAvg'],
            ratingCount: service['ratingCount'],
            state: service['state'],
            calificaciones: service['calificaciones'] != null &&
                    service['calificaciones'].isNotEmpty
                ? List<CalificacionModel>.from(
                    service['calificaciones'].map(
                      (calificacion) {
                        return CalificacionModel(
                          id: calificacion['id'],
                          usuarioId: calificacion['usuarioId'],
                          puntuacion: calificacion['puntuacion'],
                        );
                      },
                    ),
                  )
                : [],
          ),
        ),
      ),
    );
  }

  Future<UserModel> getUserById(String id) async {
    var doc = await baseRemota.collection('users').doc(id).get();

    if (!doc.exists) return UserModel.empty();

    Map<String, dynamic>? data = doc.data();
    return UserModel(
      id: doc.id,
      imgProfile: data?['imgProfile'],
      userName: data?['userName'],
      email: data?['email'],
      password: data?['password'],
      name: data?['name'],
      type: data?['type'],
      location: data?['location'],
      products: List<ProductModel>.from(
        data?['products'].map(
          (product) => ProductModel(
            id: product['id'],
            name: product['name'],
            description: product['description'],
            category: product['category'],
            images: List<String>.from(product['images']),
            price: product['price'],
            ratingAvg: product['ratingAvg'] == 0 ? 0.0 : product['ratingAvg'],
            ratingCount: product['ratingCount'],
            state: product['state'],
            calificaciones: product['calificaciones'] != null &&
                    product['calificaciones'].isNotEmpty
                ? List<CalificacionModel>.from(
                    product['calificaciones'].map(
                      (calificacion) {
                        return CalificacionModel(
                          id: calificacion['id'],
                          usuarioId: calificacion['usuarioId'],
                          puntuacion: calificacion['puntuacion'],
                        );
                      },
                    ),
                  )
                : [],
          ),
        ),
      ),
      services: List<ServiceModel>.from(
        data?['services'].map(
          (service) => ServiceModel(
            id: service['id'],
            name: service['name'],
            description: service['description'],
            category: service['category'],
            schedule: service['schedule'],
            availableDays: List<String>.from(service['availableDays']),
            images: List<String>.from(service['images']),
            price: service['price'],
            ratingAvg: service['ratingAvg'] == 0 ? 0.0 : service['ratingAvg'],
            ratingCount: service['ratingCount'],
            state: service['state'],
            calificaciones: service['calificaciones'] != null &&
                    service['calificaciones'].isNotEmpty
                ? List<CalificacionModel>.from(
                    service['calificaciones'].map(
                      (calificacion) {
                        return CalificacionModel(
                          id: calificacion['id'],
                          usuarioId: calificacion['usuarioId'],
                          puntuacion: calificacion['puntuacion'],
                        );
                      },
                    ),
                  )
                : [],
          ),
        ),
      ),
    );
  }

  Future<List<UserModel>> searchInPublications(String query) async {
    List<UserModel> users = [];

    // Obtener todos los usuarios y guardarlos en un modelo
    users = await getUsers();

    // Filtrar por productos
    for (UserModel user in users) {
      user.products.removeWhere((product) =>
          !product.name.toUpperCase().contains(query.toUpperCase()));
    }

    // Filtrar por servicios
    for (UserModel user in users) {
      user.services.removeWhere((service) =>
          !service.name.toUpperCase().contains(query.toUpperCase()));
    }

    // Retornar la lista de usuarios
    return users;
  }

  Future<List<UserModel>> searchInPersons(String query) async {
    List<UserModel> users = [];

    // Obtener todos los usuarios y guardarlos en un modelo
    users = await getUsers();

    // Filtrar por personas
    users.removeWhere(
        (user) => !user.name.toUpperCase().contains(query.toUpperCase()));

    // Retornar la lista de usuarios
    return users;
  }

  Future<bool> insertOneProduct(
      String userId, ProductModel newProduct, List<File?> imgs) async {
    try {
      // Obtener el documento del usuario con el id
      UserModel doc = await UserController().getUserById(userId);

      // Subir las imagenes a Firebase Storage
      List<String> imgUrls = [];

      // Generar un id aleatorio
      var idRandom = const Uuid().v4();

      // Asignar el id random al producto
      newProduct.id = idRandom;

      // Crear una copia de la lista de imagenes pero guardarlo en un stream
      var imgsStream = Stream.fromIterable(imgs);

      // Subir cada imagen a Firebase Storage
      await for (var img in imgsStream) {
        var imgRef = carpetaRemota
            .ref('products/${newProduct.id}/${img!.path.split('/').last}');
        await imgRef.putFile(img);
        imgUrls.add(await imgRef.getDownloadURL());
      }

      // Reemplazar las imagenes del nuevo producto con las urls
      newProduct.images = imgUrls;

      // Actualiza el usuario con la nueva lista de productos
      doc.products.add(newProduct);

      // Actualizar el documento del usuario con la nueva lista de productos
      await baseRemota.collection('users').doc(userId).update({
        'products': [
          ...doc.products.map((product) => {
                'id': product.id,
                'name': product.name,
                'description': product.description,
                'category': product.category,
                'images': product.images,
                'price': product.price,
                'ratingAvg': product.ratingAvg,
                'ratingCount': product.ratingCount,
                'state': product.state,
              }),
        ],
      });

      // Retornar true si se insertó correctamente
      return true;
    } catch (error) {
      // Retornar false si hubo un error
      log('Error: $error');
      return false;
    }
  }

  Future<bool> insertOneService(
      String userId, ServiceModel newService, List<File?> imgs) async {
    try {
      // Obtener el documento del usuario con el id
      UserModel doc = await UserController().getUserById(userId);

      // Subir las imagenes a Firebase Storage
      List<String> imgUrls = [];

      // Generar un id aleatorio
      var idRandom = const Uuid().v4();

      // Asignar el id random al servicio
      newService.id = idRandom;

      // Crear una copia de la lista de imagenes pero guardarlo en un stream
      var imgsStream = Stream.fromIterable(imgs);

      // Subir cada imagen a Firebase Storage
      await for (var img in imgsStream) {
        var imgRef = carpetaRemota
            .ref('services/${newService.id}/${img!.path.split('/').last}');
        await imgRef.putFile(img);
        imgUrls.add(await imgRef.getDownloadURL());
      }

      // Reemplazar las imagenes del nuevo servicio con las urls
      newService.images = imgUrls;

      // Actualizar el usuario con la nueva lista de servicios
      doc.services.add(newService);

      // Actualiza el documento del usuario con la nueva lista de servicios
      await baseRemota.collection('users').doc(userId).update({
        'services': [
          ...doc.services.map((service) => {
                'id': service.id,
                'name': service.name,
                'description': service.description,
                'category': service.category,
                'schedule': service.schedule,
                'availableDays': service.availableDays,
                'images': service.images,
                'price': service.price,
                'ratingAvg': service.ratingAvg,
                'ratingCount': service.ratingCount,
                'state': service.state,
              }),
        ],
      });

      // Retornar true si se insertó correctamente
      return true;
    } catch (e) {
      // Retornar false si hubo un error
      log('Error: $e');
      return false;
    }
  }

  Future<bool> updateOneProduct(
      String userId, ProductModel product, List<File?> imgs) async {
    try {
      // Obtener el documento del usuario con el id
      var doc = await UserController().getUserById(userId);

      // Si las imagenes no se cambian, se mantienen las mismas
      if (imgs.isNotEmpty) {
        log('Imagenes: $imgs');
        // Borrar de firebase storage las imagenes anteriores
        for (var img in product.images) {
          await carpetaRemota.refFromURL(img).delete();
        }

        // Subir las imagenes a Firebase Storage
        List<String> imgUrls = [];

        // Crear una copia de la lista de imagenes pero guardarlo en un stream
        var imgsStream = Stream.fromIterable(imgs);

        // Subir cada imagen a Firebase Storage
        await for (var img in imgsStream) {
          var imgRef = carpetaRemota
              .ref('products/${product.id}/${img!.path.split('/').last}');
          await imgRef.putFile(img);
          imgUrls.add(await imgRef.getDownloadURL());
        }

        // Reemplazar las imagenes del nuevo producto con las urls
        product.images = imgUrls;
      }

      log('Productos: ${doc.products}');

      // Actualiza el documento del usuario con la nueva lista de productos
      await baseRemota.collection('users').doc(userId).update({
        'products': [
          ...doc.products.where((p) => p.id != product.id),
          {
            'id': product.id,
            'name': product.name,
            'description': product.description,
            'category': product.category,
            'images': product.images,
            'price': product.price,
            'ratingAvg': product.ratingAvg,
            'ratingCount': product.ratingCount,
            'state': product.state,
          },
        ]
            .map((product) =>
                product is ProductModel ? product.toMap() : product)
            .toList(),
      });

      // Retornar true si se insertó correctamente
      return true;
    } catch (e) {
      // Retornar false si hubo un error
      return false;
    }
  }

  Future<bool> updateOneService(
      String userId, ServiceModel service, List<File?> imgs) async {
    try {
      // Obtener el documento del usuario con el id
      UserModel doc = await UserController().getUserById(userId);

      // Si las imagenes no se cambian, se mantienen las mismas
      if (imgs.isNotEmpty) {
        log('Imagenes: $imgs');
        // Borrar de firebase storage las imagenes anteriores
        for (var img in service.images) {
          await carpetaRemota.refFromURL(img).delete();
        }

        // Subir las imagenes a Firebase Storage
        List<String> imgUrls = [];

        // Crear una copia de la lista de imagenes pero guardarlo en un stream
        var imgsStream = Stream.fromIterable(imgs);

        // Subir cada imagen a Firebase Storage
        await for (var img in imgsStream) {
          var imgRef = carpetaRemota
              .ref('services/${service.id}/${img!.path.split('/').last}');
          await imgRef.putFile(img);
          imgUrls.add(await imgRef.getDownloadURL());
        }

        // Reemplazar las imagenes del nuevo servicio con las urls
        service.images = imgUrls;
      }

      doc.services.removeWhere((s) => s.id == service.id);

      // Actualiza el documento del usuario con la nueva lista de servicios
      await baseRemota.collection('users').doc(userId).update({
        'services': [
          ...doc.services,
          {
            'id': service.id,
            'name': service.name,
            'description': service.description,
            'category': service.category,
            'schedule': service.schedule,
            'availableDays': service.availableDays,
            'images': service.images,
            'price': service.price,
            'ratingAvg': service.ratingAvg,
            'ratingCount': service.ratingCount,
            'state': service.state,
          },
        ]
            .map((service) =>
                service is ServiceModel ? service.toMap() : service)
            .toList(),
      });

      // Retornar true si se insertó correctamente
      return true;
    } catch (e) {
      // Retornar false si hubo un error
      log('Error: $e');
      return false;
    }
  }

  Future<bool> deleteOneProduct(String userId, String productId) async {
    try {
      // Obtener el documento del usuario con el id
      var doc = await UserController().getUserById(userId);

      // Actualiza el documento del usuario con la nueva lista de productos
      await baseRemota.collection('users').doc(userId).update({
        'products': [
          ...doc.products.where((p) => p.id != productId),
        ],
      });

      // Retornar true si se insertó correctamente
      return true;
    } catch (e) {
      // Retornar false si hubo un error
      return false;
    }
  }

  Future<bool> deleteOneService(String userId, String serviceId) async {
    try {
      // Obtener el documento del usuario con el id
      var doc = await UserController().getUserById(userId);

      // Actualiza el documento del usuario con la nueva lista de servicios
      await baseRemota.collection('users').doc(userId).update({
        'services': [
          ...doc.services.where((s) => s.id != serviceId),
        ],
      });

      // Retornar true si se insertó correctamente
      return true;
    } catch (e) {
      // Retornar false si hubo un error
      return false;
    }
  }

  Future<bool> deleteOneUser(String userId) async {
    try {
      // Eliminar el documento del usuario con el id
      await baseRemota.collection('users').doc(userId).delete();

      // Retornar true si se eliminó correctamente
      return true;
    } catch (e) {
      // Retornar false si hubo un error
      return false;
    }
  }

  Future<bool> insertOneUser(UserModel newUser) async {
    try {
      // Insertar el nuevo usuario en la base de datos
      await baseRemota.collection('users').doc(newUser.id).set({
        'imgProfile': '',
        'userName': newUser.userName.toLowerCase(),
        'email': newUser.email.toLowerCase(),
        'password': newUser.password,
        'name': newUser.name,
        'type': newUser.type,
        'location': newUser.location,
        'products': [],
        'services': [],
      });

      // Retornar true si se insertó correctamente
      return true;
    } catch (e) {
      // Retornar false si hubo un error
      return false;
    }
  }

  Future<bool> updateOneUser(UserModel user, File imgProfile) async {
    try {
      log('Usuario: ${user.products}');

      log('Imagen: ${imgProfile.path}');

      // Comprobar que el nombre de usuario nuevo este disponible
      var consulta = await baseRemota
          .collection('users')
          .where('userName', isEqualTo: user.userName.toLowerCase())
          .get();

      if (consulta.docs.first.id != user.id) {
        return false;
      }

      // Si se cambió la imagen de perfil
      if (imgProfile.path.isNotEmpty) {
        // Subir la imagen a Firebase Storage
        var imgRef = carpetaRemota.ref('users/${user.id}/profile.jpg');
        await imgRef.putFile(imgProfile);
        // Reemplazar la imagen de perfil con la url
        user.imgProfile = await imgRef.getDownloadURL();
      }

      // Actualizar el documento del usuario con el id
      await baseRemota.collection('users').doc(user.id).update({
        'imgProfile': user.imgProfile,
        'userName': user.userName.toLowerCase(),
        'email': user.email,
        'password': user.password,
        'name': user.name,
        'type': user.type,
        'location': user.location,
        'products': user.products.map((product) {
          return {
            'id': product.id,
            'name': product.name,
            'description': product.description,
            'category': product.category,
            'images': product.images,
            'price': product.price,
            'ratingAvg': product.ratingAvg,
            'ratingCount': product.ratingCount,
            'state': product.state,
            'calificaciones': product.calificaciones
                .map((calificacion) => calificacion.toMap())
                .toList(),
          };
        }).toList(),
        'sevices': user.services.map((service) {
          return {
            'id': service.id,
            'name': service.name,
            'description': service.description,
            'category': service.category,
            'schedule': service.schedule,
            'availableDays': service.availableDays,
            'images': service.images,
            'price': service.price,
            'ratingAvg': service.ratingAvg,
            'ratingCount': service.ratingCount,
            'state': service.state,
            'calificaciones': service.calificaciones
                .map((calificacion) => calificacion.toMap())
                .toList(),
          };
        }).toList(),
      });

      // Retornar true si se actualizó correctamente
      return true;
    } catch (e) {
      // Retornar false si hubo un error
      return false;
    }
  }

  Future<bool> isUserVerified(String userId) async {
    try {
      // Buscar el documento del usuario con el id
      Map<String, dynamic> user = await baseRemota
          .collection('users')
          .doc(userId)
          .get()
          .then((doc) => doc.data()!);

      log('Usuario: ${user['userName']}');

      // Verificar si el usuario tiene una clave llamada verified
      if(user['verified'] == null) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
