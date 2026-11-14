#!/usr/bin/env python3
"""Tie a release download to the exact commit, its test run and the
signing key, before it is published.

    python3 tools/release/release_manifest.py \\
        --ci-artifact dist-ci/   # the downloaded "NOTORYX-Core-Android-ARM64" artifact (has BUILD-INFO.json)
        --signed NOTORYX-Core-10.1.0-rc.2-arm64-v8a.apk \\
        --tag v10.1.0-rc.2 \\
        --out RELEASE-MANIFEST.json

It refuses (exit 1) when:
- the "Flutter and Dart" tests for that exact commit didn't pass, or never ran
  (a build-only run is not a test pass);
- the signed APK's contents differ from the CI build in anything but the
  signature (checked by comparing every non-signature entry);
- the signing certificate isn't the expected release certificate.

Needs `gh` (signed in). Reads the v2/v3 signing certificate itself; falls
back to `keytool` for v1-only APKs. Prints nothing secret.
"""
import argparse
import hashlib
import json
import re
import struct
import subprocess
import sys
import zipfile
from datetime import datetime, timezone

REPO = 'TheLogsAreScreaming/notoryx-core'
TEST_WORKFLOW = 'Flutter and Dart'
# SHA-256 of the release certificate (bastion-release.jks, alias bastion).
EXPECTED_CERT_PREFIX = '01834f7d'


def sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def unsigned_entries(apk):
    """Every entry except the signature files, with its CRC."""
    with zipfile.ZipFile(apk) as z:
        return {
            i.filename: i.CRC
            for i in z.infolist()
            if not re.match(r'META-INF/.*\.(SF|RSA|DSA|EC|MF)$', i.filename)
        }


def _lp(buf, off):
    """Read one uint32-length-prefixed item; return (item, next offset)."""
    n = struct.unpack_from('<I', buf, off)[0]
    return buf[off + 4:off + 4 + n], off + 4 + n


def _signing_block_cert(apk):
    """SHA-256 of the first signer's certificate in the APK Signature Scheme
    v3 or v2 block, or None. keytool only reads v1 (JAR) signatures, and
    release APKs here are signed with v2/v3 only."""
    data = open(apk, 'rb').read()
    eocd = data.rfind(b'PK\x05\x06')
    if eocd < 0:
        return None
    cd_offset = struct.unpack_from('<I', data, eocd + 16)[0]
    if data[cd_offset - 16:cd_offset] != b'APK Sig Block 42':
        return None
    size = struct.unpack_from('<Q', data, cd_offset - 24)[0]
    pairs_start = cd_offset - size - 8 + 8
    pairs_end = cd_offset - 24
    blocks = {}
    off = pairs_start
    while off < pairs_end:
        length = struct.unpack_from('<Q', data, off)[0]
        pid = struct.unpack_from('<I', data, off + 8)[0]
        blocks[pid] = data[off + 12:off + 8 + length]
        off += 8 + length
    for pid in (0xf05368c0, 0x7109871a):  # v3, then v2
        if pid not in blocks:
            continue
        signers, _ = _lp(blocks[pid], 0)
        signer, _ = _lp(signers, 0)
        signed_data, _ = _lp(signer, 0)
        _digests, o = _lp(signed_data, 0)
        certs, _ = _lp(signed_data, o)
        cert, _ = _lp(certs, 0)
        return hashlib.sha256(cert).hexdigest()
    return None


def cert_sha256(apk):
    found = _signing_block_cert(apk)
    if found:
        return found
    out = subprocess.run(['keytool', '-printcert', '-jarfile', apk],
                         capture_output=True, text=True).stdout
    m = re.search(r'SHA256:\s*([0-9A-F:]+)', out)
    return m.group(1).replace(':', '').lower() if m else None


def test_runs(commit):
    out = subprocess.run(
        ['gh', 'api', f'repos/{REPO}/actions/runs?head_sha={commit}&per_page=100',
         '--jq', '.workflow_runs[] | {name, conclusion, html_url, event}'],
        capture_output=True, text=True, check=True).stdout
    return [json.loads(line) for line in out.splitlines() if line.strip()]


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--ci-artifact', required=True)
    p.add_argument('--signed', required=True)
    p.add_argument('--tag', required=True)
    p.add_argument('--out', default='RELEASE-MANIFEST.json')
    a = p.parse_args()

    info = json.load(open(f'{a.ci_artifact}/BUILD-INFO.json'))
    ci_apk = f"{a.ci_artifact}/{info['artifact']}"
    problems = []

    if sha256(ci_apk) != info['artifact_sha256_before_signing']:
        problems.append('CI artifact does not match its BUILD-INFO.json hash')
    if unsigned_entries(ci_apk) != unsigned_entries(a.signed):
        problems.append('signed APK contents differ from the CI build beyond the signature')

    cert = cert_sha256(a.signed)
    if not cert or not cert.startswith(EXPECTED_CERT_PREFIX):
        problems.append(f'unexpected signing certificate: {cert}')

    runs = test_runs(info['commit'])
    tests = [r for r in runs if r['name'] == TEST_WORKFLOW]
    passed = [r for r in tests if r['conclusion'] == 'success']
    if not passed:
        problems.append(f'no successful "{TEST_WORKFLOW}" run for commit {info["commit"]} '
                        f'(found: {[r["conclusion"] for r in tests] or "none"})')

    manifest = {
        'tag': a.tag,
        'commit': info['commit'],
        'build_run': info['run'],
        'build_kind': info['kind'],
        'test_runs': [r['html_url'] for r in passed],
        'flutter': info.get('flutter'),
        'pubspec_lock_sha256': info['pubspec_lock_sha256'],
        'ci_artifact_sha256': info['artifact_sha256_before_signing'],
        'published_artifact': a.signed.split('/')[-1],
        'published_sha256': sha256(a.signed),
        'signing_certificate_sha256': cert,
        'resigned_outside_ci': True,
        'created_utc': datetime.now(timezone.utc).isoformat(timespec='seconds'),
        'problems': problems,
    }
    json.dump(manifest, open(a.out, 'w'), indent=2)
    print(json.dumps(manifest, indent=2))
    if problems:
        print('\nNOT READY TO PUBLISH:', *problems, sep='\n- ', file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
