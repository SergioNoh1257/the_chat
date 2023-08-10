import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:the_chat/keys.dart';

class UploaderFile {
  final String fileName;
  final String fileExtension;
  final int fileSize;
  final Uint8List? bytes;

  UploaderFile({
    required this.fileName,
    required this.fileSize,
    required this.fileExtension,
    required this.bytes,
  });
}

class Uploader {
  Future<UploaderFile?> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowCompression: true,
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      lockParentWindow: true,
      dialogTitle: "Seleccione una imágen",
      allowedExtensions: ["png", "pneg", "jpg", "jpeg"],
    );

    if (result == null) {
      _showNullMessage();
      return null;
    }

    final PlatformFile file = result.files.first;

    if (file.size > 1024 * 1024 * 5) {
      _showLimitExcededMessage(5);
      return null;
    }

    return UploaderFile(
      fileName: _formatName(file.name),
      fileExtension: "Image",
      fileSize: file.size,
      bytes: file.bytes,
    );
  }

  Future<UploaderFile?> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowCompression: true,
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      lockParentWindow: true,
      dialogTitle: "Seleccione un archivo de audio",
      allowedExtensions: ["mp3", "ogg", "m4a"],
    );

    if (result == null) {
      _showNullMessage();
      return null;
    }

    final PlatformFile file = result.files.first;

    if (file.size > 1024 * 1024 * 10) {
      _showLimitExcededMessage(10);
      return null;
    }

    return UploaderFile(
      fileName: _formatName(file.name),
      fileExtension: "Audio",
      fileSize: file.size,
      bytes: file.bytes,
    );
  }

  Future<UploaderFile?> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowCompression: true,
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      lockParentWindow: true,
      dialogTitle: "Seleccione un video",
      allowedExtensions: ["mp4"],
    );

    if (result == null) {
      _showNullMessage();
      return null;
    }

    final PlatformFile file = result.files.first;

    if (file.size > 1024 * 1024 * 15) {
      _showLimitExcededMessage(15);
      return null;
    }

    return UploaderFile(
      fileName: _formatName(file.name),
      fileExtension: "Video",
      fileSize: file.size,
      bytes: file.bytes,
    );
  }

  Future<UploaderFile?> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowCompression: true,
      allowMultiple: false,
      withData: true,
      type: FileType.any,
      lockParentWindow: true,
      dialogTitle: "Seleccione un archivo",
    );

    if (result == null) {
      _showNullMessage();
      return null;
    }

    final PlatformFile file = result.files.first;

    if (file.size > 1024 * 1024 * 20) {
      _showLimitExcededMessage(20);
      return null;
    }

    return UploaderFile(
      fileName: _formatName(file.name),
      fileExtension: "Document",
      fileSize: file.size,
      bytes: file.bytes,
    );
  }

  _showNullMessage() {
    GlobalSnackBar.show("Se canceló la subida del archivo");
  }

  _showLimitExcededMessage(double maxSize) {
    GlobalSnackBar.show("No puedes subir un video de más de $maxSize MiB");
  }

  _formatName(String name) {
    return name.replaceAll(
      RegExp(
        r'([^\w\s.]|_)',
        caseSensitive: false,
        multiLine: true,
      ),
      "",
    );
  }
}
