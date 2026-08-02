#!/bin/bash
set -euo pipefail

# Build first; a failed build must never reach the upload step.
make dist

PLUGIN_ID=$(jq -r .id plugin.json)
BUNDLE=$(ls dist/*.tar.gz)
KEY="s3://n2g-mattermost/plugins/${PLUGIN_ID}.tar.gz"

# Explicitly clear whatever's currently published before uploading the new
# build, rather than relying on `cp`'s implicit overwrite — matters once S3
# versioning is on, and makes "replace, don't accumulate" an intentional step
# instead of a side effect.
aws s3 rm "${KEY}" || true
aws s3 cp "${BUNDLE}" "${KEY}"
