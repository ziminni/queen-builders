import 'dart:math' show min;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/scroll/desktop_smooth_scroll.dart';
import '../models/budget_allocation.dart';
import '../models/project.dart';

class CreateProjectDialog extends StatefulWidget {
  final Future<void> Function(Project project) onCreateProject;

  const CreateProjectDialog({super.key, required this.onCreateProject});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _foremanController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, bool> _isFocused = {};
  final ScrollController _formScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final fields = [
      'name',
      'client',
      'foreman',
      'location',
      'startDate',
      'deadline',
    ];

    for (final field in fields) {
      _focusNodes[field] = FocusNode();
      _focusNodes[field]!.addListener(() {
        setState(() {
          _isFocused[field] = _focusNodes[field]!.hasFocus;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _foremanController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _deadlineController.dispose();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _formScrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.trim().isEmpty ||
        _clientController.text.trim().isEmpty ||
        _foremanController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty) {
      _showAlert('Please fill in all required fields');
      return;
    }

    if (_startDateController.text.trim().isEmpty ||
        _deadlineController.text.trim().isEmpty) {
      _showAlert('Please select start date and deadline');
      return;
    }

    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text.trim(),
      client: _clientController.text.trim(),
      foreman: _foremanController.text.trim(),
      status: 'Planning',
      location: _locationController.text.trim(),
      progress: 0,
      budgetAllocated: BudgetAllocation(materials: 0, labor: 0, equipment: 0),
      startDate: _startDateController.text.trim(),
      deadline: _deadlineController.text.trim(),
      materials: [],
      expenses: [],
      progressLogs: [],
      issues: [],
      comments: [],
    );

    try {
      await widget.onCreateProject(project);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        _showAlert(
          'Could not create the project. Check that the server is running and try again.',
        );
      }
    }
  }

  void _showAlert(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = min(640.0, size.width - 32);
    final dialogHeight = min(520.0, size.height - 32);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.richGold, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Project',
                      style: AppTextStyles.h2.copyWith(
                        fontFamily: AppTextStyles.cinzelFont,
                        color: AppColors.deepBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _CloseButton(onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
              Expanded(
                child: ScrollConfiguration(
                  behavior: const DesktopSmoothScrollBehavior(),
                  child: Scrollbar(
                    controller: _formScrollController,
                    thumbVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(8),
                    interactive: true,
                    child: SingleChildScrollView(
                      controller: _formScrollController,
                      primary: false,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.manual,
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _InputField(
                                  label: 'Project Name',
                                  controller: _nameController,
                                  focusNode: _focusNodes['name']!,
                                  isFocused: _isFocused['name'] ?? false,
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _InputField(
                                  label: 'Client Name',
                                  controller: _clientController,
                                  focusNode: _focusNodes['client']!,
                                  isFocused: _isFocused['client'] ?? false,
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _InputField(
                                  label: 'Foreman',
                                  controller: _foremanController,
                                  focusNode: _focusNodes['foreman']!,
                                  isFocused: _isFocused['foreman'] ?? false,
                                  placeholder: 'Enter foreman name',
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _InputField(
                                  label: 'Location',
                                  controller: _locationController,
                                  focusNode: _focusNodes['location']!,
                                  isFocused: _isFocused['location'] ?? false,
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _DateField(
                                  label: 'Start Date',
                                  controller: _startDateController,
                                  focusNode: _focusNodes['startDate']!,
                                  isFocused: _isFocused['startDate'] ?? false,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _DateField(
                                  label: 'Deadline',
                                  controller: _deadlineController,
                                  focusNode: _focusNodes['deadline']!,
                                  isFocused: _isFocused['deadline'] ?? false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _CancelButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _SubmitButton(onPressed: _handleSubmit),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String? placeholder;
  final bool isRequired;

  const _InputField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    this.placeholder,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.deepBlack,
              fontWeight: FontWeight.w500,
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused ? AppColors.richGold : const Color(0xFFD9D9D9),
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;

  const _DateField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.deepBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused ? AppColors.richGold : const Color(0xFFD9D9D9),
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: true,
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: InputBorder.none,
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                controller.text =
                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              }
            },
          ),
        ),
      ],
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered
            ? AppColors.error.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.close,
              size: 24,
              color: _isHovered ? AppColors.error : const Color(0xFF8A8A8A),
            ),
          ),
        ),
      ),
    );
  }
}

class _CancelButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CancelButton({required this.onPressed});

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered
            ? Colors.black.withValues(alpha: 0.05)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFD9D9D9), width: 2),
        ),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'Cancel',
                style: AppTextStyles.button.copyWith(
                  color: const Color(0xFF2B2B2B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final Future<void> Function() onPressed;

  const _SubmitButton({required this.onPressed});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered ? const Color(0xFF8C6B3F) : AppColors.richGold,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            widget.onPressed();
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'Create Project',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
