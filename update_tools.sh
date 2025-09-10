#!/bin/bash

echo "Updating tools catalog from GitHub..."

# Backup non-basher tools
mkdir -p content/tools/.backup
for file in content/tools/*.md; do
  if [ -f "$file" ]; then
    # Check if it's NOT a basher tool (has type field that's not basher)
    if grep -q "^type:" "$file" && ! grep -q "^type: *[\"']basher[\"']" "$file"; then
      echo "Backing up non-basher tool: $(basename "$file")"
      cp "$file" content/tools/.backup/
    fi
  fi
done

# Get all repos from GitHub  
repos=$(gh repo list gnomegl --limit 100 --json name,description,url,repositoryTopics)

# Remove all markdown files
rm -f content/tools/*.md

# Process each repo
echo "$repos" | jq -c '.[]' | while IFS= read -r repo; do
  name=$(echo "$repo" | jq -r '.name')
  desc=$(echo "$repo" | jq -r '.description // "No description"')
  url=$(echo "$repo" | jq -r '.url')
  topics=$(echo "$repo" | jq -r '.repositoryTopics[].name' 2>/dev/null)
  
  # Skip non-tool repos
  if [[ "$name" == "gnomegl.github.io" ]] || [[ "$name" == ".github" ]]; then
    continue
  fi
  
  # Check if it has basher topic
  if echo "$topics" | grep -q "basher"; then
    echo "Adding basher tool: ${name}"
    cat > "content/tools/${name}.md" << EOF
---
title: "${name}"
description: "${desc}"
github: "${url}"
install: "basher install gnomegl/${name}"
type: "basher"
category: "osint"
date: $(date -Iseconds)
---

## Installation

\`\`\`bash
basher install gnomegl/${name}
\`\`\`

## Description

${desc}

## Usage

\`\`\`bash
${name} --help
\`\`\`

## Source

View the source code on [GitHub](${url})
EOF
  fi
done

# Restore non-basher tools from backup
if [ -d "content/tools/.backup" ]; then
  for file in content/tools/.backup/*.md; do
    if [ -f "$file" ]; then
      echo "Restoring non-basher tool: $(basename "$file")"
      cp "$file" content/tools/
    fi
  done
  rm -rf content/tools/.backup
fi

echo "Tools catalog updated!"

echo "Rebuilding Hugo site..."
if command -v hugo &> /dev/null; then
    hugo --minify
    echo "Site rebuilt successfully!"
else
    echo "Hugo not found. Please install Hugo to rebuild the site."
fi