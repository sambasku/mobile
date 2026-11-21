import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqflite/sqflite.dart';

import 'lemma_database_opener.dart';
import 'lemma_dataset_constants.dart';
import 'lemma_release_meta.dart';

enum LemmaDatasetUpdateOutcome {
  updated,
  alreadyLatest,
  offline,
  incompatibleSchema,
  appUpdateRequired,
  downloadFailed,
  hashMismatch,
  swapFailed,
  invalidPointer,
  busy,
}

class LemmaDatasetUpdateResult {
  const LemmaDatasetUpdateResult(
    this.outcome, {
    this.remote,
    this.localReleaseVersion,
    this.message,
  });

  final LemmaDatasetUpdateOutcome outcome;
  final LemmaReleaseMeta? remote;
  final int? localReleaseVersion;
  final String? message;
}

/// OTA manual: upgrade-only dari active.json.
class LemmaDatasetUpdater {
  LemmaDatasetUpdater({
    required this.dio,
    required this.opener,
    this.isOnline = true,
    this.onBeforeSwap,
    this.onAfterSwap,
    this.packageInfoLoader,
  });

  final Dio dio;
  final LemmaDatabaseOpener opener;
  final bool isOnline;
  final Future<void> Function()? onBeforeSwap;
  final Future<void> Function()? onAfterSwap;
  final Future<PackageInfo> Function()? packageInfoLoader;

  bool _busy = false;
  bool get isBusy => _busy;

  Future<LemmaDatasetUpdateResult> update() async {
    if (_busy) {
      return const LemmaDatasetUpdateResult(LemmaDatasetUpdateOutcome.busy);
    }
    _busy = true;
    try {
      if (!isOnline) {
        return const LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.offline,
        );
      }

      final localVersion = await _resolveLocalVersion();
      final active = await _fetchActiveJson();
      if (active == null) {
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.invalidPointer,
          localReleaseVersion: localVersion,
        );
      }

