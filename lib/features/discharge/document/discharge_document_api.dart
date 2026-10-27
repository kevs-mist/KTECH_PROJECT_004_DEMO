import 'dart:io';
import 'dart:typed_data';

import '../../../data/api/admissions_api.dart';
import 'discharge_draft.dart';

abstract class DischargeDocumentApi {
  /// Builds the discharge summary PDF from the admission and the current form draft.
  Future<Uint8List> renderPdf(Admission admission, DischargeDraft draft);

  /// Writes bytes to a temp file and returns it.
  Future<File> saveToTemp(Uint8List bytes, String fileName);

  /// Opens the file in the OS default PDF viewer (Preview / Edge / Acrobat).
  Future<void> openExternally(File file);

  /// Opens the native print dialog.
  Future<void> printPdf(Uint8List bytes, String jobName);

  String suggestedFileName(Admission admission, DischargeDraft draft);
}
