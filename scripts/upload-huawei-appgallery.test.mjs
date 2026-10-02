#!/usr/bin/env node
// Self-check: jalankan `node --test scripts/upload-huawei-appgallery.test.mjs`
import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';

test('skip bersih tanpa env', () => {
  const r = spawnSync(process.execPath, ['scripts/upload-huawei-appgallery.mjs'], {
    env: {}, encoding: 'utf8',
  });
  assert.match((r.stdout ?? '') + (r.stderr ?? ''), /Skip:/);
  assert.equal(r.status, 0);
});

test('error jelas tanpa argumen file saat env ada', () => {
  const r = spawnSync('node', ['scripts/upload-huawei-appgallery.mjs'], {
    env: { ...process.env, HUAWEI_CLIENT_ID: 'x', HUAWEI_CLIENT_SECRET: 'y', HUAWEI_APP_ID: 'z' },
    encoding: 'utf8',
  });
  assert.match(r.stderr + r.stdout, /Usage:/);
  assert.equal(r.status, 1);
});
