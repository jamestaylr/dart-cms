import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'server.dart';

/**
 * Main point of entry; creates a new authentication server
 */
void main() {
  AuthServer server =
      new AuthServer("0.0.0.0", 7663, "Authentication Server");
}

// ~ Server Definitions .......................................................

class AuthServer extends Server {
  AuthServer(String address, int port, String header) : super(
      address,
      port,
      header);

  void handleSocketRequest(String request, WebSocket socket) {
    String username = request.split(",").first;
    String password = request.split(",").last;

    if ((username == null) || (password == null)) {
      socket.add(null);
      return;
    }

    var db = new Db('mongodb://0.0.0.0:27017/main');
    DbCollection collection;

    db.open().then((value) {
      collection = db.collection("auth_data");

      return collection.findOne(where.eq("username", username));

    }).then((val) {
      if (val == null) {
        return;
      }

      List<String> values = val.values;

      if (values.elementAt(2) == password) {
        print(
            "The client provided username ${username} and password ${password} that matched. Sending API key ${values.elementAt(3)}");
        socket.add(values.elementAt(3));
        return;
      } else {
        socket.add(null);
        return;
      }

    }).then((d) {
      db.close();
    });
  }

}
