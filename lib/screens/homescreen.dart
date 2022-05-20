import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample_task/common/const.dart';
import 'package:sample_task/models/arguments.dart';
import 'package:sample_task/route_nav/nav_const.dart';
import '../generated/l10n.dart';
import '../provider/cart_provider.dart';
import '../services/notification_service.dart';
import '../shimmer/custom_widget.dart';
import 'gmap_screen.dart';
import 'package:sample_task/models/usermodel.dart';
import '../widgets/navigation_drawer.dart';
import '../provider/db_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final textController = TextEditingController();
  List<UserModel>? userOnSearch;
  bool isLoading = false;
  @override
  void initState() {
    LocalNotificationService.initializeNotificationHome(context);
    Future.microtask(() => context.read<ContactsProvider>().loadUsers());
    Future.microtask(() => context.read<CartProvider>().loadProducts());
    super.initState();
  }
  Widget buildShimmer() =>
      ListTile(
        leading: const CustomWidget.circular(height: 64, width: 64),
        title: Align(
          alignment: Alignment.centerLeft,
          child: CustomWidget.rectangular(height: 16,
            width: MediaQuery.of(context).size.width*0.3,),
        ),
        subtitle: const CustomWidget.rectangular(height: 14),
      );
  @override
  Widget build(BuildContext context) {
    final translated = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title:  Text(translated.homeScreen),
        backgroundColor: Colors.teal,
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GoogleMapScreen()));
                  },
                  icon: const Icon(Icons.location_on)))
        ],
      ),
      body: Consumer<ContactsProvider>(builder: (context, model, child) {
        // if (model.user == null) {
        //   return const Center(
        //     child: CircularProgressIndicator(),
        //   );
        // }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    userOnSearch = model.user
                        ?.where((element) => element.name
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
                controller: textController,
                decoration:  InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 3.0)),
                    hintText: translated.searchName),
              ),
            ),
            textController.text.isNotEmpty && userOnSearch!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:  [
                        const Icon(Icons.search_off),
                        Text(
                          translated.noResults,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                        // itemCount: snapshot.data!.name!.length,
                        itemCount: textController.text.isNotEmpty
                            ? userOnSearch!.length
                            : model.user?.length,
                        itemBuilder: (context, index) {
                          var item = model.user?.elementAt(index);

                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: model.user == null ? const CustomWidget.circular(height: 64, width: 64) :
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(textController
                                            .text.isNotEmpty
                                        ? userOnSearch![index]
                                                .profileImage
                                                .isEmpty
                                            ? 'https://www.kindpng.com/picc/m/78-785827_user-profile-avatar-login-account-male-user-icon.png'
                                            : userOnSearch![index].profileImage
                                        : item!.profileImage.isEmpty
                                            ? 'https://www.kindpng.com/picc/m/78-785827_user-profile-avatar-login-account-male-user-icon.png'
                                            : item.profileImage),
                                    radius: 18,
                                  ),
                                  title: model.user == null ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: CustomWidget.rectangular(height: 16,
                                      width: MediaQuery.of(context).size.width*0.3,),
                                  ) :
                                  Text(textController.text.isNotEmpty
                                      ? userOnSearch![index].name.isNotEmpty
                                          ? '${translated.name} : ${userOnSearch![index].name}'
                                          : '${translated.name} : '
                                      : item!.name.isNotEmpty
                                          ? '${translated.name} : ${item.name}'
                                          : '${translated.name} : '),
                                  subtitle: model.user == null ? const CustomWidget.rectangular(height: 14) :
                                  Text(textController.text.isNotEmpty
                                      ? userOnSearch![index].username.isNotEmpty
                                          ? '${translated.userName} : ${userOnSearch![index].username}'
                                          : '${translated.userName} : '
                                      : item!.username.isNotEmpty
                                          ? '${translated.userName} : ${item.username}'
                                          : '${translated.userName} : '),
                                  onTap: () {
                                    //Navigator.of(context,rootNavigator: true).push(MaterialPageRoute(builder: (context)=>UserDetails(userModel: textController.text.isNotEmpty ? userOnSearch![index] : item!)));
                                    ArgumentsRoute route = ArgumentsRoute(
                                        userModel:
                                            textController.text.isNotEmpty
                                                ? userOnSearch![index]
                                                : item!);
                                    Navigator.pushNamed(
                                        context, userDetailScreenRoute,
                                        arguments: route);
                                  },
                                )
                                //Text(user![index].name)
                              ],
                            ),
                          );
                        }),
                  ),
          ],
        );
      }),
      drawer: const Drawer(
        child: NavigationDrawer(),
      ),
    );
  }
}

///logout fn
// static Future<void> userLogOut(
//     {required String loginMethod, required BuildContext context}) async {
//   switch (loginMethod) {
//     case Const.googleUser:
//       Provider.of<UserProvider>(context, listen: false)
//           .googleLogout(context);
//       break;
//     case Const.facebookUser:
//       Provider.of<UserProvider>(context, listen: false)
//           .fbLogOut(context);
//       break;
//
//     default:
//       SharedPreferences shared = await SharedPreferences.getInstance();
//       shared.remove('email');
//   }
// }
