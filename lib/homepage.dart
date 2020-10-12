
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';



class HomePage extends StatefulWidget {


  @override
  _HomePageState createState() =>
      new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InAppWebViewController webView;
  ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  CookieManager _cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(androidId: 1, iosId: "1", title: "Special", action: () async {
            print("Menu item Special clicked!");
            print(await webView.getSelectedText());
            await webView.clearFocus();
          })
        ],
        options: ContextMenuOptions(
            hideDefaultSystemContextMenuItems: true
        ),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webView.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid) ? contextMenuItemClicked.androidId : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: " + id.toString() + " " + contextMenuItemClicked.title);
        }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor:Colors.black,
        appBar: AppBar(backgroundColor: Colors.deepPurple,
            title: Text("Sermons")
        ),
        //drawer: myDrawer(context: context),
        body: SafeArea(
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Text("Listen to Our Sermons for  Spiritual nourishment", style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
                ),
              ),
              Container(
                  padding: EdgeInsets.all(10.0),
                  child: progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container()),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration:
                  BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                  child: InAppWebView(
                      contextMenu: contextMenu,
                      initialUrl: "https://drive.google.com/folderview?id=1BSGf6TKV7mv-2caTa4DsczwUFNQLNVJB",
                      // initialFile: "assets/index.html",

                      initialHeaders: {},
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          debuggingEnabled: true,
                          useShouldOverrideUrlLoading: true,
                            useOnDownloadStart: true
                        ),
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        webView = controller;
                        print("onWebViewCreated");
                      },
                      onLoadStart: (InAppWebViewController controller, String url) {
                        print("onLoadStart $url");
                        setState(() {
                          this.url = url;
                        });
                      },
                      shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
                        var url = shouldOverrideUrlLoadingRequest.url;
                        var uri = Uri.parse(url);

                        if (!["http", "https", "file",
                          "chrome", "data",
                          "about"].contains(uri.scheme)) {
                          if (await canLaunch(url)) {
                            // Launch the App
                            await launch(
                              url,
                            );
                            // and cancel the request
                            return ShouldOverrideUrlLoadingAction.CANCEL;
                          }
                        }

                        return ShouldOverrideUrlLoadingAction.ALLOW;
                      },
                      onLoadStop: (InAppWebViewController controller, String url) async {
                        print("onLoadStop $url");
                        setState(() {
                          this.url = url;
                        });
                      },

                      onDownloadStart: (controller, url) async {
                        print("onDownloadStart $url");
                        final taskId = await FlutterDownloader.enqueue(
                          url: url,
                          savedDir: (await getExternalStorageDirectory()).path,
                          showNotification: true, // show download progress in status bar (for Android)
                          openFileFromNotification: true, // click on notification to open downloaded file (for Android)
                        );
                      },
                      onProgressChanged: (InAppWebViewController controller, int progress) {
                        setState(() {
                          this.progress = progress / 100;
                        });
                      },
                      onUpdateVisitedHistory: (InAppWebViewController controller, String url, bool androidIsReload) {
                        print("onUpdateVisitedHistory $url");
                        setState(() {
                          this.url = url;
                        });
                      }
                  ),
                ),
              ),
//              ButtonBar(
//                alignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  RaisedButton(
//                    child: Icon(Icons.arrow_back),
//                    onPressed: () {
//                      if (webView != null) {
//                        webView.goBack();
//                      }
//                    },
//                  ),
//                  RaisedButton(
//                    child: Icon(Icons.arrow_forward),
//                    onPressed: () {
//                      if (webView != null) {
//                        webView.goForward();
//                      }
//                    },
//                  ),
//                  RaisedButton(
//                    child: Icon(Icons.refresh),
//                    onPressed: () {
//                      if (webView != null) {
//                        webView.reload();
//                      }
//                    },
//                  ),
//                ],
//              ),
            ]))
    );
  }
}