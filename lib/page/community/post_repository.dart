import 'post_model.dart';

class PostRepository {
  static List<Post> allPosts = [];
  static List<Post> get popularPosts =>
      allPosts.where((post) => post.isPopular).toList();
  static List<Post> get noticePosts =>
      allPosts.where((post) => post.title.contains('[공지]')).toList();
}
