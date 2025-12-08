import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/profile_service.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pixController = TextEditingController();
  String? _logoPath;
  bool _isLoading = true;
  final _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await _profileService.loadProfile();
    setState(() {
      _nameController.text = profile.companyName;
      _phoneController.text = profile.phone;
      _pixController.text = profile.pixKey;
      _logoPath = profile.logoPath;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _logoPath = pickedFile.path;
      });
    }
  }

  Future<void> _save() async {
    final newProfile = ProfessionalProfile(
      companyName: _nameController.text,
      phone: _phoneController.text,
      pixKey: _pixController.text,
      logoPath: _logoPath,
    );
    await _profileService.saveProfile(newProfile);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados salvos com sucesso!')),
      );
      Navigator.pop(context, true); // Retorna true para atualizar a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes do Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _logoPath != null 
                  ? FileImage(File(_logoPath!)) 
                  : (_logoPath == 'assets/logo.png' ? const AssetImage('assets/logo.png') as ImageProvider : null),
                child: _logoPath == null 
                  ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) 
                  : null,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Toque para alterar logo'),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome da Empresa/Profissional', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telefone / WhatsApp', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pixController,
              decoration: const InputDecoration(labelText: 'Chave Pix', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('SALVAR ALTERAÇÕES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
