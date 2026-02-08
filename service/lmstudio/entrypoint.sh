#!/bin/sh
set -e

LMS_DIR="/root/.lmstudio"
LMS_BIN="$LMS_DIR/bin/lms"

if [ ! -x "$LMS_BIN" ]; then
    echo "[llmster] LM Studio not found, installing..."

    mkdir -p "$LMS_DIR"

    if ! curl -fsSL https://lmstudio.ai/install.sh | bash; then
        echo "[llmster] LM Studio install failed"
        exit 1
    fi

    if [ ! -x "$LMS_BIN" ]; then
        echo "[llmster] install script finished but lms not found"
        exit 1
    fi
else
    echo "[llmster] LM Studio already installed"
fi

exec "$@"

