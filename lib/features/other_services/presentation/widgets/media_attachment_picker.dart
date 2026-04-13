import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/core/theme/app_theme.dart';

class MediaAttachmentPicker extends StatefulWidget {
  const MediaAttachmentPicker({
    required this.onMediaChanged,
    this.initialMediaPaths = const [],
    super.key,
  });

  final ValueChanged<List<String>> onMediaChanged;
  final List<String> initialMediaPaths;

  @override
  State<MediaAttachmentPicker> createState() => _MediaAttachmentPickerState();
}

class _MediaAttachmentPickerState extends State<MediaAttachmentPicker> {
  late final List<String> _mediaPaths;
  final ImagePicker _picker = ImagePicker();

  static const int _maxPhotos = 5;
  static const int _maxVideos = 1;

  @override
  void initState() {
    super.initState();
    _mediaPaths = List<String>.from(widget.initialMediaPaths);
  }

  int get _photoCount =>
      _mediaPaths.where((p) => !_isVideo(p)).length;

  int get _videoCount =>
      _mediaPaths.where(_isVideo).length;

  bool _isVideo(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi');
  }

  void _removeMedia(int index) {
    setState(() => _mediaPaths.removeAt(index));
    widget.onMediaChanged(List.unmodifiable(_mediaPaths));
  }

  Future<void> _pickFromCamera() async {
    if (_photoCount >= _maxPhotos) return;
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (file != null) _addMedia(file.path);
  }

  Future<void> _pickFromGallery() async {
    if (_photoCount >= _maxPhotos) return;
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) _addMedia(file.path);
  }

  Future<void> _pickVideo() async {
    if (_videoCount >= _maxVideos) return;
    final file = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 30),
    );
    if (file != null) _addMedia(file.path);
  }

  void _addMedia(String path) {
    setState(() => _mediaPaths.add(path));
    widget.onMediaChanged(List.unmodifiable(_mediaPaths));
  }

  void _showPickerOptions() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BottomSheetOption(
                icon: Icons.camera_alt,
                label: 'Câmera',
                enabled: _photoCount < _maxPhotos,
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              _BottomSheetOption(
                icon: Icons.photo_library,
                label: 'Galeria',
                enabled: _photoCount < _maxPhotos,
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              _BottomSheetOption(
                icon: Icons.videocam,
                label: 'Vídeo (30s)',
                enabled: _videoCount < _maxVideos,
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _mediaPaths.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) return _buildAddButton();
          return _buildThumbnail(index - 1);
        },
      ),
    );
  }

  Widget _buildAddButton() {
    final canAdd = _photoCount < _maxPhotos || _videoCount < _maxVideos;
    return GestureDetector(
      onTap: canAdd ? _showPickerOptions : null,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: canAdd ? AppColors.textPrimary : Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'Adicionar\nfoto',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamilyBody,
                fontSize: 11,
                color: canAdd ? AppColors.textPrimary : Colors.grey.shade400,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(int index) {
    final path = _mediaPaths[index];
    final isVideo = _isVideo(path);

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isVideo
                ? _buildVideoPlaceholder()
                : Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildImagePlaceholder(),
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeMedia(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
            SizedBox(height: 4),
            Text(
              '0:30 máx',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 32),
      ),
    );
  }
}

class _BottomSheetOption extends StatelessWidget {
  const _BottomSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? AppColors.textPrimary : Colors.grey.shade400,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamilyBody,
          color: enabled ? AppColors.textPrimary : Colors.grey.shade400,
        ),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
