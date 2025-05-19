import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:sgm/services/form_question.service.dart';
import 'package:sgm/row_row_row_generated/tables/form_question.row.dart';
import 'package:sgm/utils/my_logger.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.formId});

  final String formId;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, String?> _dropdownAnswers = {};
  final Map<String, Set<String>> _checkboxAnswers = {};
  final Map<String, PlatformFile?> _fileAnswers = {};

  // Example dropdown options
  final List<String> _genders = ['Male', 'Female', 'Other'];

  // Default field keys
  static const String kFullName = 'full_name';
  static const String kGender = 'gender';
  static const String kNationality = 'nationality';
  static const String kCountryResidence = 'country_residence';
  static const String kPhoneNumber = 'phone_number';

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
      body: FutureBuilder<List<FormQuestionRow>>(
        future: FormQuestionService().fetchQuestionsByForm(widget.formId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final questions = snapshot.data ?? [];
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  children: [
                    // Default required fields
                    _TextFieldWidget(
                      label: 'Full Name',
                      controller: _getController(kFullName),
                      required: true,
                      hint: 'Enter Full Name',
                    ),
                    const SizedBox(height: 20),
                    CustomDropdownContainer<String>(
                      label: 'Gender',
                      value: _dropdownAnswers[kGender],
                      items: _genders,
                      required: true,
                      onSelect: (val) => _dropdownAnswers[kGender] = val,
                    ),
                    const SizedBox(height: 20),
                    CustomDropdownContainer<String>(
                      label: 'Nationality',
                      value: _dropdownAnswers[kNationality],
                      required: true,
                      isCountryPicker: true,
                      onSelect: (val) => _dropdownAnswers[kNationality] = val,
                      items: const [],
                    ),
                    const SizedBox(height: 20),
                    CustomDropdownContainer<String>(
                      label: 'Country of Residence',
                      value: _dropdownAnswers[kCountryResidence],
                      required: true,
                      isCountryPicker: true,
                      onSelect: (val) =>
                          _dropdownAnswers[kCountryResidence] = val,
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
                        child: _buildQuestionField(
                          q,
                          key: ValueKey('field-${q.id}'),
                        ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
        },
      ),
    );
  }

  TextEditingController _getController(String key) =>
      _textControllers.putIfAbsent(key, () => TextEditingController());

  Widget _buildQuestionField(FormQuestionRow question, {Key? key}) {
    final isRequired = question.isRequired ?? false;
    final label = question.question ?? '-';

    if ((label.toLowerCase().contains('gender') && question.type == 'text') ||
        (label.toLowerCase().contains('nationality') &&
            question.type == 'text') ||
        (label.toLowerCase().contains('country of residence') &&
            question.type == 'text') ||
        (label.toLowerCase().contains('full name') &&
            question.type == 'text') ||
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
          key: key ?? ValueKey('checkbox-${question.id}'),
          label: label,
          options: question.checkboxOptions ?? [],
          values: _checkboxAnswers[question.id] ?? {},
          required: isRequired,
          onChanged: (newSet) =>
              setState(() => _checkboxAnswers[question.id] = newSet),
        );
      case 'attachment':
        return _AttachmentFieldWidget(
          key: ValueKey('attachment-${question.id}'),
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }
    // Collect all answers here
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form submitted! (see debug output)')),
    );
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
            text: label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            children: required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
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
          validator: required
              ? (val) =>
                  (val == null || val.isEmpty) ? 'This field is required' : null
              : null,
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
  State<CustomDropdownContainer<T>> createState() =>
      _CustomDropdownContainerState<T>();
}

class _CustomDropdownContainerState<T>
    extends State<CustomDropdownContainer<T>> {
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
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            children: widget.required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
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
                builder: (context) => ListView(
                  children: (widget.items ?? [])
                      .map(
                        (item) => ListTile(
                          title: Text(item.toString()),
                          onTap: () => Navigator.pop(context, item),
                        ),
                      )
                      .toList(),
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
    required this.key,
    required this.label,
    required this.options,
    required this.values,
    required this.onChanged,
    this.required = false,
  });

  final Key key;
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
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            children: required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
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
    required this.key,
    required this.label,
    required this.file,
    required this.onPick,
  });

  final ValueKey key;
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
        errorBuilder: (context, error, stackTrace) =>
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black87,
        ),
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
            final result = await FilePicker.platform
                .pickFiles(type: FileType.any, withData: true);
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
        const Text(
          'Or drag and drop a file',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
