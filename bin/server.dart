import 'dart:convert';
import 'dart:io';

void main() async {
  // Bind to port 4040
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 4040);
  print('VisaBot local dev server running on http://${server.address.address}:${server.port}');
  print('This server updates assets/data/login_users.json directly when users sign up.');

  final jsonFile = File('assets/data/login_users.json');

  await for (HttpRequest request in server) {
    // Add CORS headers for web app integration
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    if (request.uri.path == '/users') {
      if (request.method == 'GET') {
        try {
          if (await jsonFile.exists()) {
            final content = await jsonFile.readAsString();
            request.response
              ..headers.contentType = ContentType.json
              ..write(content);
          } else {
            request.response
              ..statusCode = HttpStatus.notFound
              ..write(jsonEncode({'error': 'login_users.json file not found'}));
          }
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.internalServerError
            ..write(jsonEncode({'error': e.toString()}));
        }
      } else if (request.method == 'POST') {
        try {
          final body = await utf8.decoder.bind(request).join();
          final newUser = jsonDecode(body);

          if (!await jsonFile.exists()) {
            request.response
              ..statusCode = HttpStatus.notFound
              ..write(jsonEncode({'error': 'login_users.json file not found'}));
          } else {
            final content = await jsonFile.readAsString();
            final data = jsonDecode(content) as Map<String, dynamic>;
            final users = List.from(data['users']);

            final email = newUser['email']?.toString().toLowerCase().trim();
            final exists = users.any((u) => u['email']?.toString().toLowerCase().trim() == email);

            if (exists) {
              request.response
                ..statusCode = HttpStatus.conflict
                ..write(jsonEncode({'error': 'Email already registered'}));
            } else {
              users.add(newUser);
              data['users'] = users;

              final encoder = const JsonEncoder.withIndent('  ');
              await jsonFile.writeAsString(encoder.convert(data), flush: true);

              print('Successfully added user: $email to assets/data/login_users.json');

              request.response
                ..statusCode = HttpStatus.created
                ..headers.contentType = ContentType.json
                ..write(jsonEncode({'success': true}));
            }
          }
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.internalServerError
            ..write(jsonEncode({'error': e.toString()}));
        }
      } else {
        request.response.statusCode = HttpStatus.methodNotAllowed;
      }
    } else {
      request.response.statusCode = HttpStatus.notFound;
    }
    await request.response.close();
  }
}
