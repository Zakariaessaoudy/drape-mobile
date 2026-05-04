// Darija: Had utility kay3ref content-type dyal image mn file path.
// Hada kay3awn backend/AI yqblo image bla 400 error.
class ImageFileUtils {
  const ImageFileUtils._();

  static String contentTypeForPath(String path) {
    final lowerPath = path.toLowerCase();

    if (lowerPath.endsWith('.png')) return 'image/png';
    if (lowerPath.endsWith('.webp')) return 'image/webp';
    if (lowerPath.endsWith('.gif')) return 'image/gif';
    if (lowerPath.endsWith('.heic')) return 'image/heic';
    if (lowerPath.endsWith('.heif')) return 'image/heif';

    return 'image/jpeg';
  }
}
