#!/usr/bin/env bash
# Turns this checkout into the NOTORYX Core lite build, in place.
# Run it on a throwaway checkout (CI does); it rewrites and deletes files.
# See tool/lite/README.md.
set -euo pipefail
cd "$(dirname "$0")/../.."

# 1. Swap in the lite copies (tool/lite/overrides/<path>.dart.lite -> <path>.dart).
while IFS= read -r f; do
  cp "tool/lite/overrides/$f" "${f%.lite}"
  echo "lite: replaced ${f%.lite}"
done < <(cd tool/lite/overrides && find . -name '*.dart.lite' | sed 's#^\./##' | sort)

# 2. Native-only files that import the removed packages and are no longer used.
rm -f lib/services/image_codec_session_io.dart
echo "lite: removed lib/services/image_codec_session_io.dart"

# 3. The packages themselves.
python3 tool/lite/strip_pubspec.py pubspec.yaml llamadart flutter_onnxruntime mobile_scanner

# 4. Nothing left may import them.
if grep -rnE "package:(llamadart|flutter_onnxruntime|mobile_scanner)/" lib; then
  echo "::error::lib still imports a package the lite build removes" >&2
  exit 1
fi

# 5. The tests exercise the full build; the lite job only analyzes lib and builds.
rm -rf test integration_test
echo "lite: ready"
