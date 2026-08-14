import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

class CustomField {
  String label;
  String value;
  CustomField({required this.label, required this.value});
}

class AttachedFile {
  final int id;
  final String name;
  final String size;
  final String imageUrl;

  AttachedFile({
    required this.id,
    required this.name,
    required this.size,
    required this.imageUrl,
  });
}

class InputTile extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const InputTile({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}

class PasswordTile extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final double strength;
  final Color strengthColor;
  final VoidCallback onToggleVisibility;
  final VoidCallback onGenerate;

  const PasswordTile({
    super.key,
    required this.controller,
    required this.obscure,
    required this.strength,
    required this.strengthColor,
    required this.onToggleVisibility,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                  onPressed: onToggleVisibility,
                ),
                IconButton(
                  icon: const Icon(Icons.casino_outlined),
                  tooltip: 'Generate password',
                  onPressed: onGenerate,
                ),
              ],
            ),
          ),
        ),
        if (controller.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: strength,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ],
    );
  }
}

class UrlTile extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const UrlTile({super.key, required this.controller, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
        labelText: 'Website URL',
        prefixIcon: const Icon(Icons.link_rounded),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: onClear,
        ),
      ),
    );
  }
}

class CustomFieldTile extends StatelessWidget {
  final CustomField field;
  final VoidCallback onDelete;

  const CustomFieldTile({super.key, required this.field, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final valueCtrl = TextEditingController(text: field.value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: valueCtrl,
              onChanged: (v) => field.value = v,
              decoration: InputDecoration(
                labelText: field.label,
                prefixIcon: const Icon(Icons.label_outline_rounded),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline_rounded,
              color: Colors.redAccent,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class FileTile extends StatelessWidget {
  final AttachedFile file;
  final VoidCallback onDelete;

  const FileTile({super.key, required this.file, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isImg = isImage(
      file.imageUrl.isNotEmpty ? file.imageUrl : file.name,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isImg) {
            showImagePreview(
              context,
              imageUrl: file.imageUrl,
              name: file.name,
            );
          } else {
            openRemoteFile(context, file.imageUrl, file.name);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: isImg && file.imageUrl.isNotEmpty
                    ? Image.network(
                        file.imageUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            getFileIcon(file.name),
                            color: getFileIconColor(context, file.name),
                          );
                        },
                      )
                    : Icon(
                        getFileIcon(file.name),
                        color: getFileIconColor(context, file.name),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      file.size,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: Colors.redAccent,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocalFileTile extends StatelessWidget {
  final File file;
  final VoidCallback onDelete;

  const LocalFileTile({super.key, required this.file, required this.onDelete});

  String _getFileSizeString(File file) {
    try {
      int bytes = file.lengthSync();
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    } catch (e) {
      return "0.0 KB";
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = file.path.split('/').last;
    final isImg = isImage(file.path);
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await processFileOpen(context, file.path, fileName);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: isImg
                    ? Image.file(
                        file,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            getFileIcon(fileName),
                            color: getFileIconColor(context, fileName),
                          );
                        },
                      )
                    : Icon(
                        getFileIcon(fileName),
                        color: getFileIconColor(context, fileName),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getFileSizeString(file),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: Colors.redAccent,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotesTile extends StatelessWidget {
  final TextEditingController controller;
  const NotesTile({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: const InputDecoration(
        hintText: 'Add some secure notes here...',
        alignLabelWithHint: true,
      ),
    );
  }
}

bool isImage(String pathOrUrl) {
  final mime = pathOrUrl.split('?').first.toLowerCase();
  return mime.endsWith('.jpg') ||
      mime.endsWith('.jpeg') ||
      mime.endsWith('.png') ||
      mime.endsWith('.gif') ||
      mime.endsWith('.webp') ||
      mime.endsWith('.heic');
}

IconData getFileIcon(String pathOrUrl) {
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

Color getFileIconColor(BuildContext context, String pathOrUrl) {
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

void showErrorDialog(BuildContext context, String title, String message) {
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

String getFriendlyError(OpenResult result) {
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

Future<void> extractArchive(BuildContext context, File file) async {
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
      throw Exception("Extraction is supported only for ZIP and TAR archives.");
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
        showErrorDialog(
          context,
          "Archive Extracted",
          "Extracted files. Failed to open first file: ${getFriendlyError(openRes)}",
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
      showErrorDialog(context, "Extraction Failed", e.toString());
    }
  }
}

Future<void> handleArchiveTap(BuildContext context, File file) async {
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
                showErrorDialog(
                  context,
                  "Error Opening File",
                  getFriendlyError(openRes),
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
      content: const Text("Would you like to extract this archive locally?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            extractArchive(context, file);
          },
          child: const Text("Extract"),
        ),
      ],
    ),
  );
}

void showImagePreview(
  BuildContext context, {
  String? imageUrl,
  File? file,
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
                title: Text(name, style: const TextStyle(color: Colors.white)),
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
                  child: file != null
                      ? Image.file(
                          file,
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
                        )
                      : Image.network(
                          imageUrl!,
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

Future<void> processFileOpen(
  BuildContext context,
  String localPath,
  String fileName,
) async {
  final cleanPath = localPath.toLowerCase();
  final extension = cleanPath.split('.').last;

  if (isImage(cleanPath)) {
    showImagePreview(context, file: File(localPath), name: fileName);
  } else if (extension == 'zip' ||
      extension == 'tar') {
    await handleArchiveTap(context, File(localPath));
  } else {
    final result = await OpenFilex.open(localPath);
    if (result.type != ResultType.done && context.mounted) {
      showErrorDialog(context, "Cannot Open File", getFriendlyError(result));
    }
  }
}

Future<void> openRemoteFile(
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
      await processFileOpen(context, localPath, fileName);
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      showErrorDialog(
        context,
        "Download Failed",
        "Failed to download the attachment: $e",
      );
    }
  }
}
