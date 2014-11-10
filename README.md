## Dart CMS

This project is an example of a server-side and client-side implementation of the Dart language to create, edit, and remove pages dynamically.

----------
### Introduction

Dart is a flexible language that can act as both a server-side script-driven language while also running in a light VM on the client very similar to Javascript.

This project was conducted as a side project to learn about the language and contains a working example of a CMS from start to finish.

### Prerequisites

The `dart-sdk` must be installed on the device running the server. Proper setup of the sdk ensures the `pub serve` and `dart dartfile.dart` commands to work properly.

A `MongoDB` database must be running on the server, using the default port. This database should be setup with collections of `{username, password, unique_key}` for the authentication server to use. Otherwise, the database can be left empty.

Run the shell (`launch.sh` and `launch-servers.sh`) files to launch the servers used for authentication, querying the database, and reading from the database along with the main project served through `dart pub`. Note that this implementation is modular and could be changed out for an `OAuth` protocol instead of conducting the authentication explicitly, for example.

### Operation

Users will login to the page located at root. This is the entry point. If the validation of user-provided data is successful, a session key will be returned and stored as a cookie. The user is redirected to `/app/` where the cookie is read back in and `Dart polymer` components initialized. Users can click and drag components in the left element pane, edit content, etc. to produce a page.

The resulting user operations will be pushed as `JSON` to the `dataserver` and stored in the `MongoDB` database. A shell will be constructed in the `/u/` directory. When this page is queried publicly (outside the editor), the database will be called, content will be loaded, and the view will be constructed.

> **Note:** In order to deploy the server, make sure all host references are correct.