#!/bin/bash

# Script to add a Go tool to the catalog
# Usage: ./add_go_tool.sh <name> <description> <github_url> <go_install_path>

if [ $# -lt 4 ]; then
    echo "Usage: $0 <name> <description> <github_url> <go_install_path>"
    echo "Example: $0 nuclei 'Fast vulnerability scanner' 'https://github.com/projectdiscovery/nuclei' 'github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest'"
    exit 1
fi

NAME="$1"
DESC="$2"
GITHUB_URL="$3"
GO_INSTALL="$4"

cat > "content/tools/${NAME}.md" << EOF
---
title: "${NAME}"
description: "${DESC}"
github: "${GITHUB_URL}"
install: "go install ${GO_INSTALL}"
type: "go"
category: "osint"
date: $(date -Iseconds)
---

## Installation

\`\`\`bash
go install ${GO_INSTALL}
\`\`\`

## Description

${DESC}

## Usage

\`\`\`bash
${NAME} --help
\`\`\`

## Source

View the source code on [GitHub](${GITHUB_URL})
EOF

echo "Added Go tool: ${NAME}"
echo "File created: content/tools/${NAME}.md"