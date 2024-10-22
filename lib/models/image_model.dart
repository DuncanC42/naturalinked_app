class PostImage {
  final int imageId;
  final String fileName;
  final String fileType;
  final String downloadUrl;


  PostImage({
    required this.imageId,
    required this.fileName,
    required this.fileType,
    required this.downloadUrl,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      imageId: json['imageId'] ?? 0,
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
    );
  }
}