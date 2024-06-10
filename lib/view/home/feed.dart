import 'package:flutter/material.dart';
import 'package:tigerplaceproject/view/widgets/new_product.dart';
import 'package:tigerplaceproject/view/widgets/new_service.dart';

import '../../controller/user_controller.dart';
import '../../model/user_model.dart';
import 'feed/product_widget.dart';

class Feed extends StatelessWidget {
  final ValueNotifier<List<UserModel>> usersData;

  const Feed({
    super.key,
    required this.usersData,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: usersData,
        builder: (context, users, child) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                await _fetchData();
              },
              child: _drawPublications(),
            ),
            floatingActionButton: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'btn1',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const NewService();
                      }),
                    );
                  },
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add_business_sharp),
                ),
                FloatingActionButton.extended(
                  heroTag: 'btn2',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const NewProduct();
                      }),
                    );
                  },
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  label: const Text('Producto'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          );
        });
  }

  // _drawCreateNewPublication(BuildContext context) {
  //   showModalBottomSheet(
  //     showDragHandle: true,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SizedBox(
  //         height: 100,
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             InkWell(
  //               onTap: () {},
  //               child: const Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(Icons.store_outlined, size: 30),
  //                   Text('Producto'),
  //                 ],
  //               ),
  //             )
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  _fetchData() async {
    usersData.value = await UserController().getUsers();
  }

  Widget _drawPublications() {
    if (usersData.value.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 150),
        itemCount: usersData.value.length,
        itemBuilder: (context, index) {
          return ProductWidget(user: usersData.value[index]);
        },
      );
    }
  }
}
