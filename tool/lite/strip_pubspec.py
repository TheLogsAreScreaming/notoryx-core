"""Removes packages from pubspec.yaml for the lite build.

Usage: python3 tool/lite/strip_pubspec.py pubspec.yaml PACKAGE...

Drops each package's line under `dependencies:` and its block under
`hooks: user_defines:` (llamadart has one). Fails if a package isn't found,
so a renamed dependency can't slip into the lite build unnoticed.
"""
import re
import sys

path, packages = sys.argv[1], sys.argv[2:]
lines = open(path, encoding="utf-8").read().split("\n")
out, skip_indent, found = [], None, set()
for line in lines:
    indent = len(line) - len(line.lstrip())
    if skip_indent is not None:
        if line.strip() == "" or indent > skip_indent:
            continue
        skip_indent = None
    m = re.match(r"^(\s*)([A-Za-z0-9_]+):", line)
    if m and m.group(2) in packages:
        found.add(m.group(2))
        # A dependency line may hold a version, or a block (path/git/defines).
        skip_indent = len(m.group(1))
        continue
    out.append(line)
missing = set(packages) - found
if missing:
    sys.exit(f"strip_pubspec: not in {path}: {', '.join(sorted(missing))}")
# Drop parent keys the removal emptied (`user_defines:`, then `hooks:`).
changed = True
while changed:
    changed = False
    for i, line in enumerate(out):
        m = re.match(r"^(\s*)(hooks|user_defines):\s*$", line)
        if not m:
            continue
        rest = [l for l in out[i + 1 :] if l.strip()]
        nxt = rest[0] if rest else ""
        if len(nxt) - len(nxt.lstrip()) <= len(m.group(1)):
            del out[i]
            changed = True
            break
open(path, "w", encoding="utf-8").write("\n".join(out))
print("removed:", ", ".join(packages))
