import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cash/page/cashdeal/cashdeal.dart';
import 'package:cash/page/community/community.dart';

// 앱 시작 지점
void main() {
  runApp(MyApp());
}

// 최상위 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '캐시워크',
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansTextTheme(), // Noto Sans 폰트 사용
        primarySwatch: Colors.yellow, // 기본 테마 색상
        scaffoldBackgroundColor: Colors.grey[100], // 배경색
      ),
      home: HomePage(), // 홈 페이지로 이동
    );
  }
}

// 홈 페이지 화면
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        centerTitle: true, // 여기 추가
        title: Text(
          '홈',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: Icon(Icons.screen_lock_portrait, color: Colors.black), onPressed: () {}),
        ],
        elevation: 1,
      ),

      body: SingleChildScrollView( // 스크롤 가능한 본문
        child: Column(
          children: [
            CashCouponSection(), // 상단 캐시 정보
            DayStep(), // 하루 만보 걷기 이미지 영역
            advertisementWidget(),

            // 기능 버튼 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildCategoryButton('팬마음', Icons.favorite, () {}),
                  _buildCategoryButton('건강케어', Icons.local_hospital, () {}),
                  _buildCategoryButton('돈버는퀴즈', Icons.quiz, () {}),
                  _buildCategoryButton('동네상책', Icons.map, () {}),
                  _buildCategoryButton('쇼핑비서', Icons.shopping_bag, () {}),
                  _buildCategoryButton('언니의파우치', Icons.card_giftcard, () {}),
                  _buildCategoryButton('캐시딜', Icons.attach_money, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CashDealPage()),
                    );
                  }),
                  _buildCategoryButton('트로스트', Icons.psychology, () {}),
                  _buildCategoryButton('모두의챌린지', Icons.emoji_events, () {}),
                  _buildCategoryButton('러닝크루', Icons.directions_run, () {}),
                  _buildCategoryButton('캐시닥', Icons.health_and_safety, () {}),
                  _buildCategoryButton('팀워크', Icons.groups, () {}),
                  _buildCategoryButton('뽑기', Icons.casino, () {}),
                  _buildCategoryButton('돈버는미션', Icons.task, () {}),
                  _buildCategoryButton('캐시리뷰', Icons.rate_review, () {}),
                  _buildCategoryButton('과민보스', Icons.emoji_emotions, () {}),
                  _buildCategoryButton('커뮤니티', Icons.forum, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CommunityPage()),
                    );
                  }),
                  _buildCategoryButton('캐시웨어', Icons.inventory, () {}),
                ],
              ),

            ),
            // 친구 초대 배너
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: GestureDetector(
                onTap: () {
                  print("친구 초대 배너 클릭됨!");
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/chode.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),


            _buildCouponSection(),
            _buildQuizSection(), // 돈 버는 꿀팁// 모바일 교환권
            CashDealSection(), // 캐시딜 인기상품
            _buildBestPostsSection(), // 인기글 섹션 추가

          ],
        ),
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.yellow[700],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '캐시톡'),
          BottomNavigationBarItem(icon: Icon(Icons.cached), label: '혜택'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: '교환권'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }


  // 기능 버튼 UI 생성 함수
  Widget _buildCategoryButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }


  Widget _buildQuizSection() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('돈버는퀴즈', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: Text('더보기 >', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildCountdownTimer(),
          Divider(),
          _buildQuiz(
            detail: '',
            participants: '',
            cash: '',
          ),
          _buildQuiz(
            detail: '',
            participants: '',
            cash: '',
          ),
          _buildQuiz(
            detail: '',
            participants: '',
            cash: '',
          ),
        ],
      ),
    );
  }

