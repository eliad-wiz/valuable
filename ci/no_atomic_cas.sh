#!/bin/bash

# Update the list of targets that do not support atomic CAS operations.
#
# Usage:
#    ./ci/no_atomic_cas.sh

set -euo pipefail
IFS=$'\n\t'

cd "$(cd "$(dirname "$0")" && pwd)"/..

file="valuable/no_atomic_cas.rs"

{
    echo "// This file is @generated by $(basename "$0")."
    echo "// It is not intended for manual editing."
    echo ""
    echo "const NO_ATOMIC_CAS_TARGETS: &[&str] = &["
} >"$file"

for target in $(rustc --print target-list); do
    res=$(rustc --print target-spec-json -Z unstable-options --target "$target" \
        | jq -r "select(.\"atomic-cas\" == false)")
    [[ -z "$res" ]] || echo "    \"$target\"," >>"$file"
done

echo "];" >>"$file"
