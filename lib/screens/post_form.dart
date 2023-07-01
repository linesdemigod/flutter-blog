import 'dart:io';

import 'package:blogapp/constant.dart';
import 'package:blogapp/models/api_response.dart';
import 'package:blogapp/models/post.dart';
import 'package:blogapp/services/post_service.dart';
import 'package:blogapp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'login.dart';

class PostForm extends StatefulWidget {
  // const PostForm({super.key});
  final Post? post;
  final String? title;

  const PostForm({super.key, this.post, this.title});

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController txtControllerBody = TextEditingController();
  bool loading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _createPost() async {
    // String? image = _imageFile == null ? null : getStringImage(_imageFile);
    ApiResponse response = await createPost(txtControllerBody.text, _imageFile);
    if (response.error == null) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } else if (response.error == unauthorized) {
      // ignore: use_build_context_synchronously
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        loading = !loading;
      });
    }
  }

  void _editPost(int postId) async {
    ApiResponse response = await editPost(postId, txtControllerBody.text);
    if (response.error == null) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } else if (response.error == unauthorized) {
      // ignore: use_build_context_synchronously
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        loading = !loading;
      });
    }
  }

  @override
  void initState() {
    if (widget.post != null) {
      txtControllerBody.text = widget.post!.body ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title}"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                //hide image when in edit mode
                widget.post != null
                    ? const SizedBox()
                    :
                    // ignore: sized_box_for_whitespace
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        decoration: BoxDecoration(
                          image: _imageFile == null
                              ? null
                              : DecorationImage(
                                  image: FileImage(_imageFile ?? File('')),
                                  fit: BoxFit.cover),
                        ),
                        child: Center(
                          child: IconButton(
                            icon: const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              // invoke get image function here
                              getImage();
                            },
                          ),
                        ),
                      ),
                Form(
                  key: formkey,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      controller: txtControllerBody,
                      keyboardType: TextInputType.multiline,
                      maxLines: 9,
                      validator: (val) =>
                          val!.isEmpty ? 'Post body is required' : null,
                      decoration: const InputDecoration(
                          hintText: 'Post body....',
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black38))),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: kTextButton("Post", () {
                    if (formkey.currentState!.validate()) {
                      setState(() {
                        loading = !loading;
                      });

                      if (widget.post == null) {
                        _createPost();
                      } else {
                        _editPost(widget.post!.id ?? 0);
                      }
                    }
                  }),
                )
              ],
            ),
    );
  }
}
