import 'package:flutter/material.dart';
import 'post_model.dart';

class Reply {
  final String nickname;
  final String content;
  final String time;

  Reply({
    required this.nickname,
    required this.content,
    required this.time,
  });
}

class Comment {
  final String nickname;
  final String content;
  final String time;
  int likes;
  int dislikes;
  List<Reply> replies;

  Comment({
    required this.nickname,
    required this.content,
    required this.time,
    this.likes = 0,
    this.dislikes = 0,
    this.replies = const [],
  });
}

class PostDetailWidget extends StatefulWidget {
  final Post post;

  const PostDetailWidget({super.key, required this.post});

  @override
  State<PostDetailWidget> createState() => _PostDetailWidgetState();
}

class _PostDetailWidgetState extends State<PostDetailWidget> {
  late int recommendCount;
  int disrecommendCount = 0;
  bool isScrapped = false;

  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  List<Comment> comments = [];
  int? replyingToIndex;

  @override
  void initState() {
    super.initState();
    recommendCount = widget.post.likes;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        comments.add(
          Comment(
            nickname: '익명${comments.length + 1}',
            content: text,
            time: '방금 전',
          ),
        );
        _commentController.clear();
      });
    }
  }

  void _submitReply(int index) {
    final text = _replyController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        comments[index].replies = [
          ...comments[index].replies,
          Reply(
            nickname: '익명${comments.length + 1}',
            content: text,
            time: '방금 전',
          ),
        ];
        _replyController.clear();
        replyingToIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 + 메뉴
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.post.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$value 선택됨')),
                    );
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: '쪽지 보내기', child: Text('쪽지 보내기')),
                    const PopupMenuItem(value: '차단', child: Text('차단')),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 닉네임 + 작성시간
            Row(
              children: [
                Text(widget.post.nickname, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Text(widget.post.time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),

            // 조회수, 추천수, 스크랩수
            Row(
              children: [
                Text('조회 ${widget.post.views}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 8),
                Text('추천 $recommendCount', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 8),
                const Text('스크랩 0', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),

            const Divider(height: 24),

            // 본문
            Text(widget.post.content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // 추천 / 비추천 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          recommendCount++;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber,
                        ),
                        child: const Icon(Icons.thumb_up, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('$recommendCount', style: const TextStyle(fontSize: 13)),
                    const Text('추천', style: TextStyle(fontSize: 11)),
                  ],
                ),
                const SizedBox(width: 40),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          disrecommendCount++;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Icon(Icons.thumb_down, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('$disrecommendCount', style: const TextStyle(fontSize: 13)),
                    const Text('비추천', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 스크랩 / 공유 아이콘
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isScrapped = !isScrapped;
                    });
                  },
                  icon: Icon(
                    isScrapped ? Icons.bookmark : Icons.bookmark_border,
                    color: isScrapped ? Colors.amber : Colors.grey,
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.share, color: Colors.grey),
              ],
            ),

            const Divider(height: 24),

            // 댓글 작성창
            Text('댓글 ${comments.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.photo),
                ),
                ElevatedButton(
                  onPressed: _submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEB00),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('등록'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 댓글 리스트
            ...comments.map((comment) {
              final index = comments.indexOf(comment);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 댓글 기본
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(comment.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      PopupMenuButton<String>(
                        onSelected: (value) {},
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: '쪽지', child: Text('쪽지 보내기')),
                          const PopupMenuItem(value: '차단', child: Text('차단')),
                        ],
                        icon: const Icon(Icons.more_vert, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(comment.content, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(comment.time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            replyingToIndex = index;
                          });
                        },
                        child: const Text('답글 쓰기', style: TextStyle(fontSize: 12)),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                comment.likes++;
                              });
                            },
                            icon: const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
                          ),
                          Text('${comment.likes}', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                comment.dislikes++;
                              });
                            },
                            icon: const Icon(Icons.thumb_down_alt_outlined, size: 16, color: Colors.grey),
                          ),
                          Text('${comment.dislikes}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  // 답글 입력창
                  if (replyingToIndex == index) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyController,
                            decoration: const InputDecoration(
                              hintText: '답글을 입력하세요',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _submitReply(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEB00),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('등록'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 답글 리스트
                  ...comment.replies.map((reply) => Padding(
                    padding: const EdgeInsets.only(left: 40, top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, size: 12, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            Text(reply.nickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(reply.content, style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(reply.time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  )),
                  const Divider(height: 24),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
