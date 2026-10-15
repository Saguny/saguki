import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'db.dart';
import 'theme.dart';
import 'transfer.dart';

/// Runs [job] behind a small blocking "working" dialog and reports the result.
Future<void> _busy(BuildContext context, String label, Future<String?> Function() job) async {
  final nav = Navigator.of(context), messenger = ScaffoldMessenger.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Row(children: [
        const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
        const SizedBox(width: 16),
        Text(label, style: T.callout),
      ]),
    ),
  );
  String? msg;
  try {
    msg = await job();
  } on FormatException catch (e) {
    msg = e.message;
  } catch (e) {
    msg = 'That didn’t work: $e';
  }
  nav.pop();
  if (msg != null) messenger.showSnackBar(SnackBar(content: Text(msg)));
}

Future<String?> _pick(List<String> exts) async {
  // Android can't filter custom extensions like .sgki, so pick anything and check here.
  final files = await FilePicker.pickFiles(dialogTitle: 'Import');
  if (files.isEmpty) return null;
  final path = files.first.path;
  if (path == null) return null;
  final ext = path.split('.').last.toLowerCase();
  if (!exts.contains(ext)) throw FormatException('Choose a ${exts.map((e) => '.$e').join(', ')} file');
  return path;
}

/// Import a .sgki backup or an Anki .apkg/.colpkg into the collection.
Future<void> importFile(BuildContext context) => _busy(context, 'Importing…', () async {
      final path = await _pick(['sgki', 'saguki', 'apkg', 'colpkg']); // .saguki: older exports
      if (path == null) return null;
      return !RegExp(r'\.(apkg|colpkg)$', caseSensitive: false).hasMatch(path)
          ? importSaguki(await File(path).readAsBytes())
          : importAnki(path);
    });

Future<void> importCsvInto(BuildContext context, Deck deck) => _busy(context, 'Importing…', () async {
      final path = await _pick(['csv', 'tsv', 'txt']);
      if (path == null) return null;
      return importCsv(await File(path).readAsString(), deck);
    });

/// Export everything ([deck] null) or one deck, as .sgki or CSV.
Future<void> exportFile(BuildContext context, {Deck? deck, bool csv = false}) =>
    _busy(context, 'Exporting…', () async {
      final base = (deck?.name ?? 'saguki-${DateTime.now().toIso8601String().substring(0, 10)}')
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final bytes = csv
          ? Uint8List.fromList(utf8.encode('﻿${await exportCsv(deck!.id)}')) // BOM so Excel reads CJK
          : Uint8List.fromList(await exportSaguki(deckId: deck?.id));
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Export',
        fileName: '$base.${csv ? 'csv' : 'sgki'}',
        bytes: bytes,
      );
      return uri == null ? null : 'Exported';
    });
