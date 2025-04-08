import 'package:flutter/material.dart';
import 'package:cash/page/community/WritePostPage.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

  final List<String> tabs = ['즐겨찾기', '전체', '인기글', '공지'];
  int currentPage = 1;

  List<Map<String, dynamic>> allPosts = [
    {'title': '전체 글 1', 'nickname': '0', 'commentCount': 0, 'time': '0', 'views': '0', 'likes': '0'},
    {'title': '전체 글 2', 'nickname': '0', 'commentCount': 0, 'time': '0', 'views': '0', 'likes': '0'},
  ];

  List<Map<String, dynamic>> popularPosts = [
    {'title': '인기글 1', 'nickname': '0', 'commentCount': 0, 'time': '0', 'views': '0', 'likes': '0'},
    {'title': '인기글 2', 'nickname': '0', 'commentCount': 0, 'time': '0', 'views': '0', 'likes': '0'},
  ];

  List<Map<String, dynamic>> noticePosts = [
    {'title': '공지글.', 'nickname': '0', 'commentCount': 0, 'time': '0', 'views': '0', 'likes': '0'},
  ];

  List<String> dropdownItems = [];
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    dropdownItems = popularPosts.map((post) => post['title'] as String).toSet().toList();
    dropdownValue = dropdownItems.isNotEmpty ? dropdownItems[0] : '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget buildNoticeItem(String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('공지', style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget buildPostItem(String title, String nickname, int commentCount, String time, String views, String likes) {
    return Column(
      children: [
        ListTile(
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nickname, style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.remove_red_eye, size: 14, color: Colors.grey),
                  SizedBox(width: 2),
                  Text(views, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(width: 8),
                  Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.grey),
                  SizedBox(width: 2),
                  Text(likes, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(width: 8),
                  Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
              SizedBox(height: 4),
              Text('$commentCount', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }

  Widget buildCommonTab(String titleText, List<Map<String, dynamic>> postList) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButton<String>(
            value: dropdownValue,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items: dropdownItems.map<DropdownMenuItem<String>>((String title) {
              return DropdownMenuItem<String>(
                value: title,
                child: Text(title),
              );
            }).toList(),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(titleText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.star_border, color: Colors.yellow[700]),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: postList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    buildNoticeItem('공지.'),
                    SizedBox(height: 8),
                  ],
                );
              } else {
                final post = postList[index - 1];
                return buildPostItem(
                  post['title'],
                  post['nickname'],
                  post['commentCount'],
                  post['time'],
                  post['views'],
                  post['likes'],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('community', style: TextStyle(fontFamily: 'Cursive', color: Colors.black)),
          centerTitle: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.yellow[700],
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.yellow[700],
                tabs: tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildCommonTab('즐겨찾기', allPosts),
            buildCommonTab('전체글', allPosts),
            buildCommonTab('BEST 인기글 (실시간)', popularPosts),
            buildCommonTab('공지사항', noticePosts),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.yellow[700],
          onPressed: () async {
            final newPost = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WritePostPage()),
            );

            if (newPost != null) {
              setState(() {
                allPosts.insert(0, newPost);
              });
            }
          },
          label: Text('글쓰기', style: TextStyle(color: Colors.black)),
          icon: Icon(Icons.edit, color: Colors.black),
        ),
      ),
    );
  }
}
