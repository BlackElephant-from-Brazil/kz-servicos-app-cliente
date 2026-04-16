import 'package:flutter/material.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/core/theme/app_theme.dart';
import 'package:kz_servicos_app/features/other_services/data/models/service_request.dart';

class UrgencySelector extends StatefulWidget {
  const UrgencySelector({
    required this.onUrgencyChanged,
    required this.onDateTimeChanged,
    this.initialUrgency = UrgencyType.scheduled,
    this.initialDateTime,
    super.key,
  });

  final ValueChanged<UrgencyType> onUrgencyChanged;
  final ValueChanged<DateTime?> onDateTimeChanged;
  final UrgencyType initialUrgency;
  final DateTime? initialDateTime;

  @override
  State<UrgencySelector> createState() => _UrgencySelectorState();
}

class _UrgencySelectorState extends State<UrgencySelector>
    with SingleTickerProviderStateMixin {
  late UrgencyType _selected;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialUrgency;
    _selectedDate = widget.initialDateTime;
    _selectedTime = widget.initialDateTime != null
        ? TimeOfDay.fromDateTime(widget.initialDateTime!)
        : null;

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    if (_selected == UrgencyType.scheduled) {
      _expandController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _selectUrgency(UrgencyType type) {
    if (_selected == type) return;
    setState(() => _selected = type);
    widget.onUrgencyChanged(type);

    if (type == UrgencyType.scheduled) {
      _expandController.forward();
    } else {
      _expandController.reverse();
      _selectedDate = null;
      _selectedTime = null;
      widget.onDateTimeChanged(null);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _notifyDateTimeChanged();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      _notifyDateTimeChanged();
    }
  }

  void _notifyDateTimeChanged() {
    if (_selectedDate == null) return;
    final time = _selectedTime ?? const TimeOfDay(hour: 8, minute: 0);
    final combined = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      time.hour,
      time.minute,
    );
    widget.onDateTimeChanged(combined);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleRow(),
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1,
          child: _buildDateTimePickers(),
        ),
      ],
    );
  }

  Widget _buildToggleRow() {
    return Row(
      children: [
        Expanded(
          child: _ToggleButton(
            label: 'Quero agendar',
            icon: Icons.calendar_today,
            isActive: _selected == UrgencyType.scheduled,
            onTap: () => _selectUrgency(UrgencyType.scheduled),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ToggleButton(
            label: 'Preciso agora',
            icon: Icons.flash_on,
            isActive: _selected == UrgencyType.now,
            onTap: () => _selectUrgency(UrgencyType.now),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePickers() {
    final dateText = _selectedDate != null
        ? '${_selectedDate!.day.toString().padLeft(2, '0')}/'
            '${_selectedDate!.month.toString().padLeft(2, '0')}/'
            '${_selectedDate!.year}'
        : 'Selecionar data';
    final timeText = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
            '${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : 'Selecionar hora';

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: _DateTimeChip(
              icon: Icons.calendar_today,
              label: dateText,
              onTap: _pickDate,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DateTimeChip(
              icon: Icons.access_time,
              label: timeText,
              onTap: _pickTime,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.highlight : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.highlight : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.white : AppColors.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamilyBody,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeChip extends StatelessWidget {
  const _DateTimeChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamilyBody,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
