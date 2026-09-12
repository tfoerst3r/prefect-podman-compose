#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Thomas Foerster <noreply@tfoerster.de>
#
# SPDX-License-Identifier: MIT

set -e

echo "source /init_prefect.sh" >> /root/.bashrc

INITFOLDER="init_scripts"
TARGET_DIR="/$INITFOLDER"

# Enable nullglob so the loop is skipped if no .sh files match
shopt -s nullglob

if [ -d "$TARGET_DIR" ]; then
    for f in "$TARGET_DIR"/*.sh; do
        if [ -r "$f" ]; then
            echo "Sourcing $f..."
            source "$f"
        fi
    done
fi

# Revert nullglob back to default behavior (good practice)
shopt -u nullglob

