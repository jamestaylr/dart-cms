library index;

import 'package:polymer/polymer.dart';
import 'package:cookie/cookie.dart' as cookie;
import 'dart:html';

// ~ Polymer Element Definitions ..............................................

// ----------------------------------------------------------
/**
 * Defines the functions for the 'auth-input' polymer element
 */
@CustomTag('auth-input')
class AuthInput extends PolymerElement {

  @observable String username = '';
  @observable String password = '';
  @observable String status = '';

  AuthInput.created() : super.created();

  // ----------------------------------------------------------
  /**
   * Called when the login button or enter is pressed
   */
  void login(Event e, var detail, Node target) {

    if (e is KeyboardEvent) {
      int code = e.keyCode;
      switch (code) {
        case 13:
          {
            transmitToSocket();
            break;
          }
      }
    } else if (e is MouseEvent) {
      transmitToSocket();
    }
  }

  // ----------------------------------------------------------
  /**
   * Transmits the captured username and password to the web socket
   */
  void transmitToSocket() {
    var webSocket = new WebSocket('ws://0.0.0.0:7663/ws');

    webSocket.onOpen.listen((e) {
      webSocket.send('${username},${password}');
    });
    
    webSocket.onClose.listen((e) {
      status = "Failed to connect! Please try again in a little while.";
    });

    webSocket.onMessage.listen((MessageEvent e) {

      if (e.data != "") {
        cookie.set('session', e.data, expires: 1, path: '/');
        window.location.assign('app/');
      } else {
        password = "";
        status = "Incorrect password, please try again.";
      }
      
    });
  }

}