      if (active.releaseVersion <= localVersion) {
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.alreadyLatest,
          remote: active,
          localReleaseVersion: localVersion,
        );
      }

      if (active.schemaVersion !=
          LemmaDatasetConstants.supportedSchemaVersion) {
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.incompatibleSchema,
          remote: active,
          localReleaseVersion: localVersion,
        );
      }

      final appInfo =
          await (packageInfoLoader?.call() ?? PackageInfo.fromPlatform());
      if (!_appMeetsMin(appInfo.version, active.minAppVersion)) {
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.appUpdateRequired,
          remote: active,
          localReleaseVersion: localVersion,
        );
      }

      final url = active.databaseUrl;
      final expectedSha = active.sha256;
      if (url == null ||
          url.isEmpty ||
          expectedSha == null ||
          expectedSha.isEmpty) {
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.invalidPointer,
          remote: active,
          localReleaseVersion: localVersion,
        );
      }
      if (!_hostAllowed(url)) {
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.downloadFailed,
          remote: active,
          localReleaseVersion: localVersion,
          message: 'host_not_allowed',
        );
      }

      final dir = await opener.datasetDir();
      final gzPath = '${dir.path}/download_${active.releaseVersion}.sqlite.gz';
      final newPath = await opener.newPath();
      final livePath = await opener.livePath();
      final bakPath = await opener.bakPath();

      for (final path in [gzPath, newPath]) {
        await _deleteQuiet(path);
      }

      try {
        await dio.download(
          url,
          gzPath,
          options: Options(
            receiveTimeout: const Duration(minutes: 2),
            sendTimeout: LemmaDatasetConstants.activeJsonTimeout,
            followRedirects: true,
            maxRedirects: 5,
            validateStatus: (s) => s != null && s >= 200 && s < 300,
          ),
        );
      } catch (e) {
        await _deleteQuiet(gzPath);
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.downloadFailed,
          remote: active,
          localReleaseVersion: localVersion,
          message: e.toString(),
        );
      }

      final gzBytes = await File(gzPath).readAsBytes();
      final actualSha = sha256.convert(gzBytes).toString();
      if (actualSha.toLowerCase() != expectedSha.toLowerCase()) {
        await _deleteQuiet(gzPath);
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.hashMismatch,
          remote: active,
          localReleaseVersion: localVersion,
        );
      }

      try {
        final uncompressed = gzip.decode(gzBytes);
        await File(newPath).writeAsBytes(uncompressed, flush: true);
      } catch (e) {
        await _deleteQuiet(gzPath);
        await _deleteQuiet(newPath);
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.downloadFailed,
          remote: active,
          localReleaseVersion: localVersion,
          message: 'gunzip:$e',
        );
      } finally {
        await _deleteQuiet(gzPath);
      }

      Database? smoke;
      try {
        smoke = await openDatabase(
          newPath,
          readOnly: true,
          singleInstance: false,
        );
        await smoke.rawQuery('SELECT 1');
        final smokeMeta = await opener.readMetaFromDb(smoke);
        if (smokeMeta.releaseVersion != active.releaseVersion) {
          throw StateError('release_meta mismatch');
        }
      } catch (e) {
        await opener.closeQuietly(smoke);
        await _deleteQuiet(newPath);
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.swapFailed,
          remote: active,
          localReleaseVersion: localVersion,
          message: 'smoke:$e',
        );
      }
      await opener.closeQuietly(smoke);

      try {
        await onBeforeSwap?.call();
        final live = File(livePath);
        final bak = File(bakPath);
        final neu = File(newPath);
        if (await bak.exists()) {
          await bak.delete();
        }
        if (await live.exists()) {
          await live.rename(bakPath);
        }
        await neu.rename(livePath);

        Database? liveDb;
        try {
          liveDb = await openDatabase(
            livePath,
            readOnly: true,
            singleInstance: false,
          );
          await liveDb.rawQuery('SELECT 1');
          final meta = await opener.readMetaFromDb(liveDb);
          await opener.closeQuietly(liveDb);
          await opener.persistMeta(meta);
        } catch (e) {
          await opener.closeQuietly(liveDb);
          if (await File(bakPath).exists()) {
            if (await File(livePath).exists()) {
              await File(livePath).delete();
            }
            await File(bakPath).rename(livePath);
          }
          await _deleteQuiet(newPath);
          return LemmaDatasetUpdateResult(
            LemmaDatasetUpdateOutcome.swapFailed,
            remote: active,
            localReleaseVersion: localVersion,
            message: 'reopen:$e',
          );
        }

        await onAfterSwap?.call();
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.updated,
          remote: active,
          localReleaseVersion: active.releaseVersion,
        );
      } catch (e) {
        return LemmaDatasetUpdateResult(
          LemmaDatasetUpdateOutcome.swapFailed,
          remote: active,
          localReleaseVersion: localVersion,
          message: e.toString(),
        );
      }
    } finally {
      _busy = false;
    }
  }

  Future<int> _resolveLocalVersion() async {
    final prefsMeta = await opener.installedMetaFromPrefs();
    var localVersion = prefsMeta?.releaseVersion ?? 0;
    final livePath = await opener.livePath();
    if (!await File(livePath).exists()) return localVersion;
    Database? probe;
    try {
      probe = await openDatabase(
        livePath,
        readOnly: true,
        singleInstance: false,
      );
      localVersion = (await opener.readMetaFromDb(probe)).releaseVersion;
    } catch (_) {
      // prefs
    } finally {
      await opener.closeQuietly(probe);
    }
    return localVersion;
  }

  Future<LemmaReleaseMeta?> _fetchActiveJson() async {
    try {
      final resp = await dio.get<dynamic>(
        LemmaDatasetConstants.activeJsonUrl,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: LemmaDatasetConstants.activeJsonTimeout,
          sendTimeout: LemmaDatasetConstants.activeJsonTimeout,
          connectTimeout: LemmaDatasetConstants.activeJsonTimeout,
        ),
      );
      final raw = resp.data;
      final text = raw is String ? raw : raw?.toString();
      if (text == null || text.isEmpty) return null;
      final json = jsonDecode(text) as Map<String, dynamic>;
      return LemmaReleaseMeta.fromActiveJson(json);
    } catch (_) {
      return null;
    }
  }

  bool _hostAllowed(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return false;
    return LemmaDatasetConstants.allowedDownloadHosts.contains(uri.host);
  }

  bool _appMeetsMin(String appVersion, String? minApp) {
    if (minApp == null || minApp.trim().isEmpty) return true;
    List<int> parts(String v) {
      final core = v.split('+').first.split('-').first;
      return core
          .split('.')
          .map((p) => int.tryParse(p) ?? 0)
          .toList(growable: false);
    }

    final a = parts(appVersion);
    final b = parts(minApp);
    final len = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av > bv) return true;
      if (av < bv) return false;
    }
    return true;
  }

  Future<void> _deleteQuiet(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
