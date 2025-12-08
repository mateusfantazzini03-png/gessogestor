import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<String> _imagePaths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePaths = prefs.getStringList('gallery_images') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _imagePaths.add(pickedFile.path);
      });
      await prefs.setStringList('gallery_images', _imagePaths);
    }
  }

  Future<void> _removeImage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePaths.removeAt(index);
    });
    await prefs.setStringList('gallery_images', _imagePaths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Portfólio')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        child: const Icon(Icons.add_a_photo),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _imagePaths.isEmpty 
          ? const Center(child: Text('Nenhuma foto adicionada ao portfólio.'))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _imagePaths.length,
              itemBuilder: (ctx, i) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(_imagePaths[i]), fit: BoxFit.cover),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => _removeImage(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.delete, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
