import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'server.dart';

/**
 * Main point of entry; creates a new query server
 */
void main() {
  QueryServer server =
      new QueryServer("0.0.0.0", 9978, "Database Query Server");
}

// ~ Server Definitions .......................................................

class QueryServer extends Server {
  QueryServer(String address, int port, String header) : super(
      address,
      port,
      header);

  void handleSocketRequest(String request, WebSocket socket) {
    String session = request;

    var db = new Db('mongodb://0.0.0.0:27017/main');
    DbCollection collection;

    if (session == null) {
      return;
    }

    db.open().then((value) {
      collection = db.collection("content_data");

      return collection.findOne(where.eq("session", session));

    }).then((val) {

      if (val == null) {
        return;
      }

      List<String> values = val.values;

      print(
          "Returned ${values.elementAt(2)} from page call with API key ${session}");
      socket.add(values.elementAt(2));

    }).then((d) {

      db.close();

    });
  }

}
