import 'dart:io';

// ~ Server Definitions .......................................................

/**
 * Performs setup operations on the server, including binding to a WebSocket
 * port address
 */
class Server {
  
  Server(String address, int port, String header) {
    HttpServer.bind(address, port).then((HttpServer server) {
      print("HTTP Server is listening on ${address}:${port}...");
      server.serverHeader = header;
      server.listen((HttpRequest request) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          WebSocketTransformer.upgrade(request).then((socket) {
            print('Client connected!');
            socket.listen((String s) {
              print('Client sent: $s');
              handleSocketRequest(s, socket);
            }, onDone: () {
              print('Client disconnected');
            });
          });
        } else {
          print("Regular ${request.method} request for: ${request.uri.path}");
          request.response.statusCode = HttpStatus.FORBIDDEN;
          request.response.reasonPhrase = "WebSocket connections only";
          request.response.close();
        }
      });
    });
  }

  void handleSocketRequest(String request, WebSocket socket) {
    return null;
  }

}
