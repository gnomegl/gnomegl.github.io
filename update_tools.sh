#!/bin/bash

echo "Updating tools catalog from GitHub..."

repos=$(gh repo list --limit 100 --json name,description,primaryLanguage,url | \
  jq -r '.[] | 
    select(
      (.primaryLanguage.name == "Shell") or 
      (.description != null and (.description | ascii_downcase | contains("basher")))
    ) | 
    @json')

rm -f content/tools/*.md

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