import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../controller/user_controller.dart';
import '../../model/user_model.dart';
import '../../tools/tool.dart';
import '../widgets/edit_profile.dart';
import 'feed/product_widget.dart';

class Profile extends StatefulWidget {
  final ValueNotifier<UserModel> userData;

  const Profile({
    super.key,
    required this.userData,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.userData,
        builder: (context, users, child) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                await _fetchData();
              },
              child: ListView(
                children: [
                  _drawUserInfo(),
                  _drawPublications(),
                ],
              ),
            ),
          );
        });
  }

  _fetchData() async {
    widget.userData.value = await UserController().getMyProfileData();
  }

  _drawUserInfo() {
    if (widget.userData.value.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: widget.userData.value.imgProfile.trim().isEmpty
                      ? CircleAvatar(
                          radius: 40,
                          backgroundImage: Image.network(
                            Tool.getDefaultProfileImage(),
                            fit: BoxFit.scaleDown,
                          ).image)
                      : CircleAvatar(
                          radius: 40,
                          backgroundImage: Image.network(
                            widget.userData.value.imgProfile,
                            fit: BoxFit.scaleDown,
                          ).image),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfile(
                          user: widget.userData.value,
                          imgProfile: widget.userData.value.imgProfile,
                        ),
                      ),
                    );
                  },
                  style: Tool.getButtonStyle('secondary'),
                  child: const Text('Editar perfil'),
                ),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _displayName(),
                  Text(
                    '@${widget.userData.value.userName} - ${widget.userData.value.type}',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _displayName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '${widget.userData.value.name} ',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        FutureBuilder(
          future: UserController().isUserVerified(widget.userData.value.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              if (snapshot.data!) {
                return const Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  color: Colors.blue,
                  size: 20,
                );
              } else {
                return const SizedBox();
              }
            }
          },
        ),
      ],
    );
  }

  _drawPublications() {
    return ProductWidget(user: widget.userData.value);
  }
}
