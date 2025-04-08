import 'package:flutter/material.dart';

class WritePostPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('글쓰기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: InputDecoration(
                  hintText: '내용을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String title = titleController.text;
                String content = contentController.text;

                if (title.isNotEmpty && content.isNotEmpty) {

                  Map<String, dynamic> newPost = {
                    'title': title,
                    'nickname': '0',
                    'commentCount': 0,
                    'time': '방금 전',
                    'views': '0',
                    'likes': '0',
                  };
                  Navigator.pop(context, newPost);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('제목과 내용을 모두 입력하세요')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('작성 완료', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
