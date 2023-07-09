//login
import 'dart:convert';
import 'dart:io';

import 'package:blogapp/constant.dart';
import 'package:blogapp/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

Future<ApiResponse> login(String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(loginUrl),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password});

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}

Future<ApiResponse> register(String name, String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(registerUrl), headers: {
      'Accept': 'application/json'
    }, body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}

Future<ApiResponse> getUserDetail() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(userUrl), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}

// update user profile
Future<ApiResponse> updateUser(String name, File? image) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken(); //get the token

    var request = http.MultipartRequest('POST', Uri.parse(usersUrl));
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType(
          'image',
          'jpeg',
        ), // Adjust the content type based on your image format
      ));
    }

    final response = await request.send();
    // print(request.fields);

    switch (response.statusCode) {
      case 200:
        var responseBody = await response.stream.bytesToString();
        apiResponse.data = jsonDecode(responseBody)['message'];
        break;
      case 422:
        final errors =
            jsonDecode(await response.stream.bytesToString())['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}

//get token
Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';
}

//get user id
Future<int> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('userId') ?? 0;
}

//get user id
Future<bool> logout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return await pref.remove('token');
}

//get base64 encode image
String? getStringImage(File? file) {
  if (file == null) return null;
  return base64Encode(file.readAsBytesSync());
}
