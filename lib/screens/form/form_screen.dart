import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:sgm/services/form_question.service.dart';
import 'package:sgm/row_row_row_generated/tables/form_question.row.dart';
import 'package:sgm/services/task.service.dart';
import 'package:sgm/utils/loading_utils.dart';
import 'package:sgm/utils/my_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../row_row_row_generated/tables/task_form_response.row.dart';
import '../../services/project_task_status.service.dart';
import '../../services/task_form_response.service.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.formId, required this.projectId});

  final String formId;
  final String projectId;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  List<FormQuestionRow>? _questions;
  String? _error;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, String?> _dropdownAnswers = {};
  final Map<String, Set<String>> _checkboxAnswers = {};
  final Map<String, PlatformFile?> _fileAnswers = {};

  // Example dropdown options
  final List<String> _genders = ['- Male', '- Female', '- Other'];

  // Default field keys
  static const String kFullName = 'full_name';
  static const String kDateOfBirth = 'date_of_birth';
  static const String kGender = 'gender';
  static const String kNationality = 'nationality';
  static const String kCountryResidence = 'country_residence';
  static const String kPhoneNumber = 'phone_number';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadQuestions();
  }

  void _initializeControllers() {
    // Initialize controllers for required fields using constants
    _textControllers[kFullName] = TextEditingController();
    _textControllers[kDateOfBirth] = TextEditingController();
    _textControllers[kGender] = TextEditingController();
    _textControllers[kNationality] = TextEditingController();
    _textControllers[kCountryResidence] = TextEditingController();
    _textControllers[kPhoneNumber] = TextEditingController();
  }

  Future<void> _loadQuestions() async {
    LoadingUtils.showLoading();
    try {
      final questions = await FormQuestionService().fetchQuestionsByForm(widget.formId);
      // Create a controller for each dynamic text question
      for (final q in questions) {
        if (q.type == 'text' && !_textControllers.containsKey(q.id)) {
          _textControllers[q.id] = TextEditingController();
        }
      }
      if (mounted) {
        setState(() {
          _questions = questions;
        });
      }
    } finally {
      LoadingUtils.dismissLoading();
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Get user info')), body: _buildBody());
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    final questions = _questions ?? [];
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            children: [
              // Default required fields
              _TextFieldWidget(
                label: 'Full Name',
                controller: _getController(kFullName),
                required: true,
                hint: 'Enter Full Name',
              ),
              const SizedBox(height: 20),
              _DatePickerFieldWidget(
                label: 'Date of Birth (YYYY/MM/DD)',
                controller: _getController(kDateOfBirth),
                required: true,
              ),
              const SizedBox(height: 20),
              _GenderDialogFieldWidget(
                label: 'Gender',
                controller: _getController(kGender),
                required: true,
                options: _genders,
              ),
              const SizedBox(height: 20),
              CustomDropdownContainer<String>(
                label: 'Nationality',
                value: _textControllers[kNationality]?.text,
                required: true,
                isCountryPicker: true,
                onSelect: (val) {
                  setState(() {
                    _textControllers[kNationality]?.text = val;
                  });
                },
                items: const [],
              ),
              const SizedBox(height: 20),
              CustomDropdownContainer<String>(
                label: 'Country of Residence',
                value: _textControllers[kCountryResidence]?.text,
                required: true,
                isCountryPicker: true,
                onSelect: (val) {
                  setState(() {
                    _textControllers[kCountryResidence]?.text = val;
                  });
                },
                items: const [],
              ),
              const SizedBox(height: 20),
              _TextFieldWidget(
                label: '(Country Code) Phone Number',
                controller: _getController(kPhoneNumber),
                required: true,
                hint: 'Ex. 1 000 000 0000',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              // Dynamic backend questions
              ...questions.map(
                (q) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildQuestionField(q, key: ValueKey('field-${q.id}')),
                ),
              ),
              const SizedBox(height: 32),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextEditingController _getController(String key) => _textControllers.putIfAbsent(key, () => TextEditingController());

  Widget _buildQuestionField(FormQuestionRow question, {Key? key}) {
    final isRequired = question.isRequired ?? false;
    final label = question.question ?? '-';

    if ((label.toLowerCase().contains('gender') && question.type == 'text') ||
        (label.toLowerCase().contains('nationality') && question.type == 'text') ||
        (label.toLowerCase().contains('country of residence') && question.type == 'text') ||
        (label.toLowerCase().contains('full name') && question.type == 'text') ||
        (label.toLowerCase().contains('phone') && question.type == 'text')) {
      // These are handled as default fields above
      return const SizedBox.shrink();
    }

    switch (question.type) {
      case 'text':
        return _TextFieldWidget(
          label: label,
          controller: _getController(question.id),
          required: isRequired,
          hint: question.description ?? 'Enter Response',
        );
      case 'checkbox':
        return _CheckboxFieldWidget(
          customKey: key ?? ValueKey('checkbox-${question.id}'),
          label: label,
          options: question.checkboxOptions ?? [],
          values: _checkboxAnswers[question.id] ?? {},
          required: isRequired,
          onChanged:
              (newSet) =>
                  setState(() => _checkboxAnswers[question.id] = newSet),
        );
      case 'attachment':
        return _AttachmentFieldWidget(
          customKey: ValueKey('attachment-${question.id}'),
          label: label,
          file: _fileAnswers[question.id],
          onPick: (file) {
            _fileAnswers[question.id] = file;
            MyLogger.d('File picked: ${file?.name}');
            // Do NOT call setState here!
          },
        );
      default:
        return Text(label);
    }
  }

  Future<void> _submitForm() async {
    void showError(String message) {
      _showFieldError(message);
    }

    if (!_formKey.currentState!.validate()) {
      showError('Please fill all required fields.');
      return;
    }

    // Explicit validation for static required fields
    if ((_textControllers[kFullName]?.text ?? '').isEmpty ||
        (_textControllers[kDateOfBirth]?.text ?? '').isEmpty ||
        (_textControllers[kGender]?.text ?? '').isEmpty ||
        (_textControllers[kNationality]?.text ?? '').isEmpty ||
        (_textControllers[kCountryResidence]?.text ?? '').isEmpty) {
      showError('Please fill all required fields.');
      return;
    }

    // Dynamic validation for required fields from FormQuestionRow
    for (final q in _questions ?? []) {
      if (q.isRequired ?? false) {
        switch (q.type) {
          case 'text':
            if ((_textControllers[q.id]?.text ?? '').isEmpty) {
              showError('Please fill all required fields.');
              return;
            }
            break;
          case 'checkbox':
            if ((_checkboxAnswers[q.id]?.isEmpty ?? true)) {
              showError('Please fill all required fields.');
              return;
            }
            break;
          case 'attachment':
            if (_fileAnswers[q.id] == null) {
              showError('Please fill all required fields.');
              return;
            }
            break;
        }
      }
    }

    // Debug: Print all answers
    _debugPrintAnswers();

    // Upload all files and get their URLs

    try {
      LoadingUtils.showLoading();
      final uploadedFileUrls = await _uploadAttachment();
      // Get or create new status
      final status = await ProjectTaskStatusService().getOrCreateNewStatus(widget.projectId);

      MyLogger.d('Status: ${status.id}');

      // Create task
      final task = await TaskService().createTask(
        title: _textControllers[kFullName]?.text ?? '',
        customerName: _textControllers[kFullName]?.text ?? '',
        customerGender: _textControllers[kGender]?.text ?? '',
        customerNationality: _textControllers[kNationality]?.text ?? '',
        customerCountryResidence: _textControllers[kCountryResidence]?.text ?? '',
        customerPhone: _textControllers[kPhoneNumber]?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '',
        customerBirthday: _parseDate(_textControllers[kDateOfBirth]?.text),
        status: status.id,
        form: widget.formId,
        project: widget.projectId,
      );

      MyLogger.d('Created task: ${task?.id}');

      // Save form responses
      if (_questions != null) {
        for (final question in _questions!) {
          final data = _buildResponseData(question, task?.id, uploadedFileUrls[question.id]);
          var created = await TaskFormService().createResponse(
            taskId: task?.id ?? '',
            questionId: question.id,
            answer: data[TaskFormResponseRow.field.answer] as String?,
            images: data[TaskFormResponseRow.field.images] as List<String>?,
            checkedBox: data[TaskFormResponseRow.field.checkedBox] as List<String>?,
            questionText: question.question,
          );
          MyLogger.d('Created response: ${question.question} -- ${data.toString()} ${created?.id}');
        }
      }
      LoadingUtils.dismissLoading();
      LoadingUtils.showSuccess('Form submitted successfully!');
      // go back
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      MyLogger.d('Error creating task: $e');
      if (mounted) {
        LoadingUtils.showSnackBar(context: context, message: 'Error creating task: $e');
      }
      return;
    } finally {
      LoadingUtils.dismissLoading();
    }
  }

  void _showFieldError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Map<String, dynamic> _buildResponseData(FormQuestionRow question, String? taskId, String? attachmentUrl) {
    final data = {
      TaskFormResponseRow.field.task: taskId,
      TaskFormResponseRow.field.question: question.id,
      TaskFormResponseRow.field.questionText: question.question,
      TaskFormResponseRow.field.checkedBox: question.checkboxOptions,
      TaskFormResponseRow.field.createdAt: DateTime.now().toIso8601String(),
      TaskFormResponseRow.field.photoConverted: false,
    };

    switch (question.type) {
      case 'text':
        data[TaskFormResponseRow.field.answer] = _textControllers[question.id]?.text;
        break;
      case 'checkbox':
        final checkedValues = _checkboxAnswers[question.id]?.toList();
        data[TaskFormResponseRow.field.checkedBox] = checkedValues;
        data[TaskFormResponseRow.field.answer] = checkedValues?.join(', ');
        break;
      case 'attachment':
        if (attachmentUrl != null) {
          data[TaskFormResponseRow.field.images] = [attachmentUrl];
          data[TaskFormResponseRow.field.answer] = attachmentUrl;
        } else {
          data[TaskFormResponseRow.field.images] = [];
          data[TaskFormResponseRow.field.answer] = '';
        }
        break;
    }
    return data;
  }

  Future<Map<String, String>> _uploadAttachment() async {
    Map<String, String> uploadedFileUrls = {};
    for (final entry in _fileAnswers.entries) {
      final questionId = entry.key;
      final file = entry.value;
      if (file != null && file.bytes != null) {
        final publicUrl = await uploadFormFileToSupabase(file);
        if (publicUrl != null) {
          uploadedFileUrls[questionId] = publicUrl;
        }
      }
    }

    MyLogger.d('Uploaded files: $uploadedFileUrls');
    return uploadedFileUrls;
  }

  Future<String?> uploadFormFileToSupabase(PlatformFile file, {String? userId}) async {
    try {
      final fileExt = path.extension(file.name);
      final fileName = '${userId ?? 'anon'}-${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = '${userId ?? 'anon'}/$fileName';
      await Supabase.instance.client.storage
          .from('formuploads')
          .uploadBinary(filePath, file.bytes!, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));
      final publicUrl = Supabase.instance.client.storage.from('formuploads').getPublicUrl(filePath);
      MyLogger.d('Uploaded file: ${file.name} to $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('File upload error: $e');
      return null;
    }
  }

  void _debugPrintAnswers() {
    for (final entry in _textControllers.entries) {
      debugPrint('Text answer for ${entry.key}: ${entry.value.text}');
    }
    for (final entry in _dropdownAnswers.entries) {
      debugPrint('Dropdown answer for ${entry.key}: ${entry.value}');
    }
    for (final entry in _checkboxAnswers.entries) {
      debugPrint('Checkbox answers for ${entry.key}: ${entry.value}');
    }
    for (final entry in _fileAnswers.entries) {
      debugPrint('File answer for ${entry.key}: ${entry.value?.name}');
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }
}

// --- Custom Widgets ---

class _TextFieldWidget extends StatelessWidget {
  const _TextFieldWidget({
    required this.label,
    required this.controller,
    this.required = false,
    this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool required;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.isNotEmpty ? label : 'No title question',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
            children: required ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
          validator: required ? (val) => (val == null || val.isEmpty) ? 'This field is required' : null : null,
        ),
      ],
    );
  }
}

class CustomDropdownContainer<T> extends StatelessWidget {
  const CustomDropdownContainer({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onSelect,
    this.required = false,
    this.isCountryPicker = false,
  });

  final String label;
  final T? value;
  final List<T>? items;
  final void Function(T) onSelect;
  final bool required;
  final bool isCountryPicker;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
            children: required ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            if (isCountryPicker) {
              showCountryPicker(
                context: context,
                showPhoneCode: false,
                onSelect: (country) {
                  onSelect(country.name as T);
                },
                countryListTheme: CountryListThemeData(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              );
            } else {
              final selected = await showModalBottomSheet<T>(
                context: context,
                builder:
                    (context) => ListView(
                      children:
                          (items ?? [])
                              .map(
                                (item) =>
                                    ListTile(title: Text(item.toString()), onTap: () => Navigator.pop(context, item)),
                              )
                              .toList(),
                    ),
              );
              if (selected != null) {
                onSelect(selected);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value?.toString() ?? 'Select',
                    style: TextStyle(color: value == null ? Colors.grey : Colors.black, fontSize: 16),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckboxFieldWidget extends StatelessWidget {
  const _CheckboxFieldWidget({
    required this.customKey,
    required this.label,
    required this.options,
    required this.values,
    required this.onChanged,
    this.required = false,
  });

  final Key customKey;
  final String label;
  final List<String> options;
  final Set<String> values;
  final bool required;
  final void Function(Set<String>) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.isEmpty ? 'No title question' : label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
            children: required ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        ...options.map(
          (opt) => CheckboxListTile(
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            value: values.contains(opt),
            onChanged: (checked) {
              final newSet = Set<String>.from(values);
              if (checked == true) {
                newSet.add(opt);
              } else {
                newSet.remove(opt);
              }
              onChanged(newSet);
            },
            title: Text(opt, style: const TextStyle(fontSize: 14)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _AttachmentFieldWidget extends StatefulWidget {
  const _AttachmentFieldWidget({
    required this.customKey,
    required this.label,
    required this.file,
    required this.onPick,
  });

  final ValueKey customKey;
  final String label;
  final PlatformFile? file;
  final void Function(PlatformFile?) onPick;

  @override
  State<_AttachmentFieldWidget> createState() => _AttachmentFieldWidgetState();
}

class _AttachmentFieldWidgetState extends State<_AttachmentFieldWidget> {
  PlatformFile? _file;

  @override
  void initState() {
    super.initState();
    _file = widget.file;
  }

  @override
  void didUpdateWidget(covariant _AttachmentFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.file != oldWidget.file) {
      _file = widget.file;
    }
  }

  bool _isImageFile(String? path) {
    if (path == null) return false;
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.bmp') ||
        ext.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    Widget fileWidget;
    if (_file != null && _isImageFile(_file!.name) && _file!.bytes != null) {
      fileWidget = Image.memory(
        _file!.bytes!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      );
    } else if (_file != null) {
      fileWidget = Text(
        _file!.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      );
    } else {
      fileWidget = ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.attach_file),
        label: const Text('Select a file'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black87),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              final file = File(pickedFile.path);
              final fileBytes = await file.readAsBytes();
              final fileName = pickedFile.name;
              final platformFile = PlatformFile(
                name: fileName,
                size: fileBytes.length,
                bytes: fileBytes,
                path: file.path,
              );
              setState(() => _file = platformFile);
              widget.onPick(platformFile);
            }
          },
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: fileWidget),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Or drag and drop a file',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _DatePickerFieldWidget extends StatelessWidget {
  const _DatePickerFieldWidget({required this.label, required this.controller, this.required = false});

  final String label;
  final TextEditingController controller;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
            children: required ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000, 1, 1),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.text =
                  "${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}";
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'YYYY/MM/DD', border: OutlineInputBorder()),
              validator: required ? (val) => (val == null || val.isEmpty) ? 'This field is required' : null : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderDialogFieldWidget extends StatelessWidget {
  const _GenderDialogFieldWidget({
    required this.label,
    required this.controller,
    required this.options,
    this.required = false,
  });

  final String label;
  final TextEditingController controller;
  final List<String> options;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
            children: required ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final selected = await showModalBottomSheet<String>(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              context: context,
              builder:
                  (context) => ListView(
                    children:
                        options
                            .map((gender) => ListTile(title: Text(gender), onTap: () => Navigator.pop(context, gender)))
                            .toList(),
                  ),
            );
            if (selected != null) {
              controller.text = selected;
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Select Gender', border: OutlineInputBorder()),
              validator: required ? (val) => (val == null || val.isEmpty) ? 'This field is required' : null : null,
            ),
          ),
        ),
      ],
    );
  }
}
