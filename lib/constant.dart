//--- STRING --//
import 'package:flutter/material.dart';

const baseUrl = "http://your-ip:8000/api";
const loginUrl = "$baseUrl/login";
const registerUrl = "$baseUrl/register";
const logoutUrl = "$baseUrl/logout";
const userUrl = "$baseUrl/user";
const usersUrl = "$baseUrl/users";
const postsUrl = "$baseUrl/posts";
const commentsUrl = "$baseUrl/comments";
const imageUrl = 'http://your-id:8000/storage/';

//--Errors---
const serverError = "Server error";
const unauthorized = "Unauthorized";
const somethingWentWrong = "Something went wrong, try again!";

//---input decoration
InputDecoration kInputDecoration(String label) {
  return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.all(10),
      border: const OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.black)));
}

TextButton kTextButton(String label, Function onPressed) {
  return TextButton(
    style: ButtonStyle(
        backgroundColor:
            MaterialStateColor.resolveWith((states) => Colors.blue),
        padding: MaterialStateProperty.resolveWith(
            (states) => const EdgeInsets.symmetric(vertical: 10))),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white),
    ),
    onPressed: () => onPressed(),
  );
}

//loginRegisterHint
Row kLoginRegisterHint(String text, String label, Function onTap) {
  return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(text),
    GestureDetector(
      child: Text(
        label,
        style: const TextStyle(color: Colors.blue),
      ),
      onTap: () => onTap(),
    )
  ]);
}

//likes and comment btn
Expanded kLikeAndComment(
    int value, IconData icon, Color color, Function onTap) {
  return Expanded(
    child: Material(
        child: InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(
              width: 4,
            ),
            Text('$value'),
          ],
        ),
      ),
    )),
  );
}
