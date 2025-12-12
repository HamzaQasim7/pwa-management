import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core/services/image_storage_service.dart';

/// Callback for when an image is selected
/// Returns the image data - either base64 string (local) or URL (cloud)
typedef OnImageSelected = void Function(String? imageData, bool isUrl);

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({
    super.key,
    this.label = 'Tap to add image',
    this.onImageSelected,
    this.initialImage,
    this.entityType,
    this.entityId,
    this.imageStorageService,
    this.uploadToCloud = false,
  });

  final String label;
  final OnImageSelected? onImageSelected;
  
  /// Initial image - can be base64 string or URL
  final String? initialImage;
  
  /// Entity type for cloud storage (e.g., 'feedProduct', 'medicine')
  final String? entityType;
  
  /// Entity ID for cloud storage
  final String? entityId;
  
  /// Optional image storage service for cloud uploads
  final ImageStorageService? imageStorageService;
  
  /// Whether to upload images to cloud storage
  final bool uploadToCloud;

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  String? _imageData; // Can be base64 or URL
  bool _isUrl = false;
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _imageData = widget.initialImage;
    _isUrl = _isValidUrl(widget.initialImage);
  }

  @override
  void didUpdateWidget(covariant ImagePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialImage != widget.initialImage) {
      setState(() {
        _imageData = widget.initialImage;
        _isUrl = _isValidUrl(widget.initialImage);
      });
    }
  }

  bool _isValidUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.startsWith('http://') || value.startsWith('https://');
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
              if (_pickedImage != null || _imageData != null) ...[
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

      setState(() {
        _pickedImage = image;
        _isLoading = false;
      });

      // Process the image
      if (widget.uploadToCloud && 
          widget.imageStorageService != null &&
          widget.imageStorageService!.isAvailable &&
          widget.entityType != null &&
          widget.entityId != null) {
        // Upload to Firebase Storage
        await _uploadToCloud(image);
      } else {
        // Store as base64 locally
        await _storeLocally(image);
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

  Future<void> _storeLocally(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _imageData = base64String;
        _isUrl = false;
      });

      widget.onImageSelected?.call(_imageData, false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved locally'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error storing image locally: $e');
    }
  }

  Future<void> _uploadToCloud(XFile image) async {
    setState(() => _isUploading = true);

    try {
      final file = File(image.path);
      final url = await widget.imageStorageService!.uploadImage(
        file,
        widget.entityType!,
        widget.entityId!,
      );

      if (url != null) {
        setState(() {
          _imageData = url;
          _isUrl = true;
          _isUploading = false;
        });

        widget.onImageSelected?.call(url, true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded to cloud'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Fallback to local storage
        await _storeLocally(image);
        setState(() => _isUploading = false);
      }
    } catch (e) {
      debugPrint('Error uploading to cloud: $e');
      // Fallback to local storage
      await _storeLocally(image);
      setState(() => _isUploading = false);
    }
  }

  Future<void> _removeImage() async {
    // If it's a cloud URL, try to delete from storage
    if (_isUrl && 
        _imageData != null &&
        widget.imageStorageService != null &&
        widget.imageStorageService!.isAvailable) {
      try {
        await widget.imageStorageService!.deleteImage(_imageData!);
      } catch (e) {
        debugPrint('Error deleting cloud image: $e');
      }
    }

    setState(() {
      _pickedImage = null;
      _imageData = null;
      _isUrl = false;
    });
    widget.onImageSelected?.call(null, false);
  }

  Widget? _buildImagePreview() {
    // Show URL image
    if (_isUrl && _imageData != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _imageData!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            // Cloud indicator
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_done,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Cloud',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Edit icon
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

    // Show base64 image
    if (_imageData != null && !_isUrl) {
      try {
        final bytes = base64Decode(_imageData!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                bytes,
                fit: BoxFit.cover,
              ),
              // Local indicator
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_android,
                        size: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Local',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Edit icon
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

    // Show file image (before processing)
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
      onTap: (_isLoading || _isUploading) ? null : _showPicker,
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
        child: (_isLoading || _isUploading)
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isUploading ? 'Uploading to cloud...' : 'Processing image...',
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
                        widget.uploadToCloud ? 'Saves to cloud' : 'Saves locally',
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

/// Helper widget to display an image from base64 string or URL
class SmartImage extends StatelessWidget {
  const SmartImage({
    super.key,
    required this.imageData,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
  });

  /// Image data - can be base64 string or URL
  final String imageData;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  bool get _isUrl =>
      imageData.startsWith('http://') || imageData.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (_isUrl) {
      // Network image
      image = CachedNetworkImage(
        imageUrl: imageData,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(context),
        errorWidget: (context, url, error) => _buildError(context),
      );
    } else {
      // Base64 image
      try {
        final bytes = base64Decode(imageData);
        image = Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
        );
      } catch (e) {
        image = placeholder ?? _buildError(context);
      }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Container(
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

/// Helper widget to display an image from base64 string (legacy support)
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
    // Delegate to SmartImage for unified handling
    return SmartImage(
      imageData: base64String,
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      placeholder: placeholder,
    );
  }
}
