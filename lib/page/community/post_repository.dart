import 'package:cash/page/community/post_model.dart';

class PostRepository {
  static List<Post> allPosts = [
    Post(
      title: '[전체] aa',
      nickname: '익명1',
      commentCount: 3,
      views: 45,
      likes: 12,
      time: '방금 전',
      content: 'aa.',
    ),
    Post(
      title: '[전체] bb',
      nickname: '익명2',
      commentCount: 1,
      views: 20,
      likes: 5,
      time: '1분 전',
      content: 'bb.',
    ),
  ];

  static List<Post> popularPosts = [
    Post(
      title: '[인기글] aa',
      nickname: '익명3',
      commentCount: 5,
      views: 100,
      likes: 50,
      time: '5분 전',
      content: 'aa.',
    ),
  ];

  static List<Post> noticePosts = [
    Post(
      title: '[공지] bb',
      nickname: '관리자',
      commentCount: 0,
      views: 200,
      likes: 30,
      time: '10분 전',
      content: 'bb.',
    ),
  ];
}
