import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:sgm/services/form_question.service.dart';
import 'package:sgm/row_row_row_generated/tables/form_question.row.dart';
import 'package:sgm/services/project_task_status.service.dart';
import 'package:sgm/services/task.service.dart';
import 'package:sgm/utils/my_logger.dart';
import 'package:sgm/row_row_row_generated/tables/task_form_response.row.dart';
import 'package:sgm/services/task_form_response.service.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.formId, required this.projectId});

  final String formId;
  final String projectId;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, Set<String>> _checkboxAnswers = {};
  final Map<String, PlatformFile?> _fileAnswers = {};
  String? _errorMessage;
  List<FormQuestionRow>? _questions;

  // Example dropdown options
  final List<String> _genders = ['Male', 'Female', 'Other'];

  // Default field keys
  static const String kFullName = 'full_name';
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
    // Initialize controllers for required fields
    _textControllers[kFullName] = TextEditingController();
    _textControllers[kGender] = TextEditingController();
    _textControllers[kNationality] = TextEditingController();
    _textControllers[kCountryResidence] = TextEditingController();
    _textControllers[kPhoneNumber] = TextEditingController();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await FormQuestionService().fetchQuestionsByForm(widget.formId);
      if (mounted) {
        setState(() {
          _questions = questions;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading questions: $e';
        });
      }
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
    return Scaffold(
      appBar: AppBar(title: const Text('Get user info')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
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
                controller: _textControllers[kFullName]!,
                required: true,
                hint: 'Enter Full Name',
              ),
              const SizedBox(height: 20),
              CustomDropdownContainer<String>(
                label: 'Gender',
                value: _textControllers[kGender]?.text,
                items: _genders,
                required: true,
                onSelect: (val) => _textControllers[kGender]?.text = val,
              ),
              const SizedBox(height: 20),
              CustomDropdownContainer<String>(
                label: 'Nationality',
                value: _textControllers[kNationality]?.text,
                required: true,
                isCountryPicker: true,
                onSelect: (val) => _textControllers[kNationality]?.text = val,
                items: const [],
              ),
              const SizedBox(height: 20),
              CustomDropdownContainer<String>(
                label: 'Country of Residence',
                value: _textControllers[kCountryResidence]?.text,
                required: true,
                isCountryPicker: true,
                onSelect: (val) => _textControllers[kCountryResidence]?.text = val,
                items: const [],
              ),
              const SizedBox(height: 20),
              _TextFieldWidget(
                label: '(Country Code) Phone Number',
                controller: _textControllers[kPhoneNumber]!,
                required: true,
                hint: 'Ex. 1 000 000 0000',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              // Dynamic backend questions
              ...questions.map(
                    (q) =>
                    Padding(
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
                      textStyle: Theme
                          .of(context)
                          .textTheme
                          .titleMedium,
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

  TextEditingController _getController(String key) =>
      _textControllers.putIfAbsent(key, () => TextEditingController());

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
          onChanged: (newSet) => setState(() => _checkboxAnswers[question.id] = newSet),
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
    // Validate required fields
    if (_textControllers['fullName']?.text.isEmpty ?? true) {
      setState(() => _errorMessage = 'Full Name is required');
      return;
    }
    if (_textControllers['gender']?.text.isEmpty ?? true) {
      setState(() => _errorMessage = 'Gender is required');
      return;
    }
    if (_textControllers['nationality']?.text.isEmpty ?? true) {
      setState(() => _errorMessage = 'Nationality is required');
      return;
    }
    if (_textControllers['countryOfResidence']?.text.isEmpty ?? true) {
      setState(() => _errorMessage = 'Country of Residence is required');
      return;
    }
    if (_textControllers['phoneNumber']?.text.isEmpty ?? true) {
      setState(() => _errorMessage = 'Phone Number is required');
      return;
    }

    setState(() => _errorMessage = null);

    try {
      // Get or create new status
      final status = await ProjectTaskStatusService().getOrCreateNewStatus(widget.projectId);

      // Create task
      final task = await TaskService().createTask(
        title: _textControllers['fullName']!.text,
        customerName: _textControllers['fullName']!.text,
        customerGender: _textControllers['gender']!.text,
        customerNationality: _textControllers['nationality']!.text,
        customerCountryResidence: _textControllers['countryOfResidence']!.text,
        customerPhone: _textControllers['phoneNumber']!.text,
        status: status.id,
        form: widget.formId,
        project: widget.projectId,
      );

      if (task == null) {
        setState(() => _errorMessage = 'Failed to create task');
        return;
      }

      // Save form responses
      if (_questions != null) {
        for (final question in _questions!) {
          final data = {
            TaskFormResponseRow.field.task: task.id,
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
              final file = _fileAnswers[question.id];
              if (file != null) {
                data[TaskFormResponseRow.field.images] = [file.name];
                data[TaskFormResponseRow.field.answer] = file.name;
              }
              break;
          }

       var created = await TaskFormService().createResponse(
            taskId: task.id,
            questionId: question.id,
            answer: data[TaskFormResponseRow.field.answer] as String?,
            images: data[TaskFormResponseRow.field.images] as List<String>?,
            checkedBox: data[TaskFormResponseRow.field.checkedBox] as List<String>?,
            questionText: question.question,
          );
          
          MyLogger.d('Created response: ${created?.id}');
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error submitting form: $e');
    } finally {
      if (mounted) {
      }
    }
  }

  // create the task  with Task Service


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
            text: label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
            children: required
                ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          validator: required ? (val) => (val == null || val.isEmpty) ? 'This field is required' : null : null,
        ),
      ],
    );
  }
}

class CustomDropdownContainer<T> extends StatefulWidget {
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
  State<CustomDropdownContainer<T>> createState() => _CustomDropdownContainerState<T>();
}

class _CustomDropdownContainerState<T> extends State<CustomDropdownContainer<T>> {
  T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
  }

  @override
  void didUpdateWidget(covariant CustomDropdownContainer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selected = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
            children: widget.required
                ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            if (widget.isCountryPicker) {
              showCountryPicker(
                context: context,
                showPhoneCode: false,
                onSelect: (country) {
                  setState(() => _selected = country.name as T?);
                  widget.onSelect(country.name as T);
                },
              );
            } else {
              final selected = await showModalBottomSheet<T>(
                context: context,
                builder: (context) =>
                    ListView(
                      children: (widget.items ?? []).map((item) =>
                          ListTile(
                            title: Text(item.toString()),
                            onTap: () => Navigator.pop(context, item),
                          ),).toList(),
                    ),
              );
              if (selected != null) {
                setState(() => _selected = selected);
                widget.onSelect(selected);
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
                    _selected?.toString() ?? 'Select',
                    style: TextStyle(
                      color: _selected == null ? Colors.grey : Colors.black,
                      fontSize: 16,
                    ),
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
            text: label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
            children: required
                ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
                : [],
          ),
        ),
        ...options.map((opt) =>
            CheckboxListTile(
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
            ),),
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
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      );
    } else if (_file != null) {
      fileWidget = Text(_file!.name, style: const TextStyle(fontWeight: FontWeight.w500));
    } else {
      fileWidget = ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.attach_file),
        label: const Text('Select a file'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black87,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
            if (result != null && result.files.isNotEmpty) {
              setState(() => _file = result.files.first);
              widget.onPick(result.files.first);
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
        const Text('Or drag and drop a file', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
