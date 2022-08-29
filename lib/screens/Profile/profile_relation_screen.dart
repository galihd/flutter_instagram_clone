import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/appuser_repo.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/components/auth_input.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';
import 'package:flutter_instagram_clone/models/follow.dart';

class ProfileRelationScreen extends StatelessWidget {
  const ProfileRelationScreen({Key? key, required this.args}) : super(key: key);
  final ProfileRelationArguments args;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: args.initialIndex,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(args.userData.username),
            automaticallyImplyLeading: true,
            bottom: TabBar(tabs: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Text('${args.followers.length} followers'),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Text('${args.following.length} following'),
              ),
            ]),
          ),
          body: TabBarView(
            children: [
              args.followers.isNotEmpty
                  ? FutureBuilder(
                      future: AppUsersRepo.findAllAppUserByIds(args.followers.map((e) => e.fromUserId).toList()),
                      builder: (BuildContext context, AsyncSnapshot<List<AppUser>> snapshot) =>
                          snapshot.connectionState == ConnectionState.done && snapshot.hasData
                              ? FollowerList(followData: snapshot.data!)
                              : const CircularProgressIndicator(),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "No follows yet",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                          Text("Start the conversation")
                        ],
                      ),
                    ),
              args.following.isNotEmpty
                  ? FutureBuilder(
                      future: AppUsersRepo.findAllAppUserByIds(args.following.map((e) => e.fromUserId).toList()),
                      builder: (BuildContext context, AsyncSnapshot<List<AppUser>> snapshot) =>
                          snapshot.connectionState == ConnectionState.done && snapshot.hasData
                              ? FollowerList(followData: snapshot.data!)
                              : const CircularProgressIndicator(),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "No follows yet",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                          Text("Start the conversation")
                        ],
                      ),
                    )
            ],
          ),
        ));
  }
}

class FollowerList extends StatefulWidget {
  const FollowerList({Key? key, required this.followData}) : super(key: key);
  final List<AppUser> followData;
  @override
  State<FollowerList> createState() => _FollowerListState();
}

class _FollowerListState extends State<FollowerList> {
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          title: SizedBox(
            width: double.infinity,
            height: 40,
            child: TextField(
              controller: searchController,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search",
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle()),
            ),
          ),
          backgroundColor: Theme.of(context).cardColor,
          titleTextStyle: Theme.of(context).textTheme.titleSmall,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            widget.followData
                .map((follow) => ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(follow.avatarUrl),
                      ),
                      title: Text(follow.username),
                      onTap: () => Navigator.pushNamed(context, MainStackRoutes.profile, arguments: follow.appUserId),
                    ))
                .toList(),
          ),
        )
      ],
    );
  }
}
