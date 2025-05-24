// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class WYSIWYGEditor extends StatefulWidget {
  const WYSIWYGEditor({
    super.key,
    this.width,
    this.height,
    this.contentJsonString,
    required this.onSaveClicked,
  });

  final double? width;
  final double? height;
  final String? contentJsonString;
  final Future Function(String fContent) onSaveClicked;

  @override
  State<WYSIWYGEditor> createState() => _WYSIWYGEditorState();
}

class _WYSIWYGEditorState extends State<WYSIWYGEditor> {
  quill.QuillController? _contentController;
  final _editorFocusNode = FocusNode();
  final _editorScrollController = ScrollController();

  StreamSubscription? _contentControllerListener;

  String? lastSavedContent;

  @override
  void initState() {
    super.initState();
    _loadDocument();
    lastSavedContent = widget.contentJsonString;

    // Listen to changes in the QuillController
    _contentControllerListener = _contentController!.document.changes.listen((
      event,
    ) {
      setState(() {});
    });
  }

  void _loadDocument() async {
    quill.Document doc;

    // Try decoding the JSON content only if the string is not null or empty
    if (widget.contentJsonString != null &&
        widget.contentJsonString!.isNotEmpty) {
      try {
        // Try to parse the contentJsonString as JSON
        doc = quill.Document.fromJson(jsonDecode(widget.contentJsonString!));
      } catch (e) {
        // If parsing fails, fallback to a new empty document
        doc = quill.Document();
        debugPrint(
          'Invalid JSON content, fallback to empty document. Error: $e',
        );
      }
    } else {
      // Fallback to an empty document if the content string is null or empty
      doc = quill.Document();
    }

    setState(() {
      _contentController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    });
  }

  @override
  void dispose() {
    _contentController?.dispose();
    _contentControllerListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If _contentController is still null, show a loader or an empty editor
    if (_contentController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: widget.width!,
      height: widget.height!,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF2F2F2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: quill.QuillSimpleToolbar(
              controller: _contentController!,
              config: const quill.QuillSimpleToolbarConfig(
                multiRowsDisplay: false,
                color: Colors.white,
              ),
            ),
          ),
          const Divider(color: Color(0xFFF2F2F2)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
              child: quill.QuillEditor(
                focusNode: _editorFocusNode,
                controller: _contentController!,
                scrollController: _editorScrollController,
              ),
            ),
          ),
          ElevatedButton(
            child: Text('Save'),
            onPressed: () async {
              final contentDoc =
                  _contentController!.document.toDelta().toJson();
              final contentJsonString = jsonEncode(contentDoc);

              await widget.onSaveClicked(contentJsonString);

              setState(() {
                lastSavedContent = contentJsonString;
              });
              _editorFocusNode.requestFocus();
            },
          ),
        ],
      ),
    );
  }
}
