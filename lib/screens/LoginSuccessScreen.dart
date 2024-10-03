import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:lottie/lottie.dart';

class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({super.key});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  @override
  void initState() {
    super.initState();
    //  Timer(
    //  const  Duration(seconds:10),
    //   () =>
    //   Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(
    //   builder: (_) =>  const LoginScreen()
    //   ),
    //   ),
    //  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFFFFFFF),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 35,
              ),
              GestureDetector(
                onTap: () {
                  Get.offAll(BottomNavigationPage());
                },
                child: Container(
                  // padding: EdgeInsets.only(left: 350),
                  child: Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.clear,
                        size: 40,
                        color: Colors.black,
                      )),
                ),
              ),
              SizedBox(child: Center(child: Lottie.asset("assets/anim.json"))),
              SizedBox(
                height: 15,
              ),
              Text(
                "Votre compte a été créé avec succès. L'administrateur vous enverra un message de validation  dans les 24 heures. Si vous ne recevez pas de message dans ce délai, veuillez contacter le +223 51554851",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
