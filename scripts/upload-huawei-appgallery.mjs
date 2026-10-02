#!/usr/bin/env node
// Upload AAB sebagai draft ke Huawei AppGallery Connect (Publishing API v2, alur OBS).
// Submit (review) manual di AppGallery Connect, konsisten dengan flow Play
// (draft + rollout manual). Pakai --submit untuk auto submit ke review.
//
// Alur (2026): token -> upload-url/for-obs (objectId + signed PUT url)
//   -> PUT file ke OBS -> PUT app-file-info (fileDestUrl = objectId)
//
// Env:
//   HUAWEI_CLIENT_ID / HUAWEI_CLIENT_SECRET - API client AGC
//     (AppGallery Connect -> Users and permissions -> API Key -> Connect API)
//   HUAWEI_APP_ID - ID app di AGC (My apps -> App information -> APP ID)
// Jika env kosong, script keluar 0 dengan pesan skip (aman untuk CI).
//
// Usage: node scripts/upload-huawei-appgallery.mjs <path.aab> [--submit]

const BASE = 'https://connect-api.cloud.huawei.com';
const SUBMIT_RETRY_MAX = 30; // 30 x 30s = 15 menit untuk kompilasi AAB
const SUBMIT_RETRY_DELAY_MS = 30_000;

const clientId = process.env.HUAWEI_CLIENT_ID ?? '';
const clientSecret = process.env.HUAWEI_CLIENT_SECRET ?? '';
const appId = process.env.HUAWEI_APP_ID ?? '';
const args = process.argv.slice(2);
const submitAfterUpload = args.includes('--submit');
const aabPath = args.find((a) => !a.startsWith('--'));

if (!clientId || !clientSecret || !appId) {
  console.log('Skip: HUAWEI_CLIENT_ID / HUAWEI_CLIENT_SECRET / HUAWEI_APP_ID tidak diset.');
  process.exit(0);
}
if (!aabPath) {
  console.error('Usage: node scripts/upload-huawei-appgallery.mjs <path.aab> [--submit]');
  process.exit(1);
}
const { createReadStream } = await import('node:fs');
const { stat } = await import('node:fs/promises');
const { request: httpsRequest } = await import('node:https');
const { size } = await stat(aabPath);
console.log(`Uploading ${aabPath} (${size} bytes) ke AppGallery app ${appId}`);

function assertOk(ret, what) {
  if (!ret || ret.code !== 0) {
    throw new Error(`${what} gagal: ${JSON.stringify(ret)}`);
  }
}

async function api(method, path, body, headers = {}) {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: { 'Content-Type': 'application/json', client_id: clientId, ...headers },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await res.text();
  let json;
  try {
    json = JSON.parse(text);
  } catch {
    throw new Error(`${method} ${path} response bukan JSON (HTTP ${res.status}): ${text.slice(0, 300)}`);
  }
  assertOk(json.ret, `${method} ${path}`);
  return json;
}

// 1. Access token (client_credentials, berlaku 48 jam).
const tokenRes = await fetch(`${BASE}/api/oauth2/v1/token`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ grant_type: 'client_credentials', client_id: clientId, client_secret: clientSecret }),
});
const tokenJson = await tokenRes.json();
if (!tokenJson.access_token) {
  throw new Error(`Token request gagal: ${JSON.stringify(tokenJson)}`);
}
const auth = { Authorization: `Bearer ${tokenJson.access_token}` };
console.log('1/4 Token OK');

// 2. URL upload OBS + objectId + headers signature. chineseMainlandFlag=0:
//    distribusi luar China daratan.
const fileName = aabPath.split('/').pop();
const obsParams = new URLSearchParams({
  appId,
  suffix: 'aab',
  fileName,
  contentLength: String(size),
  chineseMainlandFlag: '0',
});
const obs = await api(
  'GET',
  `/api/publish/v2/upload-url/for-obs?${obsParams}`,
  undefined,
  auth,
);
const { objectId, url: obsUrl, headers: obsHeaders, method: obsMethod = 'PUT' } = obs.urlInfo;
if (!objectId || !obsUrl) {
  throw new Error(`upload-url/for-obs tidak lengkap: ${JSON.stringify(obs).slice(0, 300)}`);
}
console.log(`2/4 OBS upload URL didapat (objectId ${objectId.slice(0, 40)}...)`);

// 3. PUT file ke OBS dengan headers signature. Content-Length wajib ikut
//    karena masuk signature (x-amz-content-sha256). Pakai node:https streaming,
//    bukan fetch: undici headersTimeout 300s kekejar untuk AAB besar koneksi lambat.
const putRes = await new Promise((resolve, reject) => {
  const u = new URL(obsUrl);
  const req = httpsRequest(
    u,
    { method: obsMethod, headers: { ...obsHeaders, 'Content-Length': String(size) } },
    (res) => {
      let text = '';
      res.on('data', (c) => (text += c));
      res.on('end', () => resolve({ ok: res.statusCode >= 200 && res.statusCode < 300, status: res.statusCode, text }));
    },
  );
  req.on('error', reject);
  createReadStream(aabPath).pipe(req);
});
if (!putRes.ok) {
  throw new Error(`Upload OBS gagal (HTTP ${putRes.status}): ${putRes.text.slice(0, 300)}`);
}
console.log('3/4 File terupload ke OBS');

// 4. Daftarkan paket AAB (fileType=5) pada draft version. fileDestUrl diisi
//    objectId dari langkah 2, bukan URL - error "not objectId" kalau URL.
await api(
  'PUT',
  `/api/publish/v2/app-file-info?appId=${appId}`,
  {
    fileType: 5,
    files: [{ fileName, fileDestUrl: objectId }],
  },
  auth,
);
console.log('4/4 Paket AAB terdaftar sebagai draft di AppGallery Connect');

if (submitAfterUpload) {
  for (let attempt = 1; attempt <= SUBMIT_RETRY_MAX; attempt++) {
    try {
      await api('POST', `/api/publish/v2/app-submit?appId=${appId}`, { releaseType: 1 }, auth);
      console.log('App disubmit untuk review.');
      break;
    } catch (err) {
      if (!/is being processed/i.test(String(err.message)) || attempt === SUBMIT_RETRY_MAX) {
        throw err;
      }
      console.log(`AAB masih diproses Huawei, retry ${attempt}/${SUBMIT_RETRY_MAX} dalam ${SUBMIT_RETRY_DELAY_MS / 1000}s...`);
      await new Promise((r) => setTimeout(r, SUBMIT_RETRY_DELAY_MS));
    }
  }
} else {
  console.log('Selesai (draft). Submit review manual di AppGallery Connect: My apps -> SambasKu -> Version -> atau https://developer.huawei.com/consumer/id/service/josp/agc/index.html');
}
