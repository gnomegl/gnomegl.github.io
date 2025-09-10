#!/bin/bash

# Auto-update tools catalog from GitHub repos
echo "Updating tools catalog from GitHub..."

# Get all repos with Shell as primary language or basher in description
repos=$(gh repo list --limit 100 --json name,description,primaryLanguage,url | \
  jq -r '.[] | 
    select(
      (.primaryLanguage.name == "Shell") or 
      (.description != null and (.description | ascii_downcase | contains("basher")))
    ) | 
    @json')

# Clear existing tools
rm -f content/tools/*.md

# Create tool pages
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