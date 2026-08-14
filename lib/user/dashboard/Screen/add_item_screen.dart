import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:accounts_information_handler/theme/glass_container.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'shared_item_widgets.dart';

class AddItemScreen extends StatefulWidget {
  final String categoryName;

  const AddItemScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // Controllers
  final _titleCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(text: '');
  final _urlCtrl = TextEditingController(text: '');
  final _notesCtrl = TextEditingController();

  bool _obscurePassword = true;
  double _passwordStrength = 0.0;
  bool isLoading = false;

  List<CustomField> _customFields = [];
  final List<File> _tempSelectedFiles = [];
  late final String _itemId;

  String get _category => widget.categoryName;

  @override
  void initState() {
    super.initState();

    _itemId = FirebaseFirestore.instance.collection('users').doc().id;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _usernameCtrl.text = user.email ?? '';
    }
    _titleCtrl.text = widget.categoryName;

    _passwordStrength = _calcStrength(_passwordCtrl.text);

    _passwordCtrl.addListener(() {
      setState(() {
        _passwordStrength = _calcStrength(_passwordCtrl.text);
      });
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _urlCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double _calcStrength(String pwd) {
    if (pwd.isEmpty) return 0;
    double score = 0;
    if (pwd.length >= 8) score += 0.2;
    if (pwd.length >= 12) score += 0.2;
    if (pwd.contains(RegExp(r'[A-Z]'))) score += 0.2;
    if (pwd.contains(RegExp(r'[0-9]'))) score += 0.2;
    if (pwd.contains(RegExp(r'[!@#\$%^&*()_+]'))) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  Color _strengthColor(double s) {
    if (s < 0.4) return Colors.redAccent;
    if (s < 0.7) return Colors.orangeAccent;
    return Colors.green;
  }

  String _generatePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final rng = Random.secure();
    return List.generate(16, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<void> _onSave() async {
    if (_titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title is required'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final customFieldsData = _customFields
          .map((f) => {'label': f.label, 'value': f.value})
          .toList();

      final data = {
        'title': _titleCtrl.text.trim(),
        'username': _usernameCtrl.text.trim(),
        'password': _passwordCtrl.text.trim(),
        'url': _urlCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'customFields': customFieldsData,
        'updatedAt': FieldValue.serverTimestamp(),
        'itemId': _itemId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('vault')
          .doc(widget.categoryName)
          .collection('items');

      await docRef.doc(_itemId).set(data);

      if (_tempSelectedFiles.isNotEmpty) {
        int successCount = 0;
        for (var file in _tempSelectedFiles) {
          bool success = await _uploadLocalFile(file);
          if (success) {
            successCount++;
          }
        }
        if (successCount < _tempSelectedFiles.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Saved entry, but failed to upload ${_tempSelectedFiles.length - successCount} attachment(s)',
              ),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
        _tempSelectedFiles.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry Saved Successfully'),
          backgroundColor: Colors.teal,
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _addCustomField() {
    showDialog(
      context: context,
      builder: (ctx) {
        final labelCtrl = TextEditingController();
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Add Field',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: labelCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Field label (e.g. Account Number)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _customFields.add(
                      CustomField(label: labelCtrl.text.trim(), value: ''),
                    );
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _uploadLocalFile(File file) async {
    try {
      var firebaseUid = FirebaseAuth.instance.currentUser!.uid;
      var url = Uri.parse(
        "https://prakrutitech.xyz/krish/upload_attachment.php",
      );
      var request = http.MultipartRequest("POST", url);
      request.fields["firebase_uid"] = firebaseUid;
      request.fields["item_id"] = _itemId;
      request.files.add(await http.MultipartFile.fromPath("file", file.path));

      var response = await request.send();
      var body = await response.stream.bytesToString();
      var result = jsonDecode(body);

      return result["status"] == true;
    } catch (e) {
      print("Error uploading attachment: $e");
      return false;
    }
  }

  Future<void> _addFile() async {
    List<File>? selectedFiles = await showModalBottomSheet<List<File>>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text("Camera"),
              onTap: () async {
                try {
                  var picker = ImagePicker();
                  var image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    Navigator.pop(ctx, [File(image.path)]);
                  } else {
                    Navigator.pop(ctx);
                  }
                } catch (e) {
                  print("Error picking image: $e");
                  Navigator.pop(ctx);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text("Gallery"),
              onTap: () async {
                try {
                  var picker = ImagePicker();
                  var images = await picker.pickMultiImage();
                  if (images.isNotEmpty) {
                    Navigator.pop(
                      ctx,
                      images.map((img) => File(img.path)).toList(),
                    );
                  } else {
                    Navigator.pop(ctx);
                  }
                } catch (e) {
                  print("Error picking images: $e");
                  Navigator.pop(ctx);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_rounded),
              title: const Text("Files"),
              onTap: () async {
                try {
                  var result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                  );
                  if (result != null && result.paths.isNotEmpty) {
                    List<File> files = result.paths
                        .where((path) => path != null)
                        .map((path) => File(path!))
                        .toList();
                    Navigator.pop(ctx, files);
                  } else {
                    Navigator.pop(ctx);
                  }
                } catch (e) {
                  print("Error picking files: $e");
                  Navigator.pop(ctx);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: const Text("Cancel"),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );

    if (selectedFiles == null || selectedFiles.isEmpty) return;

    setState(() {
      _tempSelectedFiles.addAll(selectedFiles);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Save',
            onPressed: isLoading ? null : _onSave,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.folder_special_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _category,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          InputTile(
                            controller: _titleCtrl,
                            label: 'Title',
                            icon: Icons.title_rounded,
                          ),
                          const SizedBox(height: 16),
                          InputTile(
                            controller: _usernameCtrl,
                            label: 'Username / Email',
                            icon: Icons.person_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          PasswordTile(
                            controller: _passwordCtrl,
                            obscure: _obscurePassword,
                            strength: _passwordStrength,
                            strengthColor: _strengthColor(_passwordStrength),
                            onToggleVisibility: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            onGenerate: () {
                              setState(() {
                                _passwordCtrl.text = _generatePassword();
                                _obscurePassword = false;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          UrlTile(
                            controller: _urlCtrl,
                            onClear: () => setState(() => _urlCtrl.clear()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Custom Fields",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ..._customFields.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final field = entry.value;
                            return CustomFieldTile(
                              field: field,
                              onDelete: () =>
                                  setState(() => _customFields.removeAt(idx)),
                            );
                          }),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _addCustomField,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Custom Field'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Attachments",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          if (_tempSelectedFiles.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(
                                child: Text(
                                  "No attachments found.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else ...[
                            ..._tempSelectedFiles.map((file) {
                              return LocalFileTile(
                                file: file,
                                onDelete: () {
                                  setState(() {
                                    _tempSelectedFiles.remove(file);
                                  });
                                },
                              );
                            }),
                          ],
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _addFile,
                              icon: const Icon(
                                Icons.attach_file_rounded,
                                size: 18,
                              ),
                              label: const Text('Add Attachment'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Notes",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          NotesTile(controller: _notesCtrl),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
        ),
      ),
    );
  }
}
