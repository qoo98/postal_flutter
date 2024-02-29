import 'package:http/http.dart' as http;

Future<http.Response> fetchResult(String uri) async {
  final response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    return response;
  } else if (response.statusCode == 400) {
    throw Exception('Bad Request');
  } else if (response.statusCode == 500) {
    throw Exception('Internal Server Error');
  } else {
    throw Exception('Unknown Error');
  }
}

