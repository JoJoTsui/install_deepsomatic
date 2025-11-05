#!/usr/bin/env bash


find /opt/deepvariant/bin -type f -name '*.zip' -print0 |
while IFS= read -r -d '' zip; do
  python3 patch_dv_stub.py --zip "$zip" --python /usr/bin/python3
done
