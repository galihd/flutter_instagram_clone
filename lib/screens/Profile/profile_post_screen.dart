import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/components/feeds.dart';
import 'package:flutter_instagram_clone/models/post.dart';

class ProfilePostScreen extends StatelessWidget {
  const ProfilePostScreen({Key? key, required this.userPosts}) : super(key: key);
  final List<Post> userPosts;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('Posts'),
        ),
        body: Column(
          children: [
            Feeds(postsList: userPosts),
          ],
        ));
  }
}
