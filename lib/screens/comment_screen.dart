import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/posts_repo.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/models/comment.dart';
import 'package:flutter_instagram_clone/models/post.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({Key? key, required this.postData}) : super(key: key);
  final Post postData;

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController commentController = TextEditingController();
  final userController = Get.find<AppUserController>();
  bool isRefreshing = true;
  bool isEmpty = true;
  Comment? createRequest;
  late List<Comment> postComments;

  Future<void> getAllPostComments() async {
    if (widget.postData.commentCount > 0) {
      PostsRepo.findAllCommentsByAttribute("targetId", widget.postData.postId).then((value) => setState((() {
            postComments = value;
            isRefreshing = false;
          })));
    }
    setState(() {
      isRefreshing = false;
      postComments = [];
    });
  }

  Future<void> addNewComment() async {
    Comment commentData = Comment(
        "",
        widget.postData.postId,
        userController.appUser.value.appUserId,
        userController.appUser.value,
        commentController.text,
        TargetType.post,
        0,
        0,
        Timestamp.fromDate(DateTime.now()),
        null);
    setState(() {
      createRequest = commentData;
      postComments.insert(0, commentData);
    });
    PostsRepo.addComment(createRequest!).then((response) => setState(() {
          createRequest = null;
          postComments[0] = response;
        }));
  }

  @override
  void initState() {
    // TODO: implement initState
    getAllPostComments();

    commentController.addListener(() => setState(() => isEmpty = commentController.text.isEmpty));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: true, title: const Text("Comments")),
        body: isRefreshing
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : postComments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "No comments yet",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        Text("Start the conversation")
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: postComments.length,
                    itemBuilder: (context, index) => CommentCard(
                      commentData: postComments[index],
                      isSending: identical(createRequest, postComments[index]),
                    ),
                  ),
        bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(border: Border(top: BorderSide(width: 0.1))),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.postData.appUser!.avatarUrl),
                  radius: 20,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextField(
                    controller: commentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(border: InputBorder.none, hintText: "Add a comment..."),
                  ),
                )),
                TextButton(onPressed: isEmpty ? null : addNewComment, child: const Text('Post'))
              ],
            )),
      ),
    );
  }
}

class CommentCard extends StatefulWidget {
  const CommentCard({Key? key, required this.commentData, required this.isSending}) : super(key: key);
  final Comment commentData;
  final bool isSending;
  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isLiked = false;

  DateTime createdDate() => DateTime.fromMillisecondsSinceEpoch(widget.commentData.createdAt.millisecondsSinceEpoch);
  String formattedDate() => (DateTime.now().millisecondsSinceEpoch - createdDate().millisecondsSinceEpoch) >
          (1000 * 60 * 60 * 24)
      ? (DateTime.now().millisecondsSinceEpoch - createdDate().millisecondsSinceEpoch) < (1000 * 60 * 60 * 24 * 7)
          ? "${((DateTime.now().millisecondsSinceEpoch - createdDate().millisecondsSinceEpoch) / (1000 * 60 * 60 * 24)).ceil()} d"
          : DateFormat("dd MMMM yyyy").format(createdDate())
      : "${((DateTime.now().millisecondsSinceEpoch - createdDate().millisecondsSinceEpoch) / (1000 * 60 * 60)).ceil()} h";

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        child: ListTile(
          leading: CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(widget.commentData.appUser!.avatarUrl),
          ),
          title: RichText(
              text: TextSpan(
                  text: '${widget.commentData.appUser!.username} ',
                  style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.w500)),
                  children: [TextSpan(text: widget.commentData.comment, style: Theme.of(context).textTheme.bodyMedium)])),
          subtitle: widget.isSending
              ? const Text("Sending...")
              : Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
                        child: Text(formattedDate(), style: Theme.of(context).textTheme.bodySmall)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child:
                          GestureDetector(onTap: () {}, child: Text("Reply", style: Theme.of(context).textTheme.bodySmall)),
                    ),
                    if (widget.commentData.likesCount > 0)
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child:
                              Text("${widget.commentData.likesCount} likes", style: Theme.of(context).textTheme.bodySmall)),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child:
                            GestureDetector(onTap: () {}, child: Text("Send", style: Theme.of(context).textTheme.bodySmall)))
                  ],
                ),
          trailing: IconButton(
              iconSize: 15,
              onPressed: () {},
              icon: isLiked ? const Icon(Icons.favorite) : const Icon(Icons.favorite_outline)),
        ),
      );
}
