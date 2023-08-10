import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:the_chat/keys.dart';

enum FileType {
  audio,
  video,
  image,
  document,
  other,
}

class AttachManager {
  AttachManager();

  selectFiles() async {
    List<String> errors = [];
    List<FilteredFile> correctFiles = [];

    final picker = await FilePicker.platform.pickFiles(
      allowCompression: true,
      allowMultiple: true,
    );

    List<PlatformFile> files = picker?.files ?? [];

    if (files.isEmpty) {
      GlobalSnackBar.show(
        "Se ha cancelado la subida de los archivos",
      );
      return;
    }

    for (PlatformFile file in files) {
      FileType firstCheck;
      FileType secondCheck;

      if (file.size == 0 || file.bytes == null) {
        errors.add("El archivo ${file.name} no pudo ser leído");
        continue;
      }

      if (file.bytes!.isEmpty) {
        errors.add("El archivo ${file.name} no contiene datos");
        continue;
      }

      if (file.bytes!.length < 16) {
        errors.add("El archivo ${file.name} es muy pequeño para comprobar");
        continue;
      }

      switch (file.extension) {
        case "mp4":
          firstCheck = FileType.video;
          break;
        case "jpg":
        case "png":
        case "jpeg":
        case "pneg":
        case "jfif":
          firstCheck = FileType.image;
          break;
        case "ogg":
        case "mp3":
        case "m4a":
          firstCheck = FileType.audio;
          break;
        case "doc":
        case "docx":
        case "ppt":
        case "pptx":
        case "xls":
        case "xlsx":
        case "pdf":
        case "txt":
          firstCheck = FileType.document;
          break;
        default:
          firstCheck = FileType.other;
      }

      String? mimetype = lookupMimeType(file.name,
          headerBytes: file.bytes!.getRange(0, 64).toList());

      if (mimetype == null || mimetype.isEmpty) {
        errors.add("El archivo ${file.name} no se pudo determinar");
        continue;
      }

      if (mimetype.startsWith("image")) {
        secondCheck = FileType.image;
      } else if (mimetype.startsWith("video")) {
        secondCheck = FileType.video;
      } else if (mimetype.startsWith("audio")) {
        secondCheck = FileType.audio;
      } else if (mimetype.startsWith("application")) {
        secondCheck = FileType.document;
      } else if (mimetype.startsWith("text")) {
        secondCheck = FileType.document;
      } else {
        secondCheck = FileType.other;
      }

      if (firstCheck != secondCheck) {
        errors.add("El archivo ${file.name} no se pudo determinar");
        continue;
      }

      if (firstCheck == FileType.image && file.size > 1024 * 1024 * 5 ||
          firstCheck == FileType.audio && file.size > 1024 * 1024 * 7.5 ||
          firstCheck == FileType.other && file.size > 1024 * 1024 * 10 ||
          firstCheck == FileType.video && file.size > 1024 * 1024 * 15 ||
          firstCheck == FileType.document && file.size > 1024 * 1024 * 20) {
        errors.add("El archivo ${file.name} excede el tamaño máximo permitido");
        continue;
      }

      correctFiles.add(
        FilteredFile(file.name, type: firstCheck, bytes: file.bytes!),
      );
    }

    if (errors.isNotEmpty) {
      GlobalSnackBar.show(
        "Ocurrieron los siguientes errores y los siguientes archivos se omitieron: ${errors.map((e) => "\n$e")}",
      );
    }

    return correctFiles;
  }
}

class FilteredFile {
  final String name;
  final FileType type;
  final Uint8List bytes;

  FilteredFile(
    this.name, {
    required this.type,
    required this.bytes,
  });

  @override
  String toString() {
    return "File $name:\nType format: $type\nInitial Data: ${bytes.getRange(0, 10)}";
  }
}
