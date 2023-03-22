import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/navigation_delegate.dart';
import 'package:flutter_html/src/replaced_element.dart';
import 'package:flutter_html/style.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import 'package:html/dom.dart' as dom;
import 'package:webview_flutter/webview_flutter.dart';

/// [IframeContentElement is a [ReplacedElement] with web content.
class IframeContentElement extends ReplacedElement {
  final String? src;
  final double? width;
  final double? height;
  final webview.NavigationDelegate? navigationDelegate;
  final UniqueKey key = UniqueKey();

  IframeContentElement({
    required String name,
    required this.src,
    required this.width,
    required this.height,
    required dom.Element node,
    required this.navigationDelegate,
  }) : super(name: name, style: Style(), node: node, elementId: node.id);
  
  webview.WebViewController? controller;
  
  @override
  Widget toWidget(RenderContext context) {
    final sandboxMode = attributes["sandbox"];
    if (controller == null) {
      controller = webview.WebViewController()
        ..setNavigationDelegate(
          webview.NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (webview.NavigationRequest request) async {
              final result =
                  await navigationDelegate!.onNavigationRequest!(webview.NavigationRequest(
                url: request.url,
                isMainFrame: request.isMainFrame,
              ));
              if (result == webview.NavigationDecision.prevent) {
                return webview.NavigationDecision.prevent;
              } else {
                return webview.NavigationDecision.navigate;
              }
            },
          ),
        )
        ..setJavaScriptMode(
          sandboxMode == null || sandboxMode == "allow-scripts"
              ? JavaScriptMode.unrestricted
              : JavaScriptMode.disabled,
        );
      if (src != null) controller!.loadRequest(Uri.parse(src!));
    }
    return Container(
      width: width ?? (height ?? 150) * 2,
      height: height ?? (width ?? 300) / 2,
      child: ContainerSpan(
        style: context.style,
        newContext: context,
        child: webview.WebViewWidget(
          controller: controller!,
          key: key,
          gestureRecognizers: {
            Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer())
          },
        ),
      ),
    );
  }
}
