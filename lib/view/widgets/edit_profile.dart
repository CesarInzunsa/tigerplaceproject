// Flutter
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:developer';

// Models
import '../../controller/user_controller.dart';
import '../../model/user_model.dart';
import '../../tools/tool.dart';

class EditProfile extends StatefulWidget {
  final UserModel user;
  final String imgProfile;

  const EditProfile({
    super.key,
    required this.user,
    required this.imgProfile,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Crear una clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _typeController = TextEditingController();

  // Imagen de perfil
  File _imgProfile = File('');

  // Array de tipos de usuario
  final List<String> _types = ['Cliente', 'Vendedor'];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _userNameController.text = widget.user.userName;
    _typeController.text = widget.user.type;

    log('EditProfile: build');
    log('EditProfile: name: ${widget.user.name}');
    log('EditProfile: username: ${widget.user.userName}');
    log('EditProfile: type: ${widget.user.type}');
    log('EditProfile: imgProfile: ${widget.imgProfile}');
  }

  @override
  Widget build(BuildContext context) {
    // log('EditProfile: build');
    // log('EditProfile: name: ${widget.user.name}');
    // log('EditProfile: username: ${widget.user.userName}');
    // log('EditProfile: type: ${widget.user.type}');
    //log('EditProfile: imgProfile: ${widget.user.imgProfile}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: _displayBody(),
    );
  }

  Widget _displayBody() {
    double screenWidth = MediaQuery.of(context).size.width;
    EdgeInsets paddingValue = screenWidth > 600 ? const EdgeInsets.symmetric(horizontal: 200) : EdgeInsets.zero;

    return ListView(
      padding: paddingValue,
      children: [
        _displayForm(),
      ],
    );
  }

  Widget _displayForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _displaySelectImage(),
          _drawFormField(_nameController, 'Nombre'),
          _drawFormField(_userNameController, 'Nombre de Usuario'),
          _displayCombo(),
          _displayButtons(),
        ],
      ),
    );
  }

  Widget _drawFormField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextFormField(
        style: const TextStyle(fontSize: 20),
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: (value) {
          if (Tool.isNullOrBlank(value!)) {
            return 'Por favor, ingrese su $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _displayCombo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: DropdownButtonFormField(
        value: _typeController.text,
        items: _types.map((String type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          _typeController.text = value.toString();
        },
        decoration: const InputDecoration(
          labelText: 'Tipo de usuario',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _displaySelectImage() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10),
                child: _drawCircleAvatar(),
              ),
              OutlinedButton(
                onPressed: () {
                  _showImagePicker();
                },
                style: Tool.getButtonStyle('secondary'),
                child: const Text('Cambiar imagen'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImagePicker() async {
    final ImagePicker picker = ImagePicker();

    final XFile? img = await picker.pickImage(source: ImageSource.gallery);

    if (img == null) {
      return;
    }

    // convert it to a Dart:io file
    _imgProfile = File(img.path);

    log('EditProfile: _imgProfile: ${_imgProfile.path}');

    setState(() {
      _imgProfile;
    });
  }

  Widget _drawCircleAvatar() {
    return CircleAvatar(
      radius: 40,
      backgroundImage: _getImgProfile(),
    );
  }

  ImageProvider _getImgProfile() {
    if (_imgProfile.path != '') {
      return Image.file(
        _imgProfile,
        fit: BoxFit.scaleDown,
      ).image;
    }

    if (widget.imgProfile.isNotEmpty) {
      if (_imgProfile.path != '') {
        return Image.file(
          _imgProfile,
          fit: BoxFit.scaleDown,
        ).image;
      } else {
        return Image.network(
          widget.imgProfile,
          fit: BoxFit.scaleDown,
        ).image;
      }
    } else {
      return Image.network(
        Tool.getDefaultProfileImage(),
        fit: BoxFit.scaleDown,
      ).image;
    }
  }

  Widget _displayButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: Tool.getButtonStyle('cancel'),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Guardar los datos
              if (_formKey.currentState!.validate()) {
                // Guardar los datos

                // Crear objeto de tipo User
                final UserModel user = UserModel(
                  id: widget.user.id,
                  imgProfile: widget.imgProfile,
                  name: _nameController.text,
                  email: widget.user.email,
                  password: widget.user.password,
                  userName: _userNameController.text,
                  type: _typeController.text,
                  location: widget.user.location,
                  products: widget.user.products,
                  services: widget.user.services,
                );

                // Enviar el objeto al método de actualización del perfil
                showDialog(
                  context: context,
                  builder: (context) => FutureProgressDialog(
                    UserController().updateOneUser(user, _imgProfile),
                    message: const Text('Actualizando perfil...'),
                  ),
                ).then((value) {
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Perfil actualizado'),
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al actualizar el perfil'),
                      ),
                    );
                  }
                });
              }
            },
            style: Tool.getButtonStyle('primary'),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
