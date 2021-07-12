import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
// import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:webview_flutter/webview_flutter.dart';

const AWSUserPoolId = 'eu-west-3_VT9pDaicz';
const AWSClientIdPROD = '4k9tabu0qem0658ksdblgag54h'; // PROD ?
const Region = 'eu-west-3';
const secret = '1h5tbok0fn73ooe52vofiankb0gkqbiiqomqs33dt2jnc5vthkeh';

const WEBAPP_API_KEY = "webapp-b539f812-bee0-4068-8ab9-c46d9b03521a";
const COGNITO_POOL_URL = 'assurly-beta.auth.eu-west-3';
const AWSClientId = '37uq05doga3mot25bqbg8moaia'; // DEV ?
const COGNITO_CLIENT_ID = AWSClientId; // DEV ?
const COGNITO_CLIENT_ID_PROD = AWSClientIdPROD; // * PROD
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLogged;
  double progress = 0;
  String token;
  WebViewController _controller;
  final Completer<WebViewController> _controllerCompleter =
      Completer<WebViewController>();
  @override
  void initState() {
    super.initState();
    isLogged = false;
    token = '';
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(title: Text('Do you want to exit'), actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('No')),
                FlatButton(
                    onPressed: () => SystemNavigator.pop(), child: Text('Yes'))
              ]));
      return Future.value(true);
    }
  }

  final userPool =
      CognitoUserPool(AWSUserPoolId, AWSClientId, clientSecret: secret);
  tokenFunc() {
    // Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    // // Now you can use your decoded token
    // print(decodedToken["email"]);
    // /* isExpired() - you can use this method to know if your token is already expired or not.
    //     when you have to handle sessions and want user to authenticate if token has expired */
    // bool isTokenExpired = JwtDecoder.isExpired(token);
    // if (!isTokenExpired) {
    //   // The user should authenticate
    // }
    // DateTime expirationDate = JwtDecoder.getExpirationDate(token);
    // print(expirationDate);
    // /* getTokenTime() - You can use this method to know how old your token is */
    // Duration tokenTime = JwtDecoder.getTokenTime(token);
    // print(tokenTime.inDays);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
            floatingActionButton:
                FloatingActionButton(onPressed: tokenFunc, child: Text('Test')),
            body: getWebViewCallBackMobileApp()));
  }

  Widget getWebViewCallBackMobileApp() {
    final urlSignInToken =
        "https://$COGNITO_POOL_URL.amazoncognito.com/login?response_type=token&scope=email+openid&client_id=$COGNITO_CLIENT_ID&redirect_uri=https://webapp-dev-assurly.web.app/params?apikey=webapp-b539f812-bee0-4068-8ab9-c46d9b03521a";
    final urlSignInCode =
        "https://$COGNITO_POOL_URL.amazoncognito.com/login?response_type=code&client_id=$COGNITO_CLIENT_ID&redirect_uri=https://webapp-dev-assurly.web.app/params?apikey=webapp-b539f812-bee0-4068-8ab9-c46d9b03521a";

    final urlLogOutToken =
        "https://assurly-beta.auth.eu-west-3.amazoncognito.com/logout?client_id=37uq05doga3mot25bqbg8moaia&response_type=token&scope=email+openid&redirect_uri=https://webapp-dev-assurly.web.app/params?apikey=webapp-b539f812-bee0-4068-8ab9-c46d9b03521a";
    final urlLogOutCode =
        "https://assurly-beta.auth.eu-west-3.amazoncognito.com/logout?client_id=37uq05doga3mot25bqbg8moaia&response_type=code&scope=email+openid&redirect_uri=https://webapp-dev-assurly.web.app/params?apikey=webapp-b539f812-bee0-4068-8ab9-c46d9b03521a";

    return isLogged
        ? Center(child: Text('woop woop'))
        : WebView(
            initialUrl: urlSignInToken,
            userAgent: 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) ' +
                'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controllerCompleter.future.then((value) => _controller = value);
              _controllerCompleter.complete(webViewController);
            },
            navigationDelegate: (NavigationRequest request) {
              if (request.url.contains("webapp-dev-assurly.web.app/")) {
                //print('request.url ${request.url}');
                String _token = request.url.substring(
                    "//webapp-dev-assurly.web.app/params?apikey=webapp-b539f812-bee0-4068-8ab9-c46d9b03521a#id_token"
                        .length);
                //print('_token $_token');
                //print('_token.length ${_token.length}');
                if (_token.isNotEmpty && _token.length > 800) {
                  setState(() => isLogged = true);
                  setState(() => token = _token);
                }
              }
              //if (request.url.contains("token=")) {
              //  String code = request.url.substring("myapp://?code=".length);
              //  print('test code2');
              //  signUserInWithAuthCode(code);
              //  print('test code3');
              //  return NavigationDecision.prevent;
              //}
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              print("onLoadStart popup $url");
            },
            onPageFinished: (String url) {
              print("onPageFinished popup $url");
            },
            gestureNavigationEnabled: true,
          );
  }

  // NavigationDecision _interceptNavigation(NavigationRequest request) {
  //   if (request.url == "https://github.com/flutter/flutter/issues") {
  //     return NavigationDecision.prevent;
  //   }
  //   if (request.url.contains("umuieme")) {
  //     print('wesh');
  //     return NavigationDecision.prevent;
  //   }
  //   return NavigationDecision.navigate;
  // }

  Future signUserInWithAuthCode(String authCode) async {
    // this was static ??
    print("in signUserWithAuthCode");
    String url = "https://$COGNITO_POOL_URL" +
        ".amazoncognito.com/oauth2/token?grant_type=authorization_code&client_id=" +
        "$COGNITO_CLIENT_ID&code=" +
        authCode +
        "&redirect_uri=myapp://";
    final response = await http.post(url,
        body: {},
        headers: {'Content-Type': 'application/x-www-form-urlencoded'});
    if (response.statusCode != 200) {
      throw Exception("Received bad status code from Cognito for auth code:" +
          response.statusCode.toString() +
          "; body: " +
          response.body);
    }

    final tokenData = json.decode(response.body);
    final idToken = CognitoIdToken(tokenData['id_token']);
    final accessToken = CognitoAccessToken(tokenData['access_token']);
    final refreshToken = CognitoRefreshToken(tokenData['refresh_token']);
    final session =
        CognitoUserSession(idToken, accessToken, refreshToken: refreshToken);
    print('tokenData $tokenData');
    print('idToken $idToken');
    print('accessToken $accessToken');
    print('refreshToken $refreshToken');
    final user = CognitoUser(null, userPool, signInUserSession: session);

    // NOTE: in order to get the email from the list of user attributes, make sure you select email in the list of
    // attributes in Cognito and map it to the email field in the identity provider.
    final attributes = await user.getUserAttributes();
    for (CognitoUserAttribute attribute in attributes) {
      if (attribute.getName() == "email") {
        user.username = attribute.getValue();
        break;
      }
    }

    return user;
  }
}
