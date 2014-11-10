library shell;

import 'dart:html';
import 'dart:convert';
import 'page.dart';
import 'page-element.dart';

/**
 * Main entry point; called when a user queries an external page in the view
 */
void main() {
  queryDatabase();

}

// ~ Class Independent Definitions ............................................

/**
 * Queries the database from the session ID in the document url request and adds
 * elements to the DOM based on the queried page
 */
void queryDatabase() {

  Page result;
  String session;

  var webSocket = new WebSocket('ws://0.0.0.0:9978/ws');
  
  try {
    session = (window.location.href.toString().split(window.location.host).last).substring(3, 13);
  } catch (RangeError, stackTrace) {
    return;
  }

  webSocket.onOpen.listen((e) {
    webSocket.send('${session}');
  });

  webSocket.onMessage.listen((MessageEvent e) {
    List loadedPages = JSON.decode(e.data);

    String name;
    try {
      String page = (window.location.href.toString().split(window.location.host).last).substring(14);
      name = page.substring(0, page.length - 5);
    } catch (RangeError, stackTrace) {
      return;
    }

    for (int i = 0; i < loadedPages.length; i++) {
      if (loadedPages[i]['name'] == name) {
        result = new Page.fromJson(loadedPages[i]);

        Iterator<PageElement> elements = result.elements.iterator;
        while (elements.moveNext()) {
          document.body.appendHtml('<p class="${elements.current.type}">${elements.current.content}</p>');
        }
      }

    }

  });

}
