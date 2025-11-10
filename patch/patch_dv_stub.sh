#!/usr/bin/env bash

# patched binary dir
BIN_DIR="/t9k/mnt/hdd/work/Vax/deepvariant/patched_dv_1.9"
# patched python3 path
PYTHON="/t9k/mnt/joey/micromamba/envs/tf/bin/python3"


# find every zipped binary in the BIN_DIR and patch
find "${BIN_DIR}" -type f -name '*.zip' -print0 |
while IFS= read -r -d '' zip; do
  python3 patch_dv_stub.py --zip "$zip" --python "${PYTHON}"
done

# rsync to /opt/deepvariant/bin
sudo rsync -avP "${BIN_DIR}"/ /opt/deepvariant/bin/
