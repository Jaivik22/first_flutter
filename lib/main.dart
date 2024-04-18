import 'dart:io';

import 'package:first_flutter/WindowsStyleProgressBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

// #docregion platform_imports
// Import for Android features.
// ignore: depend_on_referenced_packages, unused_import
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 58, 183, 125)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Welcome Jaivik'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  late final WebViewController controller;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(
        Uri.parse('https://stgdowndev.mantratecapp.com/Download/Admin'),
        // Uri.parse('https://www.linkedin.com/in/jaivik-kotadiya-278b1419b/'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        key: UniqueKey(), // Ensure WillPopScope has a non-null key
        onWillPop: () => _exitApp(context),
        child: MaterialApp(
          home: Scaffold(
            // appBar: AppBar(
            //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            //   title: Text(widget.title),
            // ),
            body: SafeArea(
              child: WillPopScope(
                  onWillPop: () => _exitApp(context),
                  child: Stack(
                    children: [
                      WebViewWidget(controller: controller),
                      if (_isLoading)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: WindowsStyleProgressBar(key: UniqueKey()),
                        )
                    ],
                  )),
            ),
          ),
        ));
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false; // Indicate that the back action has been handled
    } else {
      bool exitConfirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Container(
            height: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Do you want to exit?"),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('yes selected');
                          Navigator.of(context).pop(true);
                        },
                        child:
                            Text("Yes", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('no selected');
                          Navigator.of(context).pop(false);
                        },
                        child:
                            Text("No", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
      if (exitConfirmed == true) {
        SystemNavigator.pop(); // Close the app
      }

      return exitConfirmed ?? false; // Default to false if dialog is dismissed
    }
  }
}
