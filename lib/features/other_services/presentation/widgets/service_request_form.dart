import 'package:flutter/material.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/core/theme/app_theme.dart';
import 'package:kz_servicos_app/features/other_services/data/models/service_category.dart';
import 'package:kz_servicos_app/features/other_services/data/models/service_request.dart';
import 'package:kz_servicos_app/features/other_services/presentation/widgets/media_attachment_picker.dart';
import 'package:kz_servicos_app/features/other_services/presentation/widgets/urgency_selector.dart';

class ServiceRequestForm extends StatefulWidget {
  const ServiceRequestForm({
    required this.category,
    required this.onSubmit,
    super.key,
  });

  final ServiceCategory category;
  final ValueChanged<ServiceRequest> onSubmit;

  @override
  State<ServiceRequestForm> createState() => _ServiceRequestFormState();
}

class _ServiceRequestFormState extends State<ServiceRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _problemController = TextEditingController();
  final _detailsController = TextEditingController();
  final _addressController = TextEditingController();

  UrgencyType _urgency = UrgencyType.now;
  DateTime? _scheduledDateTime;
  List<String> _mediaPaths = const [];

  @override
  void dispose() {
    _problemController.dispose();
    _detailsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final request = ServiceRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: widget.category.id,
      categoryName: widget.category.name,
      problem: _problemController.text.trim(),
      details: _detailsController.text.trim(),
      mediaPaths: _mediaPaths,
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      urgency: _urgency,
      scheduledDate: _scheduledDateTime,
      status: ServiceRequestStatus.searchingProvider,
      createdAt: DateTime.now(),
    );

    widget.onSubmit(request);
  }

  InputDecoration _inputDecoration(String hintText, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.highlight, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSectionLabel('Qual o problema?'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _problemController,
            decoration: _inputDecoration('Descreva o problema em poucas palavras'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe o problema' : null,
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Detalhes do serviço'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _detailsController,
            decoration: _inputDecoration(
              'Explique com mais detalhes o que precisa ser feito...',
            ),
            maxLines: 5,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe os detalhes' : null,
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Fotos e vídeo'),
          const SizedBox(height: 8),
          MediaAttachmentPicker(
            onMediaChanged: (paths) => _mediaPaths = paths,
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Endereço (opcional)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _addressController,
            decoration: _inputDecoration(
              'Rua, número, bairro...',
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Quando você precisa?'),
          const SizedBox(height: 8),
          UrgencySelector(
            onUrgencyChanged: (type) => setState(() => _urgency = type),
            onDateTimeChanged: (dt) => _scheduledDateTime = dt,
          ),
          const SizedBox(height: 28),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: widget.category.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.category.icon,
            color: widget.category.color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Solicitar ${widget.category.name}',
            style: TextStyle(
              fontFamily: AppTheme.fontFamilyTitle,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTheme.fontFamilyBody,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.highlight,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: TextStyle(
            fontFamily: AppTheme.fontFamilyBody,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Enviar pedido de prestador'),
      ),
    );
  }
}
