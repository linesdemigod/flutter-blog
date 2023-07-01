import 'dart:convert';
import 'dart:io';

import 'package:blogapp/constant.dart';
import 'package:blogapp/models/api_response.dart';
import 'package:blogapp/models/post.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'user_service.dart';

//get all post
Future<ApiResponse> getPosts() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(postsUrl), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['posts']
            .map((p) => Post.fromJson(p))
            .toList();
        //get the list of posts, map each post from the model
        apiResponse.data as List<dynamic>;
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

// create a post
Future<ApiResponse> createPost(String body, File? image) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken(); //get the token

    var request = http.MultipartRequest('POST', Uri.parse(postsUrl));
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['body'] = body;

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

    switch (response.statusCode) {
      case 200:
        var responseBody = await response.stream.bytesToString();
        apiResponse.data = jsonDecode(responseBody);
        break;
      case 422:
        final errors =
            jsonDecode(await response.stream.bytesToString())['errors'];
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

//edit a post
Future<ApiResponse> editPost(int postId, String body) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken(); //get the token
    final response = await http.put(Uri.parse('$postsUrl/$postId'), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: {
      'body': body,
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 403:
        apiResponse.data = jsonDecode(response.body)['message'];
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

// Delete post
Future<ApiResponse> deletePost(int postId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.delete(Uri.parse('$postsUrl/$postId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
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

//like or unlike post
Future<ApiResponse> likeUnlikePost(int postId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken(); //get the token
    final response = await http.post(
      Uri.parse('$postsUrl/$postId/likes'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
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
