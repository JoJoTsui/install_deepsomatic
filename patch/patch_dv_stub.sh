#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# patched binary dir
BIN_DIR="${BIN_DIR:-/t9k/mnt/hdd/work/Vax/deepvariant/patched_dv_1.9}"
# patched python3 path
PYTHON="${PYTHON:-/t9k/mnt/joey/micromamba/envs/tf/bin/python3}"


# find every zipped binary in the BIN_DIR and patch
find "${BIN_DIR}" -type f -name '*.zip' -print0 |
while IFS= read -r -d '' zip; do
  python3 "${SCRIPT_DIR}/patch_dv_stub.py" --zip "$zip" --python "${PYTHON}"
done

# rsync to /opt/deepvariant/bin
sudo rsync -avP "${BIN_DIR}"/ /opt/deepvariant/bin/
