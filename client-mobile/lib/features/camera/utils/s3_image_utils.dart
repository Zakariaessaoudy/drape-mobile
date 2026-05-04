// Darija: Had utility kaykhdem m3a S3 URLs:
// kay3ref wach URL signed, kaykhrej s3 key, w kayencodeih l endpoint dyal AI.
class S3ImageUtils {
  const S3ImageUtils._();

  static bool isSignedUrl(String url) {
    return url.contains('X-Amz-Signature=');
  }

  static String? extractS3Key(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    if (!host.contains('s3')) return null;

    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;

    return segments.map(Uri.decodeComponent).join('/');
  }

  static String encodeS3Key(String s3Key) {
    return s3Key.split('/').map(Uri.encodeComponent).join('/');
  }
}
