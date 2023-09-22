import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/auth_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/profile_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/splash_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/theme_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/no_internet_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/auth_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/dashboard/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/maintenance/maintenance_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/onboarding/onboarding_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/splash/widget/splash_painter.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  late StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(!firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
        isNotConnected ? const SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? getTranslated('no_connection', context)! : getTranslated('connected', context)!,
            textAlign: TextAlign.center,
          ),
        ));
        if(!isNotConnected) {
          _route();
        }
      }
      firstTime = false;
    });

    _route();
  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged.cancel();
  }

  void _route() {
    Provider.of<SplashProvider>(context, listen: false).initConfig(context).then((bool isSuccess) {
      if(isSuccess) {
        Provider.of<SplashProvider>(context, listen: false).initSharedPrefData();
        Timer(const Duration(seconds: 1), () {
          if(Provider.of<SplashProvider>(context, listen: false).configModel!.maintenanceMode!) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const MaintenanceScreen()));
          }else {
            if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
              Provider.of<AuthProvider>(context, listen: false).updateToken(context);
              Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const DashBoardScreen()));
            } else {
              if(Provider.of<SplashProvider>(context, listen: false).showIntro()!) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => OnBoardingScreen(
                  indicatorColor: ColorResources.grey, selectedIndicatorColor: Theme.of(context).primaryColor,
                )));
              }else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const AuthScreen()));
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Provider.of<SplashProvider>(context).hasConnection ? Stack(
        clipBehavior: Clip.none, children: [
          
          Container(
            decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                 Color.fromARGB(255, 157, 240, 198),
                 Color.fromARGB(255, 78, 177, 91), 
                    
                 
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topRight,
              
              ),
              
           ),
           
           child: Center(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(210, 0, 40, 70),
                  child: Image.asset(Images.pakFlag, fit: BoxFit.scaleDown, width: 30),
                ),
              ],
            ),
           ),


           
            
            //width: MediaQuery.of(context).size.width,
            //height: MediaQuery.of(context).size.height,
            //color: Provider.of<ThemeProvider>(context).darkTheme ? Colors.black : ColorResources.getPrimary(context),
           // child: CustomPaint(
            //  painter: SplashPainter(),
            //S),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(Images.splashScreenLogo, height: 250.0, fit: BoxFit.scaleDown,
                  width: 250.0,),



                 //const SizedBox(height: 15,),
                 const Padding(
                   padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                   child: const Text('Made in ',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                 ),


                  const SizedBox(height: 300,),
                 const Text('Copyright © 2023 Techspire Pvt Ltd. All rights reserved.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  ),

              ],
            ),
          ),
        ],
      ) : const NoInternetOrDataScreen(isNoInternet: true, child: SplashScreen()),
    );
  }

}
