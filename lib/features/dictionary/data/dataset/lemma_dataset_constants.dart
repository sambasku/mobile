/// Konstanta path & kontrak dataset lemma publik (offline).
abstract final class LemmaDatasetConstants {
  static const assetSqlite = 'assets/data/database.sqlite';
  static const assetBundleMeta = 'assets/data/bundle_meta.json';

  static const liveFileName = 'database.sqlite';
  static const bakFileName = 'database.sqlite.bak';
  static const newFileName = 'database.sqlite.new';
  static const dirName = 'lemma_dataset';

  static const activeJsonUrl =
      'https://raw.githubusercontent.com/sambasku/database/main/metadata/active.json';

  /// Schema yang didukung app ini (public schema v1).
  static const supportedSchemaVersion = 1;

  static const searchTimeout = Duration(seconds: 5);
  static const detailTimeout = Duration(seconds: 10);
  static const stickyDuration = Duration(seconds: 45);
  static const activeJsonTimeout = Duration(seconds: 8);

  static const prefsReleaseVersion = 'lemma_dataset_release_version';
  static const prefsSchemaVersion = 'lemma_dataset_schema_version';
  static const prefsInstalledAt = 'lemma_dataset_installed_at';

  static const allowedDownloadHosts = <String>{
    'raw.githubusercontent.com',
    'github.com',
    'objects.githubusercontent.com',
  };
}
