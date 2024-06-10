import 'package:flutter/material.dart';
import 'package:tigerplaceproject/controller/login_controller.dart';
import 'package:tigerplaceproject/view/home/profile.dart';
import 'package:tigerplaceproject/view/sign_in.dart';

import '../controller/user_controller.dart';
import '../model/user_model.dart';
import 'home/feed.dart';
import 'home/find.dart';

// Ventana principal de la aplicacion
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _index = 0;
  final ValueNotifier<List<UserModel>> _usersData = ValueNotifier([]);
  final ValueNotifier<UserModel> _userData = ValueNotifier(UserModel.empty());

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return _drawScaffoldPC();
      } else {
        return _drawScaffoldPhone();
      }
    });
  }

  /// Método para dibujar el cuerpo de la pantalla cuando esta en pc
  Widget _drawScaffoldPC() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Icon(Icons.store_outlined, size: 30),
        actions: [
          _displaySignOutButton(),
          _displayChangeLocationButton(),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (int index) {
              setState(() {
                _index = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Inicio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text('Buscar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Perfil'),
              ),
            ],
          ),
          Expanded(
            child: drawBody(),
          )
        ],
      ),
    );
  }

  /// Método para dibujar el cuerpo de la pantalla cuando esta en telefono
  Widget _drawScaffoldPhone() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Icon(Icons.store_outlined, size: 30),
        actions: [
          _displaySignOutButton(),
          _displayChangeLocationButton(),
        ],
      ),
      body: drawBody(),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  /// Método para dibujar el cuerpo de la pantalla
  Widget drawBody() {
    switch (_index) {
      case 0:
        return Feed(usersData: _usersData);
      case 1:
        return const Find();
      case 2:
        return Profile(userData: _userData);
      default:
        return Feed(usersData: _usersData);
    }
  }

  Future<void> _fetchData() async {
    _usersData.value = await UserController().getUsers();
  }

  Future<void> _fetchUserData() async {
    _userData.value = await UserController().getMyProfileData();
  }

  Widget _displaySignOutButton() {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Cerrar sesión'),
              content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
              actions: [
                TextButton(
                  onPressed: () async {
                    await LoginController.cerrarSesion().then((value) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignIn(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    });
                  },
                  child: const Text('Sí'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _displayChangeLocationButton() {
    return IconButton(
      icon: const Icon(Icons.location_on),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Ubicación'),
              content: const Text('¿Deseas cambiar tu ubicación?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _displayModalBottomSheet();
                  },
                  child: const Text('Sí'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final List<String> _locations = ['LC', 'Iguaneras', 'UD', 'Biblioteca', 'Los G', 'El Domo','La Campana', 'Cafeteteria 2do piso'];
  var _selectedLocation = 'LC';

  void _displayModalBottomSheet() {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20,
          ),
          child: Column(
            children: [
              // Lista de ubicaciones
              DropdownButtonFormField(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                value: _selectedLocation,
                items: _locations.map((String location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) => {
                  setState(() {
                    _selectedLocation = value.toString();
                  })
                },
              ),
              // Boton para guardar la ubicacion
              ElevatedButton(
                onPressed: () async {
                  UserController().changeLocation(_selectedLocation).then((value){
                    Navigator.pop(context);
                  });
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
