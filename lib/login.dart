import 'package:flutter/material.dart';

import 'package:flutter_chat/util/adapt.dart';
import 'package:flutter_chat/util/text_styles.dart';
import 'package:openfire/openfire.dart';
import 'package:xml/xml.dart';
import 'package:flutter_chat/util/connection.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        brightness: Brightness.dark,
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            // The login screen is immediately displayed on top of the Shrine
            // home screen using onGenerateRoute and so rootNavigator must be
            // set to true in order to get out of Shrine completely.
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ),*/
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(px(24.0)),
          children: <Widget>[
            Row(
              children: <Widget>[
                Image.asset('assets/images/vip_agent.png',width: px(32.0), height: px(32.0),),
                SizedBox(width: px(5.0),),
                Text('VIP Concierge Chat', style: TextStyle(
                  fontSize: Adapt.adapt360.px(20.0),
                  color: txtGold,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: px(5.0)),
                Text(
                  'Log in to your agent account',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: txtBlack,
                    height: 1.29,
                    fontSize: font(14.0),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            SizedBox(height: px(40.0)),
            Form(
              autovalidate: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: px(8.0)), 
                    child: Text('Account', style: TextStyle(
                      fontSize: px(14), 
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: txtGray,
                    )),
                  ),
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter account number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(px(8.0)),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),
                  SizedBox(height: px(32.0)),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: px(8.0)), 
                    child: Text('Password', style: TextStyle(
                      fontSize: px(14), 
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: txtGray,
                    )),
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Enter Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(px(8.0)),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white70
                    ),
                  ),
                  SizedBox(height: px(50.0)),
                  SizedBox(
                    width: double.infinity,
                    height: px(48),
                    child: RaisedButton(
                      color: txtGold,
                      textColor: txtWhite,
                      child: Text('Login', style: TextStyle(
                        fontSize: px(16), 
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        height: 1.25,
                      ),),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(px(5.0))
                      ),
                      onPressed: () {
                        //MessageUtils.connect();
                        if ( _passwordController.text == null ||
                             _passwordController.text == "" ||
                             _usernameController.text == null ||
                             _usernameController.text == "") {
                          return;
                        }
                        XmppConnection conn = XmppConnection.getInstance();
                        conn.connect(_usernameController.text,  _passwordController.text,(result){
                          Navigator.of(context, rootNavigator: true).pop();
                        });
                      },
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
