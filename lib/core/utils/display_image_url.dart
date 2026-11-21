/// URL tampilan gambar: bungkus jsDelivr dengan wsrv.nl untuk resize.
/// URL ImageKit / lain dikembalikan apa adanya.
String? displayImageUrl(
  String? url, {
  int? width,
  int? height,
}) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null) return url;

  final host = uri.host.toLowerCase();
  final isJsDelivr = host == 'cdn.jsdelivr.net' || host.endsWith('.jsdelivr.net');
  if (!isJsDelivr) return url;

  final originPath = '${uri.host}${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
  return Uri.https('wsrv.nl', '/', {
    'url': originPath,
    if (width != null) 'w': '$width',
    if (height != null) 'h': '$height',
    'fit': 'cover',
    'output': 'webp',
  }).toString();
}

/// jsDelivr `gh/owner/repo@branch/path` → raw.githubusercontent (langsung
/// dari GitHub, tanpa tunggu purge CDN). Null kalau URL bukan jsDelivr gh.
///
/// Dipakai sebagai fallback setelah unggah foto: file sudah ada di branch
/// GitHub, tapi cdn.jsdelivr.net / wsrv.nl sering masih 404 atau menggantung
/// sampai Action purge selesai - itu yang bikin Skeletonizer placeholder
/// tidak hilang.
String? jsDelivrToRawGithubUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  if (host != 'cdn.jsdelivr.net' && !host.endsWith('.jsdelivr.net')) {
    return null;
  }
  final segs = uri.pathSegments;
  // /gh/{owner}/{repo}@{branch}/{path...}
  if (segs.length < 3 || segs.first != 'gh') return null;
  final owner = segs[1];
  final repoAtBranch = segs[2];
  final at = repoAtBranch.indexOf('@');
  if (at <= 0 || at >= repoAtBranch.length - 1) return null;
  final repo = repoAtBranch.substring(0, at);
  final branch = repoAtBranch.substring(at + 1);
  final filePath = segs.skip(3).join('/');
  if (owner.isEmpty || repo.isEmpty || branch.isEmpty || filePath.isEmpty) {
    return null;
  }
  return 'https://raw.githubusercontent.com/$owner/$repo/$branch/$filePath';
}
