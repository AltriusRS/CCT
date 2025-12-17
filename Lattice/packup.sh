#!/usr/bin/env bash
set -euo pipefail

PKG_DIR="pkg"
OUT_FILE="$PKG_DIR/index.toml"

echo "Generating package index at $OUT_FILE"

# Write header
cat > "$OUT_FILE" <<EOF
[repository]
name = "Lattice Official"
description = "Official Lattice package repository"

EOF

# DO NOT use GROUPS (it's a bash builtin)
declare -A PACKAGE_GROUPS=(
    ["kernel"]="packages.kernel"
    ["boot"]="packages.boot"
    ["shared"]="packages.shared"
    ["drivers/core"]="packages.drivers_core"
    ["drivers/mekanism"]="packages.drivers_mekanism"
)

for dir in "${!PACKAGE_GROUPS[@]}"; do
    group="${PACKAGE_GROUPS[$dir]}"
    full_path="$PKG_DIR/$dir"

    [[ -d "$full_path" ]] || continue

    echo "[$group]" >> "$OUT_FILE"

    find "$full_path" -type f -name "*.lua" | sort | while read -r file; do
        rel_path="${file#$PKG_DIR/}"
        name="$(basename "$file" .lua)"
        hash="$(sha256sum "$file" | awk '{print $1}')"

        cat >> "$OUT_FILE" <<EOF
$name = { path = "$rel_path", sha256 = "$hash" }
EOF
    done

    echo >> "$OUT_FILE"
done

echo "Done."
