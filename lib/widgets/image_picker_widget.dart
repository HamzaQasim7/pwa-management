import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Callback for when an image is selected
/// Returns the image as a base64 string for storage
typedef OnImageSelected = void Function(String? imageBase64);

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({
    super.key,
    this.label = 'Tap to add image',
    this.onImageSelected,
    this.initialImage,
  });

  final String label;
  final OnImageSelected? onImageSelected;
  final String? initialImage;

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  String? _imageBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageBase64 = widget.initialImage;
  }

  Future<void> _showPicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (_pickedImage != null || _imageBase64 != null) ...[
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  title: const Text('Remove'),
                  subtitle: const Text('Remove current image'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );

    if (source == null || !mounted) return;

    await _pickImage(source);
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Read and convert to base64
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _pickedImage = image;
        _imageBase64 = base64String;
        _isLoading = false;
      });

      // Notify parent
      widget.onImageSelected?.call(_imageBase64);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected successfully'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _pickedImage = null;
      _imageBase64 = null;
    });
    widget.onImageSelected?.call(null);
  }

  Widget _buildImagePreview() {
    if (_imageBase64 != null) {
      try {
        final bytes = base64Decode(_imageBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                bytes,
                fit: BoxFit.cover,
              ),
              // Overlay with edit icon
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        // Invalid base64, show placeholder
      }
    }

    if (_pickedImage != null && !kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(_pickedImage!.path),
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imagePreview = _buildImagePreview();
    final hasImage = imagePreview != null;

    return GestureDetector(
      onTap: _isLoading ? null : _showPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasImage
                ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                : Theme.of(context).colorScheme.outlineVariant,
            width: hasImage ? 2 : 1,
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Processing image...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              )
            : hasImage
                ? imagePreview
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supports JPG, PNG',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

/// Helper widget to display an image from base64 string
class Base64Image extends StatelessWidget {
  const Base64Image({
    super.key,
    required this.base64String,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
  });

  final String base64String;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    try {
      final bytes = base64Decode(base64String);
      final image = Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
      );

      if (borderRadius != null) {
        return ClipRRect(
          borderRadius: borderRadius!,
          child: image,
        );
      }

      return image;
    } catch (e) {
      return placeholder ??
          Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.image_not_supported,
              color: Theme.of(context).colorScheme.outline,
            ),
          );
    }
  }
}
