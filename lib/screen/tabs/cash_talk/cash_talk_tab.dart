import 'package:flutter/material.dart';
import 'package:cash/screen/tabs/cash_talk/chat_tab.dart';
import 'package:cash/screen/tabs/cash_talk/ranking_tab.dart';

class CashTalkTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 탭 3개
      child: Scaffold(
        appBar: AppBar(
          title: Text('캐시톡'),
          backgroundColor: Colors.yellow[700],
          centerTitle: true,
        ),
        body: TabBarView(
          children: [
            // 친구 화면
            ListView(
              padding: EdgeInsets.all(16),
              children: [
                Container(
                  height: 100,
                  color: Colors.grey[300],
                  child: Center(child: Text('')),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.yellow[700],
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                    SizedBox(width: 8),
                    Text('', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('추천 0'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('추천 친구 바로가기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.yellow[700],
                    child: Icon(Icons.verified, color: Colors.black),
                  ),
                  title: Text(''),
                  subtitle: Text('.'),
                ),
                SizedBox(height: 16),
                Text('오늘의 행운 친구 🍀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (index) {
                      return Container(
                        width: 80,
                        margin: EdgeInsets.only(right: 8),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.person, color: Colors.black),
                            ),
                            SizedBox(height: 4),
                            Text('친구 ${index + 1}', overflow: TextOverflow.ellipsis),
                            TextButton(
                              onPressed: () {},
                              child: Text('친구추가'),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Text(
                        '앗, 캐시톡 친구가 없어요.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '지금 친구를 맺고 캐시를 주고받아보세요.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '캐시톡 친구를 만날 수 있는 가장 빠른 방법!',
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.group_add),
                        label: Text('캐시톡 친구 모집 게시판'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          foregroundColor: Colors.black,
                          minimumSize: Size(250, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 채팅 화면
            ChatTab(),

            // 랭킹 화면
            RankingTab(),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.grey[100],
          child: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.yellow[700],
            tabs: [
              Tab(icon: Icon(Icons.person), text: '친구'),
              Tab(icon: Icon(Icons.chat), text: '채팅'),
              Tab(icon: Icon(Icons.leaderboard), text: '랭킹'),
            ],
          ),
        ),
      ),
    );
  }
}