// 타이머 위젯
  Widget _buildCountdownTimer() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('다음 퀴즈까지 남은 시간 🕓 ', style: TextStyle(color: Colors.white)),
          Text('0 : 0 : 0', style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

// 퀴즈 항목 위젯
  Widget _buildQuiz({
    required String detail,
    required String participants,
    required String cash,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text('진행중', style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
      title: Text(detail, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: [
          Icon(Icons.people, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text(participants, style: TextStyle(fontSize: 12)),
          SizedBox(width: 10),
          Icon(Icons.monetization_on, size: 14, color: Colors.orange),
          SizedBox(width: 4),
          Text(cash, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }


  // 모바일 교환권 섹션
  Widget _buildCouponSection() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('모바일 교환권', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: Text('전체보기 >', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCoupon('5,000캐시'),
              _buildCoupon('10,000캐시'),
              _buildCoupon('20,000캐시'),
            ],
          ),
        ],
      ),
    );
  }


  // 교환권 박스
  Widget _buildCoupon(String text) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 14)),
    );
  }
}

// 하루 만보 걷기 위젯
class DayStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.yellow[700], // 공백 부분을 노란색으로 채움,
      ),

      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'http://thumbnail.10x10.co.kr/webimage/image/basic600/235/B002351252.jpg?cmd=thumb&w=500&h=500&fit=true&ws=false',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Text('하루 만보 걷기', style: TextStyle(fontSize: 18, color: Colors.white)),
              Text('0 걸음', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('0 kcal   0 분   0 m', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
// 광고 배너 섹션 위젯
class advertisementWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // 여백 조정
      child: GestureDetector(
        onTap: () {
          print("광고 배너 클릭됨!"); // 클릭 이벤트 처리
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12), // 둥근 모서리 적용
          child: Image.network(
            'https://via.placeholder.com/350x100.png?text=Ad+Banner', // 샘플 배너 이미지
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// 캐시 쿠폰 표시 섹션
class CashCouponSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow[700],
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('C 0캐시', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () {},
            child: Text('내 쿠폰함', style: TextStyle(fontSize: 16, color: Colors.blue[900])),
          ),
        ],
      ),
    );
  }
}



// 캐시딜 섹션
class CashDealSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('캐시딜 인기상품', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: PageView.builder(
              itemCount: 4,
              itemBuilder: (context, index) => _buildCashDealPage(),
            ),
          ),
        ],
      ),
    );
  }

  // 각 페이지에 들어갈 리스트
  Widget _buildCashDealPage() {
    return ListView.builder(
      itemCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildCashDealItem(),
    );
  }

  // 캐시딜 아이템 UI
  Widget _buildCashDealItem() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            'https://cdn.pixabay.com/photo/2022/11/27/18/01/flower-7620426_640.jpg',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text('[만원의행복] 경북 햇 부사 사과'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('0% 0원', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            Text('P 0 적립 | 무료배송', style: TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Icon(Icons.star, color: Colors.yellow[700]),
      ),
    );
  }
}
// BEST 인기글 섹션
Widget _buildBestPostsSection() {
  final List<Map<String, dynamic>> bestPosts = [
    {'rank': '01', 'title': '', 'comment': 0},
    {'rank': '02', 'title': '', 'comment': 0},
    {'rank': '03', 'title': '', 'comment': 0},
    {'rank': '04', 'title': '', 'comment': 0},
    {'rank': '05', 'title': '', 'comment': 0},
    {'rank': '06', 'title': '', 'comment': 0},
    {'rank': '07', 'title': '', 'comment': 0},
    {'rank': '08', 'title': '', 'comment': 0},
    {'rank': '09', 'title': '', 'comment': 0},
    {'rank': '10', 'title': '', 'comment': 0},
  ];

  return Container(
    margin: EdgeInsets.all(10),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('BEST 인기글(실시간)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {},
              child: Text('더보기 >', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        Text('우리 같이 소통해요', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        SizedBox(height: 10),
        ...bestPosts.map((post) => _buildBestPostItem(post)).toList(),
      ],
    ),
  );
}

// 인기글 항목 UI
Widget _buildBestPostItem(Map<String, dynamic> post) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.5),
    child: Row(
      children: [
        Text(post['rank'], style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            post['title'],
            style: TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 5),
        Text(
          '[${post['comment']}]',
          style: TextStyle(color: Colors.red, fontSize: 13),
        ),
      ],
    ),
  );
}
