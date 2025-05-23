import 'package:flutter/material.dart';

enum QuestionType { text, checkbox, attachment }

class QuestionData {
  final String id;
  QuestionType type;
  String title;
  bool required;
  List<String>? options; // For checkbox
  QuestionData({
    String? id,
    required this.type,
    this.title = '',
    this.required = false,
    this.options,
  }) : id = id ?? UniqueKey().toString();
}

class AddFormDialog extends StatefulWidget {
  final void Function(
    String formTitle,
    String formName,
    String formDescription,
    List<QuestionData> questions,
  )?
  onSubmit;
  final String projectId;

  const AddFormDialog({super.key, this.onSubmit, required this.projectId});

  @override
  State<AddFormDialog> createState() => _AddFormDialogState();
}

class ReferralQuestionBlock extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onToggle;

  static const List<String> options = [
    'Google Search',
    'Google Map',
    'YouTube',
    'Instagram',
    'Tiktok',
    'Facebook',
    'Snapchat',
    'Reddit',
    'Recommended by Friend or Others',
    'Other',
  ];

  const ReferralQuestionBlock({
    super.key,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E1D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'How did you hear from us?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Switch(
                value: enabled,
                activeColor: const Color(0xFFD1B06B),
                onChanged: onToggle,
              ),
            ],
          ),
          ...options.map(
            (option) => Row(
              children: [
                Checkbox(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  value: false,
                  onChanged: null, // Always disabled
                ),
                Text(
                  option,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7B7F8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFormDialogState extends State<AddFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final String _formTitle = '';
  String _formName = '';
  String _formDescription = '';
  final List<QuestionData> _questions = [];
  String? _highlightedId;
  final Color _highlightColor = const Color(0xFFFFF9C4); // light yellow
  final Map<String, GlobalKey> _questionKeys = {};
  bool _referralEnabled = true;

  void _scrollToQuestion(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _questionKeys[id];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 400),
          alignment: 0, // 0 = top
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _clearHighlightAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _highlightedId = null;
        });
      }
    });
  }

  void _addQuestion(QuestionType type) {
    setState(() {
      if (type == QuestionType.checkbox) {
        _questions.add(
          QuestionData(type: type, options: ['Option 1', 'Option 2']),
        );
      } else {
        _questions.add(QuestionData(type: type));
      }
      _highlightedId = _questions.last.id;
    });
    _clearHighlightAfterDelay();
    _scrollToQuestion(_questions.last.id);
  }

  void _moveQuestionUp(int index) {
    if (index > 0) {
      setState(() {
        final q = _questions.removeAt(index);
        _questions.insert(index - 1, q);
        _highlightedId = q.id;
      });
      _clearHighlightAfterDelay();
      _scrollToQuestion(_questions[index - 1].id);
    }
  }

  void _moveQuestionDown(int index) {
    if (index < _questions.length - 1) {
      setState(() {
        final q = _questions.removeAt(index);
        _questions.insert(index + 1, q);
        _highlightedId = q.id;
      });
      _clearHighlightAfterDelay();
      _scrollToQuestion(_questions[index + 1].id);
    }
  }

  void _copyQuestion(int index) {
    setState(() {
      final q = _questions[index];
      final newQ = QuestionData(
        type: q.type,
        title: q.title,
        required: q.required,
        options: q.options != null ? List<String>.from(q.options!) : null,
      );
      _questions.insert(index + 1, newQ);
      _highlightedId = newQ.id;
    });
    _clearHighlightAfterDelay();
    _scrollToQuestion(_questions[index + 1].id);
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _updateQuestion(int index, QuestionData data) {
    setState(() {
      _questions[index] = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add Form',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Form',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Form Name',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (v) => setState(() => _formName = v),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Form Description',
                                border: OutlineInputBorder(),
                              ),
                              onChanged:
                                  (v) => setState(() => _formDescription = v),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F6EF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE5E1D6),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Add Question',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF7B7F8A),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      _QuestionTypeButton(
                                        icon: Icons.text_fields,
                                        label: 'Text',
                                        onTap:
                                            () =>
                                                _addQuestion(QuestionType.text),
                                      ),
                                      _QuestionTypeButton(
                                        icon: Icons.attach_file,
                                        label: 'Attachment',
                                        onTap:
                                            () => _addQuestion(
                                              QuestionType.attachment,
                                            ),
                                      ),
                                      _QuestionTypeButton(
                                        icon: Icons.check_box,
                                        label: 'Checkbox',
                                        onTap:
                                            () => _addQuestion(
                                              QuestionType.checkbox,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Column(
                              children:
                                  _questions.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final q = entry.value;
                                    final key = _questionKeys.putIfAbsent(
                                      q.id,
                                      () => GlobalKey(),
                                    );
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ),
                                      child: _QuestionBlock(
                                        key: key,
                                        data: q,
                                        highlighted: q.id == _highlightedId,
                                        highlightColor: _highlightColor,
                                        onChanged:
                                            (data) =>
                                                _updateQuestion(idx, data),
                                        onRemove: () => _removeQuestion(idx),
                                        onMoveUp:
                                            idx > 0
                                                ? () => _moveQuestionUp(idx)
                                                : null,
                                        onMoveDown:
                                            idx < _questions.length - 1
                                                ? () => _moveQuestionDown(idx)
                                                : null,
                                        onCopy: () => _copyQuestion(idx),
                                      ),
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 24),
                            ReferralQuestionBlock(
                              enabled: _referralEnabled,
                              onToggle:
                                  (val) =>
                                      setState(() => _referralEnabled = val),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD1B06B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: Theme.of(context).textTheme.titleMedium,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _handleSubmitCreateForm(context);
                      },
                      child: const Text('Create Form'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmitCreateForm(BuildContext context) async {
    var existTitle =
        _questions
            .where((q) => q.title == "How did you hear from us?")
            .toList();
    if (_referralEnabled && existTitle.isEmpty) {
      _questions.add(
        QuestionData(
          type: QuestionType.checkbox,
          title: 'How did you hear from us?',
          required: false,
          options: ReferralQuestionBlock.options,
        ),
      );
    } else {
      _questions.removeWhere((q) => q.title == 'How did you hear from us?');
    }

    if (_formKey.currentState!.validate()) {
      widget.onSubmit?.call(
        _formTitle,
        _formName,
        _formDescription,
        _questions,
      );
      Navigator.of(context).pop();
    }
  }
}

class _QuestionTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuestionTypeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E1D6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF7B7F8A)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF7B7F8A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionBlock extends StatefulWidget {
  final QuestionData data;
  final ValueChanged<QuestionData> onChanged;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onCopy;
  final bool highlighted;
  final Color highlightColor;

  const _QuestionBlock({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
    this.onCopy,
    this.highlighted = false,
    this.highlightColor = Colors.transparent,
  });

  @override
  State<_QuestionBlock> createState() => _QuestionBlockState();
}

class _QuestionBlockState extends State<_QuestionBlock> {
  late TextEditingController _titleController;
  late bool _required;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data.title);
    _required = widget.data.required;
    _options = widget.data.options ?? ['Option 1', 'Option 2'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: const EdgeInsets.all(16),
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastLinearToSlowEaseIn,
      decoration: BoxDecoration(
        color: widget.highlighted ? widget.highlightColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E1D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.data.type == QuestionType.text
                    ? Icons.text_fields
                    : widget.data.type == QuestionType.attachment
                    ? Icons.attach_file
                    : Icons.check_box,
                color: const Color(0xFF7B7F8A),
              ),
              const SizedBox(width: 8),
              Text(
                widget.data.type == QuestionType.text
                    ? 'Text'
                    : widget.data.type == QuestionType.attachment
                    ? 'Attachment'
                    : 'Checkbox',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (widget.onMoveDown != null)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_downward,
                    color: Color(0xFFB0B3BB),
                  ),
                  tooltip: 'Move Down',
                  onPressed: widget.onMoveDown,
                ),
              if (widget.onMoveUp != null)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_upward,
                    color: Color(0xFFB0B3BB),
                  ),
                  tooltip: 'Move Up',
                  onPressed: widget.onMoveUp,
                ),
              if (widget.onCopy != null)
                IconButton(
                  icon: const Icon(Icons.copy, color: Color(0xFFB0B3BB)),
                  tooltip: 'Copy',
                  onPressed: widget.onCopy,
                ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFF7B7F8A),
                ),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'New question',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      widget.data.type == QuestionType.attachment
                          ? Color(0xFFD1B06B)
                          : Color(0xFF7B7F8A),
                ),
              ),
            ),
            onChanged: (v) {
              widget.onChanged(
                widget.data
                  ..title = v
                  ..required = _required
                  ..options =
                      widget.data.type == QuestionType.checkbox
                          ? _options
                          : null,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Add description',
            style: TextStyle(
              color: Color(0xFF6B4F13),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.data.type == QuestionType.checkbox)
            Column(
              children: [
                ..._options.asMap().entries.map((entry) {
                  final idx = entry.key;
                  return Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextFormField(
                            initialValue: entry.value,
                            decoration: const InputDecoration(
                              labelText: 'Option',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              setState(() {
                                _options[idx] = v;
                                widget.onChanged(
                                  widget.data
                                    ..title = _titleController.text
                                    ..required = _required
                                    ..options = _options,
                                );
                              });
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          setState(() {
                            _options.removeAt(idx);
                            widget.onChanged(
                              widget.data
                                ..title = _titleController.text
                                ..required = _required
                                ..options = _options,
                            );
                          });
                        },
                      ),
                    ],
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Option'),
                    onPressed: () {
                      setState(() {
                        _options.add('Option ${_options.length + 1}');
                        widget.onChanged(
                          widget.data
                            ..title = _titleController.text
                            ..required = _required
                            ..options = _options,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          Row(
            children: [
              Switch(
                value: _required,
                activeColor: const Color(0xFFD1B06B),
                onChanged: (v) {
                  setState(() {
                    _required = v;
                    widget.onChanged(
                      widget.data
                        ..title = _titleController.text
                        ..required = _required
                        ..options =
                            widget.data.type == QuestionType.checkbox
                                ? _options
                                : null,
                    );
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Required',
                style: TextStyle(
                  color: Color(0xFF7B7F8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
