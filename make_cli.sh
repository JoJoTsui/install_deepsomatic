#!/usr/bin/env bash

# This script creates shell wrappers for Python zip archives, making them executable directly from the command line.

# Define the bash header for the scripts
BASH_HEADER='#!/usr/bin/env bash'

# --- Create Wrapper Scripts ---

# Create a wrapper for make_examples_somatic
printf "%s\n%s\n" \
  "${BASH_HEADER}" \
  'python3 -u /opt/deepvariant/bin/make_examples_somatic.zip "$@"' > \
  /opt/deepvariant/bin/make_examples_somatic

# Create a wrapper for call_variants
printf "%s\n%s\n" \
  "${BASH_HEADER}" \
  'python3 /opt/deepvariant/bin/call_variants.zip "$@"' > \
  /opt/deepvariant/bin/call_variants

# Create a wrapper for postprocess_variants
printf "%s\n%s\n" \
  "${BASH_HEADER}" \
  'python3 /opt/deepvariant/bin/postprocess_variants.zip "$@"' > \
  /opt/deepvariant/bin/postprocess_variants

# Create a wrapper for vcf_stats_report
printf "%s\n%s\n" \
  "${BASH_HEADER}" \
  'python3 /opt/deepvariant/bin/vcf_stats_report.zip "$@"' > \
  /opt/deepvariant/bin/vcf_stats_report

# Create a wrapper for show_examples
printf "%s\n%s\n" \
  "${BASH_HEADER}" \
  'python3 /opt/deepvariant/bin/show_examples.zip "$@"' > \
  /opt/deepvariant/bin/show_examples

# Create a wrapper for runtime_by_region_vis
printf "%s\n%s\n" \
  "${BASH_HEADER}" \
  'python3 /opt/deepvariant/bin/runtime_by_region_vis.zip "$@"' > \
  /opt/deepvariant/bin/runtime_by_region_vis

# Create a wrapper for the deepsomatic runner
printf "%s\n%s\n" \
  "${BASH_HEADER}" \
  'python3 -u /opt/deepvariant/bin/deepsomatic/run_deepsomatic.py "$@"' > \
  /opt/deepvariant/bin/deepsomatic/run_deepsomatic

# --- Make all wrapper scripts executable ---

chmod +x \
  /opt/deepvariant/bin/make_examples_somatic \
  /opt/deepvariant/bin/call_variants \
  /opt/deepvariant/bin/postprocess_variants \
  /opt/deepvariant/bin/vcf_stats_report \
  /opt/deepvariant/bin/show_examples \
  /opt/deepvariant/bin/runtime_by_region_vis \
  /opt/deepvariant/bin/deepsomatic/run_deepsomatic

echo "Wrapper scripts created and made executable."


