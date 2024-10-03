import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koumi/Admin/NotificationPage.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/MessageWa.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/PinLoginScreen.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/service/MessageService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
  @override
  Size get preferredSize => const Size.fromHeight(100.0);
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _CustomAppBarState extends State<CustomAppBar> {
  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];
  String type = '';
  List<MessageWa> messageList = [];
  String? email = "";
  bool isExist = false;

  void verify() async {
    await Provider.of<ActeurProvider>(context, listen: false)
        .initializeActeurFromSharedPreferences();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      typeActeurData = acteur.typeActeur!;
      type = typeActeurData.map((data) => data.libelle).join(', ');
      setState(() {
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Vérifiez si acteur est non nul avant de l'attribuer à la variable locale
    // if (Provider.of<ActeurProvider>(context, listen: false).acteur != null) {
    verify();
  }

  @override
  Widget build(BuildContext context) {
    return !isExist
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/fav.png',
                  height: 46,
                  scale: 1,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Future.microtask(() {
                      Provider.of<BottomNavigationService>(context,
                              listen: false)
                          .changeIndex(0);
                    });
                    Get.to(
                      PinLoginScreen(),
                      duration: Duration(seconds: 1),
                      transition: Transition.leftToRight,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  icon: Icon(
                    Icons.login,
                    color: const Color.fromARGB(255, 3, 100, 179),
                  ),
                  label: Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                      color: const Color.fromARGB(255, 3, 100, 179),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Consumer<ActeurProvider>(
                builder: (context, acteurProvider, child) {
                  final ac = acteurProvider.acteur;
                  if (ac == null) {
                    return SizedBox();
                  }

                  List<TypeActeur> typeActeurData = ac.typeActeur!;
                  type = typeActeurData.map((data) => data.libelle).join(', ');
                  return ListTile(
                    tileColor: Color.fromRGBO(255, 255, 255, 1),
                    leading: ClipOval(
                        child: FadeInImage(
                      image: NetworkImage(
                          "$apiOnlineUrl/acteur/${acteur!.idActeur}/image?timestamp=${DateTime.now().millisecondsSinceEpoch}"),
                      placeholder: AssetImage('assets/images/profil.jpg'),
                      placeholderFit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/profil.jpg',
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        );
                      },
                    )),
                    title: Text(
                      ac.nomActeur!.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: d_colorGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: d_colorGreen,
                          fontSize: 17,
                          fontWeight: FontWeight.w400),
                    ),
                    trailing: badges.Badge(
                      position: badges.BadgePosition.topEnd(top: -8, end: -1),
                      badgeContent:
                          Consumer(builder: (context, messageService, child) {
                        return FutureBuilder(
                            future: MessageService()
                                .fetchMessageByActeur(ac.idActeur!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("0",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ));
                              }

                              if (!snapshot.hasData) {
                                return Text("0",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ));
                              } else {
                                messageList = snapshot.data!;
                                return Text(
                                  messageList.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                );
                              }
                            });
                      }),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationPage()));
                        },
                        child: Icon(
                          Icons.notifications_none_outlined,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }

  Widget _buildShimmerEffect() {
    return ClipOval(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
