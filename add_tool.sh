#!/bin/bash

# Usage: ./add_tool.sh <name> <type> [install_path]
# Types: basher, go, npm, pip, etc.

if [ $# -lt 2 ]; then
    echo "Usage: $0 <name> <type> [install_path]"
    echo "Examples:"
    echo "  $0 gitslurp go github.com/gnomegl/gitslurp@latest"
    echo "  $0 tdla basher"
    exit 1
fi

NAME="$1"
TYPE="$2"
INSTALL_PATH="$3"

echo "Fetching repository info for gnomegl/${NAME}..."
REPO_INFO=$(gh repo view "gnomegl/${NAME}" --json description,url,repositoryTopics 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "Error: Could not fetch repository gnomegl/${NAME}"
    exit 1
fi

DESC=$(echo "$REPO_INFO" | jq -r '.description // "No description"')
GITHUB_URL=$(echo "$REPO_INFO" | jq -r '.url')
TOPICS=$(echo "$REPO_INFO" | jq -r '.repositoryTopics[].name' 2>/dev/null)
TOPICS_ARRAY=$(echo "$REPO_INFO" | jq -c '.repositoryTopics[].name' 2>/dev/null | jq -s '.' 2>/dev/null || echo '[]')

HAS_BASHER=$(echo "$TOPICS" | grep -q "basher" && echo "true" || echo "false")

case "$TYPE" in
    go)
        if [ -z "$INSTALL_PATH" ]; then
            INSTALL_PATH="github.com/gnomegl/${NAME}@latest"
        fi
        INSTALL_CMD="go install ${INSTALL_PATH}"
        ;;
    basher)
        INSTALL_CMD="basher install gnomegl/${NAME}"
        ;;
    npm)
        INSTALL_CMD="npm install -g ${NAME}"
        ;;
    pip)
        INSTALL_CMD="pip install ${NAME}"
        ;;
    *)
        INSTALL_CMD="# Manual installation required"
        ;;
esac

cat > "content/tools/${NAME}.md" << EOF
---
title: "${NAME}"
description: "${DESC}"
github: "${GITHUB_URL}"
install: "${INSTALL_CMD}"
type: "${TYPE}"
topics: ${TOPICS_ARRAY}
date: $(date -Iseconds)
---

## Installation

EOF

cat >> "content/tools/${NAME}.md" << EOF
\`\`\`bash
${INSTALL_CMD}
\`\`\`

EOF

if [ "$HAS_BASHER" == "true" ] && [ "$TYPE" != "basher" ]; then
    cat >> "content/tools/${NAME}.md" << EOF
### Alternative Installation (Basher)

\`\`\`bash
basher install gnomegl/${NAME}
\`\`\`

EOF
fi

cat >> "content/tools/${NAME}.md" << EOF
## Description

${DESC}

## Usage

\`\`\`bash
${NAME} --help
\`\`\`

## Source

View the source code on [GitHub](${GITHUB_URL})
EOF

echo "Added ${TYPE} tool: ${NAME}"
echo "Description: ${DESC}"
echo "File created: content/tools/${NAME}.md"