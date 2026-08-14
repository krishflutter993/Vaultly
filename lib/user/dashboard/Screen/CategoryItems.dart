import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:accounts_information_handler/user/dashboard/Screen/add_item_screen.dart';
import 'package:accounts_information_handler/user/dashboard/Screen/edit_item_screen.dart';
import 'package:accounts_information_handler/theme/glass_container.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    final uid = user.uid;

    final itemsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('vault')
        .doc(categoryName)
        .collection('items');

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  AddItemScreen(categoryName: categoryName),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
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
          child: StreamBuilder(
            stream: itemsRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 80,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No Items Found",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>? ?? {};

                  final rawCustomFields = data['customFields'];
                  final List<dynamic> customFields = rawCustomFields is List
                      ? rawCustomFields
                      : rawCustomFields is Map
                      ? rawCustomFields.values.toList()
                      : [];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(8.0),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          iconColor: Theme.of(context).colorScheme.primary,
                          title: Text(
                            data['title'] ?? 'No Title',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              data['username'] ?? 'No Username',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                          ),
                          children: [
                            const Divider(height: 1),
                            _buildDetailRow(
                              context,
                              'Password',
                              data['password'] ?? 'No Password',
                            ),
                            _buildDetailRow(
                              context,
                              'URL',
                              data['url'] ?? 'No URL',
                            ),
                            _buildDetailRow(
                              context,
                              'Notes',
                              data['notes'] ?? 'No Notes',
                            ),
                            ...customFields.map((field) {
                              final f = field as Map<String, dynamic>;
                              return _buildDetailRow(
                                context,
                                f['label'] ?? 'Custom Field',
                                f['value'] ?? '',
                              );
                            }),
                            ItemAttachmentsWidget(itemId: doc.id, uid: uid),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                             EditItemScreen(
                                               categoryName: categoryName,
                                               itemId: doc.id,
                                               initialData: data,
                                             ),
                                        transitionsBuilder:
                                            (_, animation, __, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Edit Entry'),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String value) {
    if (value.isEmpty ||
        value == 'No Password' ||
        value == 'No URL' ||
        value == 'No Notes') {
      return const SizedBox.shrink();
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 0.0,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.copy_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title copied to clipboard'),
              backgroundColor: Colors.teal,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}

class ItemAttachmentsWidget extends StatefulWidget {
  final String itemId;
  final String uid;

  const ItemAttachmentsWidget({
    super.key,
    required this.itemId,
    required this.uid,
  });

  @override
  State<ItemAttachmentsWidget> createState() => _ItemAttachmentsWidgetState();
}

class _ItemAttachmentsWidgetState extends State<ItemAttachmentsWidget> {
  List<dynamic> _attachments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    try {
      var url = Uri.parse(
        "https://prakrutitech.xyz/krish/view_attachments.php?firebase_uid=${widget.uid}&item_id=${widget.itemId}",
      );
      var response = await http.get(url);
      var result = jsonDecode(response.body);
      if (result["status"] == true) {
        setState(() {
          _attachments = result["data"];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    bool _isImage(String pathOrUrl) {
      final mime = pathOrUrl.split('?').first.toLowerCase();
      return mime.endsWith('.jpg') ||
          mime.endsWith('.jpeg') ||
          mime.endsWith('.png') ||
          mime.endsWith('.gif') ||
          mime.endsWith('.webp') ||
          mime.endsWith('.heic');
    }

    IconData _getFileIcon(String pathOrUrl) {
      final cleanPath = pathOrUrl.split('?').first.toLowerCase();
      if (cleanPath.endsWith('.pdf')) {
        return Icons.picture_as_pdf_rounded;
      } else if (cleanPath.endsWith('.doc') || cleanPath.endsWith('.docx')) {
        return Icons.description_rounded;
      } else if (cleanPath.endsWith('.xls') || cleanPath.endsWith('.xlsx')) {
        return Icons.table_view_rounded;
      } else if (cleanPath.endsWith('.ppt') || cleanPath.endsWith('.pptx')) {
        return Icons.slideshow_rounded;
      } else if (cleanPath.endsWith('.txt')) {
        return Icons.text_snippet_rounded;
      } else if (cleanPath.endsWith('.zip') ||
          cleanPath.endsWith('.tar')) {
        return Icons.folder_zip_rounded;
      }
      return Icons.insert_drive_file_rounded;
    }

    Color _getFileIconColor(BuildContext context, String pathOrUrl) {
      final cleanPath = pathOrUrl.split('?').first.toLowerCase();
      if (cleanPath.endsWith('.pdf')) {
        return Colors.redAccent;
      } else if (cleanPath.endsWith('.doc') || cleanPath.endsWith('.docx')) {
        return Colors.blueAccent;
      } else if (cleanPath.endsWith('.xls') || cleanPath.endsWith('.xlsx')) {
        return Colors.green;
      } else if (cleanPath.endsWith('.ppt') || cleanPath.endsWith('.pptx')) {
        return Colors.orange;
      } else if (cleanPath.endsWith('.txt')) {
        return Colors.blueGrey;
      } else if (cleanPath.endsWith('.zip') || cleanPath.endsWith('.tar')) {
        return Colors.amber;
      }
      return Theme.of(context).colorScheme.primary;
    }

    void _showErrorDialog(BuildContext context, String title, String message) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }

    String _getFriendlyError(OpenResult result) {
      switch (result.type) {
        case ResultType.noAppToOpen:
          return "No compatible application is installed on your device to open this file type. Please install an appropriate app and try again.";
        case ResultType.fileNotFound:
          return "The file could not be found on your device.";
        case ResultType.permissionDenied:
          return "Access denied. Please grant file storage/access permissions.";
        default:
          return result.message;
      }
    }

    Future<void> _extractArchive(BuildContext context, File file) async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text("Extracting archive..."),
                  ],
                ),
              ),
            ),
          );
        },
      );

      try {
        final bytes = file.readAsBytesSync();
        Archive archive;
        final extension = file.path.split('.').last.toLowerCase();
        if (extension == 'zip') {
          archive = ZipDecoder().decodeBytes(bytes);
        } else if (extension == 'tar') {
          archive = TarDecoder().decodeBytes(bytes);
        } else {
          throw Exception(
            "Extraction is supported only for ZIP and TAR archives.",
          );
        }

        final tempDir = await getTemporaryDirectory();
        final outDir = Directory(
          '${tempDir.path}/${file.path.split('/').last.split('.').first}_extracted',
        );
        if (!outDir.existsSync()) {
          outDir.createSync(recursive: true);
        }

        String? firstFilePath;
        for (final archiveFile in archive) {
          final filename = archiveFile.name;
          if (archiveFile.isFile) {
            final data = archiveFile.content as List<int>;
            final outFile = File('${outDir.path}/$filename');
            outFile.createSync(recursive: true);
            outFile.writeAsBytesSync(data);
            firstFilePath ??= outFile.path;
          } else {
            Directory('${outDir.path}/$filename').createSync(recursive: true);
          }
        }

        if (context.mounted) Navigator.pop(context);

        if (firstFilePath != null) {
          final openRes = await OpenFilex.open(firstFilePath);
          if (openRes.type != ResultType.done && context.mounted) {
            _showErrorDialog(
              context,
              "Archive Extracted",
              "Extracted files. Failed to open first file: ${_getFriendlyError(openRes)}",
            );
          }
        } else {
          final openRes = await OpenFilex.open(outDir.path);
          if (openRes.type != ResultType.done && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Archive extracted to: ${outDir.path}")),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          _showErrorDialog(context, "Extraction Failed", e.toString());
        }
      }
    }

    Future<void> _handleArchiveTap(BuildContext context, File file) async {
      final cleanPath = file.path.toLowerCase();
      final extension = cleanPath.split('.').last;
      if (extension != 'zip' && extension != 'tar') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Archive Option"),
            content: Text(
              "Direct extraction is only supported for ZIP/TAR. Would you like to try opening this $extension archive using the system app?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final openRes = await OpenFilex.open(file.path);
                  if (openRes.type != ResultType.done && context.mounted) {
                    _showErrorDialog(
                      context,
                      "Error Opening File",
                      _getFriendlyError(openRes),
                    );
                  }
                },
                child: const Text("Open"),
              ),
            ],
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Extract Archive"),
          content: const Text(
            "Would you like to extract this archive locally?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _extractArchive(context, file);
              },
              child: const Text("Extract"),
            ),
          ],
        ),
      );
    }

    void _showImagePreview(
      BuildContext context, {
      required String imageUrl,
      required String name,
    }) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Text(
                      name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Future<void> _processFileOpen(
      BuildContext context,
      String localPath,
      String fileName,
    ) async {
      final cleanPath = localPath.toLowerCase();
      final extension = cleanPath.split('.').last;

      if (_isImage(cleanPath)) {
        _showImagePreview(context, imageUrl: localPath, name: fileName);
      } else if (extension == 'zip' ||
          extension == 'tar') {
        await _handleArchiveTap(context, File(localPath));
      } else {
        final result = await OpenFilex.open(localPath);
        if (result.type != ResultType.done && context.mounted) {
          _showErrorDialog(
            context,
            "Cannot Open File",
            _getFriendlyError(result),
          );
        }
      }
    }

    Future<void> _openRemoteFile(
      BuildContext context,
      String url,
      String fileName,
    ) async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text("Downloading file..."),
                  ],
                ),
              ),
            ),
          );
        },
      );

      try {
        final dio = Dio();
        final tempDir = await getTemporaryDirectory();
        final localPath = '${tempDir.path}/$fileName';

        await dio.download(url, localPath);

        if (context.mounted) Navigator.pop(context);

        if (context.mounted) {
          await _processFileOpen(context, localPath, fileName);
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          _showErrorDialog(
            context,
            "Download Failed",
            "Failed to download the attachment: $e",
          );
        }
      }
    }

    if (_attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            "Attachments",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              final att = _attachments[index];
              var imageUrl = att["file_url"] ?? '';
              if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                imageUrl = "https://prakrutitech.xyz/krish/$imageUrl";
              }
              final fileName =
                  att["original_name"] ??
                  (imageUrl.isNotEmpty
                      ? imageUrl.split('/').last
                      : 'attachment');
              final isImg = _isImage(fileName);

              return GestureDetector(
                onTap: () {
                  if (imageUrl.isNotEmpty) {
                    if (isImg) {
                      _showImagePreview(
                        context,
                        imageUrl: imageUrl,
                        name: fileName,
                      );
                    } else {
                      _openRemoteFile(context, imageUrl, fileName);
                    }
                  }
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: isImg && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                _getFileIcon(fileName),
                                color: _getFileIconColor(context, fileName),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            _getFileIcon(fileName),
                            color: _getFileIconColor(context, fileName),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
