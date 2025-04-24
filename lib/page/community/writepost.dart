import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class WritePostPage extends StatefulWidget {
  const WritePostPage({super.key});

  @override
  State<WritePostPage> createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final _titleController = TextEditingController();
  final quill.QuillController _quillController = quill.QuillController.basic();

  String _selectedBoard = '전체';
  bool _isSubmitting = false;

  final List<String> _boards = ['전체', '인기글', '공지사항'];

  void _submitPost() {
    FocusScope.of(context).unfocus();

    final title = _titleController.text.trim();
    final content = _quillController.document.toPlainText().trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pop(context, {
        'title': '[$_selectedBoard] $title',
        'content': content,
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _topYellowBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('게시판', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedBoard,
                      items: _boards.map((board) {
                        return DropdownMenuItem(value: board, child: Text(board));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedBoard = val!),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text('제목', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: '제목을 입력해주세요',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text('내용', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          quill.QuillToolbar.simple(
                            configurations: quill.QuillSimpleToolbarConfigurations(
                              controller: _quillController,
                              multiRowsDisplay: false,
                              showFontSize: true,
                              showFontFamily: true,
                              showColorButton: true,
                              showBackgroundColorButton: true,
                              showBoldButton: true,
                              showItalicButton: true,

                              showClearFormat: true,
                              showAlignmentButtons: true,
                              showListCheck: true,
                              showListBullets: true,
                              showListNumbers: true,
                              showQuote: true,
                              showCodeBlock: true,
                              showIndent: true,
                              showLink: true,

                              showUndo: true,
                              showRedo: true,
                            ),
                          ),


                          const SizedBox(height: 8),
                          Container(
                            height: 280,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: quill.QuillEditor.basic(
                              configurations: quill.QuillEditorConfigurations(
                                controller: _quillController,
                                scrollable: true,
                                expands: false,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEB00),
                            foregroundColor: Colors.black,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text('완료'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topYellowBar() {
    return Container(
      color: const Color(0xFFFFEB00),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '커뮤니티',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // 아이콘 자리 확보용
        ],
      ),
    );
  }
}
