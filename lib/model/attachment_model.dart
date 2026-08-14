class AttachmentModel {
  final int id;
  final String originalName;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String fileUrl;
  final String createdAt;

  AttachmentModel({
    required this.id,
    required this.originalName,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.fileUrl,
    required this.createdAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: int.parse(json["id"].toString()),
      originalName: json["original_name"] ?? "",
      fileName: json["file_name"] ?? "",
      fileType: json["file_type"] ?? "",
      fileSize: int.parse(json["file_size"].toString()),
      fileUrl: json["file_url"] ?? "",
      createdAt: json["created_at"] ?? "",
    );
  }
}
