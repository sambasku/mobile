import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'lemma_dataset_constants.dart';
import 'lemma_release_meta.dart';

/// Hasil open DB lemma lokal.
class LemmaDatabaseHandle {
  const LemmaDatabaseHandle({
    required this.db,
    required this.meta,
    required this.livePath,
  });

  final Database db;
  final LemmaReleaseMeta meta;
  final String livePath;
}

/// Copy asset → documents, buka read-only, siap untuk query lokal.
class LemmaDatabaseOpener {
  LemmaDatabaseOpener({
    SharedPreferences? prefs,
    AssetBundle? bundle,
  })  : _prefs = prefs,
        _bundle = bundle ?? rootBundle;

  final SharedPreferences? _prefs;
  final AssetBundle _bundle;

  Future<SharedPreferences> _prefsOr() async =>
      _prefs ?? await SharedPreferences.getInstance();

  Future<Directory> datasetDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, LemmaDatasetConstants.dirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> livePath() async =>
      p.join((await datasetDir()).path, LemmaDatasetConstants.liveFileName);

  Future<String> bakPath() async =>
      p.join((await datasetDir()).path, LemmaDatasetConstants.bakFileName);

  Future<String> newPath() async =>
      p.join((await datasetDir()).path, LemmaDatasetConstants.newFileName);

  Future<LemmaReleaseMeta> readBundleMeta() async {
    final raw = await _bundle.loadString(LemmaDatasetConstants.assetBundleMeta);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return LemmaReleaseMeta.fromBundleMeta(json);
  }

  Future<LemmaReleaseMeta> readMetaFromDb(Database db) async {
    final rows = await db.query('release_meta');
    final map = <String, String>{
      for (final row in rows)
        if (row['key'] != null && row['value'] != null)
          row['key']!.toString(): row['value']!.toString(),
    };
    return LemmaReleaseMeta(
      releaseVersion: int.tryParse(map['release_version'] ?? '') ?? 0,
      schemaVersion: int.tryParse(map['schema_version'] ?? '') ?? 1,
      channel: map['channel'],
      releasedAt: map['released_at'],
    );
  }

  Future<void> persistMeta(LemmaReleaseMeta meta) async {
    final prefs = await _prefsOr();
    await prefs.setInt(
      LemmaDatasetConstants.prefsReleaseVersion,
      meta.releaseVersion,
    );
    await prefs.setInt(
      LemmaDatasetConstants.prefsSchemaVersion,
      meta.schemaVersion,
    );
    await prefs.setString(
      LemmaDatasetConstants.prefsInstalledAt,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<LemmaReleaseMeta?> installedMetaFromPrefs() async {
    final prefs = await _prefsOr();
    final v = prefs.getInt(LemmaDatasetConstants.prefsReleaseVersion);
    if (v == null) return null;
    return LemmaReleaseMeta(
      releaseVersion: v,
      schemaVersion:
          prefs.getInt(LemmaDatasetConstants.prefsSchemaVersion) ?? 1,
    );
  }

  /// Pastikan file live ada / diperbarui dari asset bila bundle lebih baru.
  Future<void> ensureInstalledFromBundle() async {
    final live = File(await livePath());
    final bundleMeta = await readBundleMeta();
    final installed = await installedMetaFromPrefs();

    final needCopy = !await live.exists() ||
        installed == null ||
        bundleMeta.releaseVersion > installed.releaseVersion;

    if (!needCopy) return;

    final bytes = await _bundle.load(LemmaDatasetConstants.assetSqlite);
    final data = bytes.buffer.asUint8List(
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );
    await live.writeAsBytes(data, flush: true);
    await persistMeta(bundleMeta);
  }

  Future<LemmaDatabaseHandle> open() async {
    await ensureInstalledFromBundle();
    final path = await livePath();
    final db = await openDatabase(
      path,
      readOnly: true,
      singleInstance: false,
    );
    try {
      await db.rawQuery('SELECT 1');
      final meta = await readMetaFromDb(db);
      await persistMeta(meta);
      return LemmaDatabaseHandle(db: db, meta: meta, livePath: path);
    } catch (_) {
      await db.close();
      rethrow;
    }
  }

  Future<void> closeQuietly(Database? db) async {
    if (db == null) return;
    try {
      await db.close();
    } catch (_) {}
  }
}
