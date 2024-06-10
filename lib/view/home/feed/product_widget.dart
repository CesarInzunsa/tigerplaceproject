import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:developer';

import '../../../controller/user_controller.dart';
import '../../widgets/edit_product.dart';
import '../../widgets/edit_service.dart';

class ProductWidget extends StatefulWidget {
  final dynamic user;

  const ProductWidget({
    super.key,
    required this.user,
  });

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  int rating = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var product in widget.user.products)
          _drawProductCard(product, widget.user.id),
        for (var service in widget.user.services)
          _drawServiceCard(service, widget.user.id)
      ],
    );
  }

  _drawProductCard(product, String userId) {
    return GestureDetector(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(widget.user.name),
              subtitle: Text(
                  'Ubicación: ${widget.user.location} - ${product.state ? 'Activo' : 'Inactivo'}'),
              leading: const Icon(Icons.person),
              visualDensity: VisualDensity.compact,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${product.description}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var image in product.images)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.network(
                        image,
                        height: 200,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 200,
                            width: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Container(
                            height: 200,
                            width: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error_outline),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    'Precio: \$${product.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Rating: ${product.ratingAvg}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.star, color: Colors.yellow),
                  Text(
                    '(${product.ratingCount})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        log('ENTRO AL PRODUCTO!!!!!!!!!!!!!!!');
        // Si el producto le pertenece al usuario actual
        // entonces se redirige a la pantalla de edición
        if (await _isCurrentUser(widget.user.id)) {
          log('ES EL USUARIO ACTUAL');
          _showConfirmEditProdServDialog(product, isProduct: true);
        } else {
          // Si el producto no le pertenece al usuario actual
          // entonces mostrar dialogo de punteo
          log('NO ES EL USUARIO ACTUAL');
          _rateProductOrService(product, userId, isProduct: true);
        }
      },
    );
  }

  _drawServiceCard(service, String userId) {
    return GestureDetector(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(widget.user.name),
              subtitle: Text(
                  'Ubicación: ${widget.user.location} - ${service.state ? 'Activo' : 'Inactivo'}'),
              leading: const Icon(Icons.person),
              trailing: Text('Horario: ${service.schedule}'),
              visualDensity: VisualDensity.compact,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${service.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${service.description}\nDias: ${service.availableDays.toString()}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var image in service.images)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.network(
                        image,
                        height: 200,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 200,
                            width: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Container(
                            height: 200,
                            width: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error_outline),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    'Precio: \$${service.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Rating: ${service.ratingAvg}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.star, color: Colors.yellow),
                  Text(
                    '(${service.ratingCount})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        log('ENTRO AL SERVICIO!!!!!!!!!!!!!!!');
        // Si el servicio le pertenece al usuario actual
        // entonces se redirige a la pantalla de edición
        if (await _isCurrentUser(widget.user.id)) {
          log('ES EL USUARIO ACTUAL');
          _showConfirmEditProdServDialog(service, isProduct: false);
        } else {
          // Si el servicio no le pertenece al usuario actual
          // entonces mostrar dialogo de punteo
          log('NO ES EL USUARIO ACTUAL');
          _rateProductOrService(service, userId, isProduct: false);
        }
      },
    );
  }

  void _rateProductOrService(dynamic prodServ, String userId,
      {required bool isProduct}) {
    String titulo = '';
    if (isProduct) {
      log('PUNTEAR PRODUCTO');
      titulo = 'Puntúa el producto: ${prodServ.name}';
    } else {
      log('PUNTEAR SERVICIO');
      titulo = 'Puntúa el servicio: ${prodServ.name}';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: RatingBar.builder(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.all(4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              this.rating = rating.toInt();
              log(rating.toString());
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                log('PUNTEO: $rating');

                String myId = UserController().getMyProfileId();

                if (isProduct) {
                  log('PUNTEAR PRODUCTO');
                  await UserController()
                      .rateProduct(userId, prodServ.id, rating, myId)
                      .then((value) {
                    if (value) {
                      _showMessage('Puntuación realizada con éxito');
                    } else {
                      _showMessage('Error al puntuar el producto');
                    }
                  });
                } else {
                  log('PUNTEAR SERVICIO');
                  await UserController()
                      .rateService(userId, prodServ.id, rating, myId)
                      .then((value) {
                    if (value) {
                      _showMessage('Puntuación realizada con éxito');
                    } else {
                      _showMessage('Error al puntuar el producto');
                    }
                  });
                }
              },
              child: const Text('Puntuar'),
            ),
          ],
        );
      },
    );
  }

  _showConfirmEditProdServDialog(prodServ, {required bool isProduct}) {
    String titulo = '';
    if (isProduct) {
      log('EDITAR PRODUCTO');
      titulo = 'Editar producto: ${prodServ.name}';
    } else {
      log('EDITAR SERVICIO');
      titulo = 'Editar servicio ${prodServ.name}';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: const Text('¿Desea editar este producto/servicio?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    if (isProduct) {
                      return EditProduct(product: prodServ);
                    } else {
                      return EditService(service: prodServ);
                    }
                  }),
                );
              },
              child: const Text('Editar'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _isCurrentUser(String userId) async {
    return UserController().isCurrentUser(userId);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
