import 'package:app_school/model/auth_api.dart';
import 'package:app_school/main.dart';
import 'dashboard.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  var an = ()  async {
      final isAuthenticated = await LocalAuthApi.authenticate();
      print(isAuthenticated);
      if (isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => dashboard()),
        );
      }
    };
  an();
  return  Scaffold(
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 24),
              buildAuthenticate(context),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildAuthenticate(BuildContext context) => buildButton(
    text: 'Authenticate',
    icon: Icons.lock_open,
    onClicked: () async {
      final isAuthenticated = await LocalAuthApi.authenticate();
      print(isAuthenticated);
      if (isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => dashboard()),
        );
      }
    },
  );

  Widget buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(50),
        ),
        icon: Icon(icon, size: 26),
        label: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
        onPressed: onClicked,
      );
}