import 'package:flutter/material.dart';
import 'package:tigerplaceproject/view/home/profile_user.dart';
import '../../view/home/feed/product_widget.dart';
import '../../controller/user_controller.dart';
import '../../model/user_model.dart';

List<UserModel> publicationsData = [];
List<UserModel> personsData = [];
ValueNotifier<String> searchValue = ValueNotifier('');

class Find extends StatelessWidget {
  const Find({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buscar'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Publicaciones'),
              Tab(text: 'Personas'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                onSubmitted: (value) {
                  searchValue.value = value;
                },
                decoration: InputDecoration(
                  hintText: 'Buscar',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: searchValue,
              builder: (context, value, child) {
                return Expanded(
                  child: TabBarView(
                    children: [
                      _buildPublicaciones(),
                      _buildPersonas(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _fetchData(value) async {
  publicationsData = await UserController().searchInPublications(value);
  personsData = await UserController().searchInPublications(value);
}

_buildPublicaciones() {
  if (searchValue.value.isEmpty) {
    return const Center(child: Text('Buscar productos / servicios'));
  }

  return FutureBuilder(
    future: _fetchData(searchValue.value),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return ListView.builder(
          itemCount: publicationsData.length,
          itemBuilder: (context, index) {
            return ProductWidget(
              user: publicationsData[index],
            );
          },
        );
      }
    },
  );
}

_buildPersonas() {
  if (searchValue.value.isEmpty) {
    return const Center(child: Text('Buscar personas'));
  }

  return FutureBuilder(
    future: _fetchData(searchValue.value),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return ListView.builder(
          itemCount: personsData.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(personsData[index].name),
              subtitle: Text(personsData[index].userName),
              trailing: Text(personsData[index].type),
              onTap: () {
                final ValueNotifier<UserModel> userData =
                    ValueNotifier(personsData[index]);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileUser(userData: userData)));
              },
            );
          },
        );
      }
    },
  );
}
