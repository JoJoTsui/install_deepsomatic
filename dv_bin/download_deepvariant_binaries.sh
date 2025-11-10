#/usr/bin/env bash

# download deepvariant 1.9
micromamba run -n deepvariant gsutil -m cp -r "gs://deepvariant/binaries/DeepVariant/1.9.0/DeepVariant-1.9.0" .
