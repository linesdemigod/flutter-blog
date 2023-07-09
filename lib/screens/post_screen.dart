import 'package:blogapp/constant.dart';
import 'package:blogapp/models/api_response.dart';
import 'package:blogapp/models/post.dart';
import 'package:blogapp/screens/comment_screen.dart';
import 'package:blogapp/screens/login.dart';
import 'package:blogapp/screens/post_form.dart';
import 'package:blogapp/services/post_service.dart';
import 'package:blogapp/services/user_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<dynamic> _postList = [];
  int userId = 0;
  bool loading = true;

  //get all post
  Future<void> retrievePosts() async {
    userId = await getUserId(); //coming form user service
    ApiResponse response = await getPosts();
    if (response.error == null) {
      setState(() {
        _postList = response.data as List<dynamic>;
        loading = loading ? !loading : loading;
      });
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
    }
  }

  //post like dislike
  void _handPostLikeDislike(int postId) async {
    ApiResponse response = await likeUnlikePost(postId);

    if (response.error == null) {
      retrievePosts();
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
    }
  }

  void _handleDeletePost(int postId) async {
    ApiResponse response = await deletePost(postId);
    if (response.error == null) {
      retrievePosts();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  @override
  void initState() {
    retrievePosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            onRefresh: () {
              return retrievePosts();
            },
            child: ListView.builder(
              itemCount: _postList.length,
              itemBuilder: (BuildContext context, int index) {
                Post post = _postList[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                      image: post.user!.image != null
                                          ? DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  '$imageUrl${post.user!.image}'))
                                          : null,
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.amber),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${post.user!.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                )
                              ],
                            ),
                          ),
                          // show only when the post belong to the user
                          post.user!.id == userId
                              ? PopupMenuButton(
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.more_vert,
                                      color: Colors.black,
                                    ),
                                  ),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      // edit post
                                      //open the post forms
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => PostForm(
                                                    title: 'Edit Post',
                                                    post: post,
                                                  )));
                                    } else {
                                      // delete post
                                      _handleDeletePost(post.id ?? 0);
                                    }
                                  },
                                )
                              : const SizedBox()
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text('${post.body}'),
                      if (post.image != null)
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 180,
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                // $imageUrl/
                                // http://192.168.177.1:8000/storage
                                // image: NetworkImage('$imageUrl${post.image}'),
                                image: CachedNetworkImageProvider(
                                    '$imageUrl${post.image}'),
                                fit: BoxFit.cover),
                          ),
                        )
                      else
                        SizedBox(
                          height: post.image != null ? 0 : 10,
                        ),
                      Row(
                        children: [
                          // like post
                          kLikeAndComment(
                              post.likesCount ?? 0,
                              post.selfLiked == true
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              post.selfLiked == true
                                  ? Colors.red
                                  : Colors.black38, () {
                            _handPostLikeDislike(post.id ?? 0);
                          }),
                          Container(
                            height: 25,
                            width: 0.5,
                            color: Colors.black38,
                          ),
                          kLikeAndComment(post.commentsCount ?? 0,
                              Icons.sms_outlined, Colors.black54, () {
                            // to comment screen
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CommentScreen(
                                      postId: post.id,
                                    )));
                          })
                        ],
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 0.5,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }
}
