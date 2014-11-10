import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'server.dart';
import 'dart:convert';

/**
 * Main point of entry; creates a new data server
 */
void main() {
  DataServer server =
      new DataServer("0.0.0.0", 9878, "Database Update Server");
}

// ~ Server Definitions .......................................................

class DataServer extends Server {
  DataServer(String address, int port, String header) : super(
      address,
      port,
      header);

  void handleSocketRequest(String request, WebSocket socket) {
    String session = request.split(",").first;
    String json = request.substring(((request.split(",").first).length) + 1);

    var db = new Db('mongodb://0.0.0.0:27017/main');
    DbCollection collection;

    db.open().then((value) {
      collection = db.collection("content_data");

      return collection.findOne(where.eq("session", session));

    }).then((val) {

      if (val != null) {
        collection.remove(val);
      }

      // anon users can edit pages

      collection.insert({
        "session": session,
        "content": json
      });

      List loadedPages = JSON.decode(json);

      for (int i = 0; i < loadedPages.length; i++) {

        Map jsonMap = loadedPages[i];
        String name = jsonMap['name'];

        new File(
            '../u/${session}/${name}.html').create(
                recursive: true)// The created file is returned as a Future.
        .then((file) {
          print("File created at: ${file.path}");
          return file.openWrite(mode: FileMode.WRITE, encoding: UTF8);
        }).then((file) {

          String template =
              "<!DOCTYPE html><html><head><meta charset=\"utf-8\">";
          template +=
              "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">";
          template +=
              "<link type=\"text/css\" rel=\"stylesheet\" href=\"../../css/reset.css\">";
          template +=
              "<link type=\"text/css\" rel=\"stylesheet\" href=\"../../fonts/fonts.css\">";
          template +=
              "<link type=\"text/css\" rel=\"stylesheet\" href=\"../../css/shell.css\">";
          template +=
              "</head><body><script type=\"application/dart\" src=\"../../dart/shell.dart\">";
          template +=
              "</script><script src=\"packages/browser/dart.js\"></script></body></html>";
          file.write(template);
        });
      }

      print("Updated ${session} with ${json}");

    }).then((d) {

      db.close();

    });
  }

}
