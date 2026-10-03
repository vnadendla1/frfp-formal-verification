"""Verify every preserved core source against its recorded SHA-256."""
from pathlib import Path
import hashlib
import json

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / "SOURCE_MANIFEST.json").read_text())
for relative, expected in manifest["files"].items():
    actual = hashlib.sha256((root / relative).read_bytes()).hexdigest()
    if actual != expected:
        raise SystemExit(f"Source hash mismatch: {relative}")
print(f"PASS: {len(manifest['files'])} preserved core files; source {manifest['source_id']}")
