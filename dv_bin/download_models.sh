#!/usr/bin/env bash



# deepvariant models
DEST="./models/deepvariant/1.9.0/"
mkdir -p "${DEST}"

gsutil -m rsync -r \
  "gs://deepvariant/models/DeepVariant/1.9.0/" \
  "${DEST}"

# deepsomatic models
DEST="./models/deepsomatic/1.9.0/"
mkdir -p "${DEST}"

gsutil -m rsync -r \
  "gs://deepvariant/models/DeepSomatic/1.9.0/" \
  "${DEST}"
