#!/bin/bash

echo "Updating tools catalog from GitHub..."

# Preserve manually created tools
mkdir -p content/tools/.backup
for file in content/tools/*.md; do
  if [ -f "$file" ]; then
    # Keep tools with type field that's not basher or go
    if grep -q "^type:" "$file" && ! grep -q "^type: *[\"']\(basher\|go\)[\"']" "$file"; then
      echo "Backing up manually created tool: $(basename "$file")"
      cp "$file" content/tools/.backup/
    fi
  fi
done

repos=$(gh repo list gnomegl --limit 100 --json name,description,url,repositoryTopics,primaryLanguage,isFork,isPrivate)

rm -f content/tools/*.md

echo "$repos" | jq -c '.[]' | while IFS= read -r repo; do
  name=$(echo "$repo" | jq -r '.name')
  desc=$(echo "$repo" | jq -r '.description // "No description"')
  url=$(echo "$repo" | jq -r '.url')
  topics=$(echo "$repo" | jq -r '.repositoryTopics[].name' 2>/dev/null)
  isFork=$(echo "$repo" | jq -r '.isFork')
  isPrivate=$(echo "$repo" | jq -r '.isPrivate')

  if [[ "$name" == "gnomegl.github.io" ]] || [[ "$name" == ".github" ]] || [[ "$isFork" == "true" ]] || [[ "$isPrivate" == "true" ]]; then
    if [[ "$isFork" == "true" ]]; then
      echo "Skipping fork: ${name}"
    elif [[ "$isPrivate" == "true" ]]; then
      echo "Skipping private repo: ${name}"
    fi
    continue
  fi

  lang=$(echo "$repo" | jq -r '.primaryLanguage.name // ""')

  if [ -n "$topics" ]; then
    # Convert newline-separated topics to comma-separated quoted strings
    topics_yaml=$(echo "$topics" | awk '{printf "\"%s\", ", $0}' | sed 's/, $//')
    topics_line="topics: [${topics_yaml}]"
  else
    topics_line="topics: []"
  fi

  if echo "$topics" | grep -q "basher"; then
    echo "Adding basher tool: ${name}"
    cat >"content/tools/${name}.md" <<EOF
---
title: "${name}"
description: "${desc}"
github: "${url}"
install: "basher install gnomegl/${name}"
type: "basher"
category: "osint"
${topics_line}
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
  elif [[ "$lang" == "Go" ]]; then
    echo "Adding Go tool: ${name}"
    cat >"content/tools/${name}.md" <<EOF
---
title: "${name}"
description: "${desc}"
github: "${url}"
install: "go install github.com/gnomegl/${name}@latest"
type: "go"
category: "osint"
${topics_line}
date: $(date -Iseconds)
---

## Installation

\`\`\`bash
go install github.com/gnomegl/${name}@latest
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

if [ -d "content/tools/.backup" ]; then
  for file in content/tools/.backup/*.md; do
    if [ -f "$file" ]; then
      echo "Restoring manually created tool: $(basename "$file")"
      cp "$file" content/tools/
    fi
  done
  rm -rf content/tools/.backup
fi

echo "Tools catalog updated!"

echo "Rebuilding Hugo site..."
if command -v hugo &>/dev/null; then
  hugo --minify
  echo "Site rebuilt successfully!"
else
  echo "Hugo not found. Please install Hugo to rebuild the site."
fi
