#!/usr/bin/env bash

# This script creates shell wrappers for Python zip archives, making them executable directly from the command line.

set -euo pipefail

# Define constants
BASH_HEADER='#!/usr/bin/env bash'
DEEPVARIANT_BIN="/opt/deepvariant/bin"
PYTHON="${PYTHON:-micromamba run -n tf python3}"  # Override with env var to use a different Python interpreter

# Array of wrapper configurations: "script_name|python_command"
WRAPPERS=(
  "make_examples_somatic|${PYTHON} -u ${DEEPVARIANT_BIN}/make_examples_somatic.zip"
  "call_variants|${PYTHON} ${DEEPVARIANT_BIN}/call_variants.zip"
  "postprocess_variants|${PYTHON} ${DEEPVARIANT_BIN}/postprocess_variants.zip"
  "vcf_stats_report|${PYTHON} ${DEEPVARIANT_BIN}/vcf_stats_report.zip"
  "show_examples|${PYTHON} ${DEEPVARIANT_BIN}/show_examples.zip"
  "runtime_by_region_vis|${PYTHON} ${DEEPVARIANT_BIN}/runtime_by_region_vis.zip"
)

# Array to store created files for chmod
CREATED_FILES=()

# --- Create Wrapper Scripts ---

# Create wrappers for zip archives
for wrapper in "${WRAPPERS[@]}"; do
  IFS='|' read -r script_name python_cmd <<< "$wrapper"
  output_path="${DEEPVARIANT_BIN}/${script_name}"
  
  printf '%s\n%s "$@"\n' "${BASH_HEADER}" "${python_cmd}" > "${output_path}"
  CREATED_FILES+=("${output_path}")
  echo "Created wrapper: ${script_name}"
done

# Create wrapper for the deepsomatic runner
DEEPSOMATIC_WRAPPER="${DEEPVARIANT_BIN}/deepsomatic/run_deepsomatic"
printf '%s\n%s -u %s/deepsomatic/run_deepsomatic.py "$@"\n' \
  "${BASH_HEADER}" \
  "${PYTHON}" \
  "${DEEPVARIANT_BIN}" > "${DEEPSOMATIC_WRAPPER}"
CREATED_FILES+=("${DEEPSOMATIC_WRAPPER}")
echo "Created wrapper: deepsomatic/run_deepsomatic"

# --- Make all wrapper scripts executable ---

chmod +x "${CREATED_FILES[@]}"

echo "All wrapper scripts created and made executable successfully."
