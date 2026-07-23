import 'dart:io';

/// Moves one legacy storage file into the current app directory when needed.
///
/// Existing data in [destinationFile] always wins. The legacy file is only
/// moved when no destination exists, so migration can never overwrite data
/// created by Floatick.
Future<void> migrateLegacyFileIfNeeded({
  required Directory destinationDirectory,
  required File destinationFile,
  required Directory? legacyDirectory,
  required String fileName,
}) async {
  await destinationDirectory.create(recursive: true);
  if (await destinationFile.exists() || legacyDirectory == null) {
    return;
  }

  final legacyFile = File('${legacyDirectory.path}/$fileName');
  if (!await legacyFile.exists()) {
    return;
  }

  try {
    await destinationFile.create(exclusive: true);
  } on PathExistsException {
    return;
  }

  RandomAccessFile? destinationHandle;
  try {
    final legacyBytes = await legacyFile.readAsBytes();
    destinationHandle = await destinationFile.open(mode: FileMode.writeOnly);
    await destinationHandle.writeFrom(legacyBytes);
    await destinationHandle.flush();
    await destinationHandle.close();
    destinationHandle = null;
    await legacyFile.delete();
  } on FileSystemException {
    await destinationHandle?.close();
    if (await destinationFile.exists()) {
      await destinationFile.delete();
    }
    rethrow;
  }
}
