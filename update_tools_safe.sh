#!/bin/bash

echo "Updating tools catalog from GitHub (preserving Go tools)..."

# First, backup any Go tools (tools with type: go in frontmatter)
mkdir -p content/tools/.backup
for file in content/tools/*.md; do
  if [ -f "$file" ] && grep -q "^type: *[\"']go[\"']" "$file"; then
    echo "Backing up Go tool: $(basename "$file")"
    cp "$file" content/tools/.backup/
  fi
done

# Get repos from GitHub
repos=$(gh repo list --limit 100 --json name,description,primaryLanguage,url | \
  jq -r '.[] | 
    select(
      (.primaryLanguage.name == "Shell") or 
      (.description != null and (.description | ascii_downcase | contains("basher")))
    ) | 
    @json')

# Remove all markdown files except backups
rm -f content/tools/*.md

# Recreate Basher tools
while IFS= read -r repo; do
  name=$(echo "$repo" | jq -r '.name')
  desc=$(echo "$repo" | jq -r '.description // "No description"')
  url=$(echo "$repo" | jq -r '.url')
  
  # Skip non-tool repos
  if [[ "$name" == "gnomegl.github.io" ]] || [[ "$name" == ".github" ]]; then
    continue
  fi
  
  cat > "content/tools/${name}.md" << EOF
---
title: "${name}"
description: "${desc}"
github: "${url}"
install: "basher install gnomegl/${name}"
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

done <<< "$repos"

# Restore Go tools from backup
if [ -d "content/tools/.backup" ]; then
  for file in content/tools/.backup/*.md; do
    if [ -f "$file" ]; then
      echo "Restoring Go tool: $(basename "$file")"
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
    echo "Sidebar updated with new tools and search/filter functionality."
    echo "Use '/' to focus search box, type to filter tools in real-time."
else
    echo "Hugo not found. Please install Hugo to rebuild the site."
    echo "Tools updated but sidebar won't reflect changes until site is rebuilt."
fi