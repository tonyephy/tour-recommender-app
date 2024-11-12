import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(List<String>) onImagesSelected; // Notifies parent with URLs of selected images

  const ImagePickerWidget({Key? key, required this.onImagesSelected}) : super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  List<XFile>? _imageFiles = [];
  List<String> _uploadedImageUrls = []; // Store URLs of uploaded images

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();

    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _imageFiles!.addAll(selectedImages);
      });

      // Upload images to Firebase and collect URLs
      for (var image in selectedImages) {
        String downloadUrl = await _uploadImageToFirebase(image);
        if (downloadUrl.isNotEmpty) {
          _uploadedImageUrls.add(downloadUrl); // Add the URL to the list only if it's not empty
        }
      }

      // Notify parent widget with the new URLs
      widget.onImagesSelected(_uploadedImageUrls);
    }
  }

  Future<String> _uploadImageToFirebase(XFile image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('reviews/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
      if (kIsWeb) {
        // Use `putData` for web because `File` is not available
        await storageRef.putData(await image.readAsBytes());
      } else {
        // For mobile use `putFile`
        await storageRef.putFile(File(image.path));
      }
      return await storageRef.getDownloadURL(); // Get the download URL after upload
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Return empty string if there's an error
    }
  }

  void _removeImage(XFile image) {
    setState(() {
      _imageFiles!.remove(image);
      // Remove the corresponding uploaded URL
      _uploadedImageUrls.removeWhere((url) => url.contains(image.name));
    });
    // Notify parent widget after removing the image
    widget.onImagesSelected(_uploadedImageUrls);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickImages,
          child: const Text('Add Images'),
        ),
        const SizedBox(height: 16.0),
        _imageFiles!.isEmpty
            ? const Text('No images selected.')
            : Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _imageFiles!.map((image) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                kIsWeb
                    ? Image.network(
                  image.path, // Web shows the blob URL temporarily
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  File(image.path), // Mobile: Use File widget to display the image
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    _removeImage(image); // Call method to remove the image
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
