import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:tigerplaceproject/controller/user_controller.dart';
import 'package:tigerplaceproject/model/product_model.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'dart:developer';

class NewProduct extends StatefulWidget {
  const NewProduct({super.key});

  @override
  State<NewProduct> createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  final List<File?> _imgFiles = [];
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Comida');

  final List<String> _categoryItems = [
    'Comida',
    'Accesorios',
    'Calzado',
    'Ropa',
    'Tecnología',
  ];
  final _priceController = TextEditingController();
  bool _stateController = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Producto'),
      ),
      body: _displayForm(),
    );
  }

  Widget _displayForm() {
    double screenWidth = MediaQuery.of(context).size.width;
    EdgeInsets paddingValue = screenWidth > 600 ? const EdgeInsets.symmetric(horizontal: 200) : EdgeInsets.zero;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: paddingValue,
        child: Column(
          children: [
            _drawFormField(_nameController, 'Nombre'),
            _drawFormField(_descriptionController, 'Descripción'),
            DropdownButtonFormField(
              padding: const EdgeInsets.only(left: 22, right: 22),
              value: _categoryController.text,
              items: _categoryItems.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _categoryController.text = value.toString();
                });
              },
            ),
            //_drawFormField(_imagesController, 'Imágenes'),
            Padding(
              padding: const EdgeInsets.only(bottom: 11, left: 22, right: 22),
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingrese un valor';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 11, left: 22, right: 22),
              child: Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Estado'),
                      value: _stateController,
                      onChanged: (bool? value) {
                        setState(() {
                          _stateController = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      onTap: () async {
                        File? imgFile;

                        final ImagePicker picker = ImagePicker();

                        final List<XFile?> imgs = await picker.pickMultiImage();

                        if (imgs.isEmpty) {
                          return;
                        }

                        for (var img in imgs) {
                          imgFile =
                              File(img!.path); // convert it to a Dart:io file
                          _imgFiles.add(imgFile);
                          log(img.path);
                        }

                        setState(() {
                          _imgFiles;
                        });
                      },
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: 'Imagenes',
                        filled: true,
                        prefixIcon: Icon(Icons.access_time_outlined),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_imgFiles.isEmpty) {
                          return 'Ingrese un valor';
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
            ),
            if (_imgFiles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 11, left: 22, right: 22),
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imgFiles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(_imgFiles[index]!),
                      );
                    },
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _displaySubmitButton(),
                _displayCancelButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawFormField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11, left: 22, right: 22),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Por favor, ingrese un valor';
          }
          return null;
        },
      ),
    );
  }

  Widget _displaySubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 33),
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Save the product
            ProductModel product = ProductModel(
              name: _nameController.text,
              description: _descriptionController.text,
              category: _categoryController.text,
              images: [],
              price: int.parse(_priceController.text),
              ratingAvg: 0.0,
              ratingCount: 0,
              state: _stateController,
              calificaciones: [],
            );

            // mostrar un dialogo de carga mientras se guarda el producto
            showDialog(
              context: context,
              builder: (context) => FutureProgressDialog(
                UserController().insertOneProduct(
                    UserController().getMyProfileId(), product, _imgFiles),
                message: const Text('Publicando producto...'),
              ),
            ).then((value) {
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto guardado'),
                  ),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al guardar el producto'),
                  ),
                );
              }
            });
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          minimumSize: const Size(88, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        child: const Text('Guardar'),
      ),
    );
  }

  Widget _displayCancelButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 33),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          minimumSize: const Size(88, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        child: const Text('Cancelar'),
      ),
    );
  }
}
