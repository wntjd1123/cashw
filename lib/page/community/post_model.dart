class Post {
  final String title;
  final String nickname;
  final int commentCount;
  final int views;
  final int likes;
  final String time;

  Post({
    required this.title,
    required this.nickname,
    required this.commentCount,
    required this.views,
    required this.likes,
    required this.time,
  });

  bool get isPopular => views > 100 || likes > 50;
}
