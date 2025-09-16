#!/bin/bash

echo "Updating tools catalog from GitHub..."

# Get current repositories from GitHub
repos=$(gh repo list gnomegl --limit 100 --json name,description,url,repositoryTopics,primaryLanguage,isFork,isPrivate)

# Create lists to track tools
declare -A current_tools
declare -A github_tools
declare -A manual_tools

# Scan existing tool files
for file in content/tools/*.md; do
  if [ -f "$file" ]; then
    tool_name=$(basename "$file" .md)
    current_tools["$tool_name"]=1

    # Check if it's a manually created tool (not basher or go type)
    if grep -q "^type:" "$file" && ! grep -q "^type: *[\"']\(basher\|go\)[\"']" "$file"; then
      manual_tools["$tool_name"]=1
      echo "Found manually created tool: $tool_name"
    fi
  fi
done

# Function to create/update tool file
create_tool_file() {
  local name="$1"
  local desc="$2"
  local url="$3"
  local topics_line="$4"
  local tool_type="$5"
  local install_cmd="$6"
  local action="$7"

  local file_path="content/tools/${name}.md"
  local existing_date=""
  local current_date=$(date -Iseconds)

  # If file exists, extract the existing date
  if [[ -f "$file_path" ]]; then
    existing_date=$(grep "^date:" "$file_path" | cut -d' ' -f2- | tr -d '"')
  fi

  # Generate new content without date for comparison
  local new_content_no_date=$(cat <<EOF
---
title: "${name}"
description: "${desc}"
github: "${url}"
install: "${install_cmd}"
type: "${tool_type}"
category: "osint"
${topics_line}
---

## Installation

\`\`\`bash
${install_cmd}
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
)

  # If file exists, compare content (excluding date line)
  local content_changed=true
  if [[ -f "$file_path" && -n "$existing_date" ]]; then
    local existing_content_no_date=$(grep -v "^date:" "$file_path")
    local new_content_no_date_clean=$(echo "$new_content_no_date" | grep -v "^date:")

    if [[ "$existing_content_no_date" == "$new_content_no_date_clean" ]]; then
      content_changed=false
    fi
  fi

  # Use existing date if content hasn't changed, otherwise use current date
  local final_date="$current_date"
  if [[ "$content_changed" == false && -n "$existing_date" ]]; then
    final_date="$existing_date"
    echo "No changes detected for tool: ${name} (preserving date)"
  else
    echo "$action tool: ${name}"
  fi

  # Write the final content with appropriate date
  cat >"$file_path" <<EOF
---
title: "${name}"
description: "${desc}"
github: "${url}"
install: "${install_cmd}"
type: "${tool_type}"
category: "osint"
${topics_line}
date: ${final_date}
---

## Installation

\`\`\`bash
${install_cmd}
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
}

# Process GitHub repositories
while IFS= read -r repo; do
  name=$(echo "$repo" | jq -r '.name')
  desc=$(echo "$repo" | jq -r '.description // "No description"')
  url=$(echo "$repo" | jq -r '.url')
  topics=$(echo "$repo" | jq -r '.repositoryTopics[].name' 2>/dev/null)
  isFork=$(echo "$repo" | jq -r '.isFork')
  isPrivate=$(echo "$repo" | jq -r '.isPrivate')

  # Skip unwanted repositories
  if [[ "$name" == "gnomegl.github.io" ]] || [[ "$name" == ".github" ]] || [[ "$isFork" == "true" ]] || [[ "$isPrivate" == "true" ]]; then
    if [[ "$isFork" == "true" ]]; then
      echo "Skipping fork: ${name}"
    elif [[ "$isPrivate" == "true" ]]; then
      echo "Skipping private repo: ${name}"
    fi
    continue
  fi

  lang=$(echo "$repo" | jq -r '.primaryLanguage.name // ""')

  # Format topics for YAML
  if [ -n "$topics" ]; then
    topics_yaml=$(echo "$topics" | awk '{printf "\"%s\", ", $0}' | sed 's/, $//')
    topics_line="topics: [${topics_yaml}]"
  else
    topics_line="topics: []"
  fi

  # Mark this tool as found in GitHub
  github_tools["$name"]=1

  # Determine tool type and installation method
  if echo "$topics" | grep -q "basher"; then
    tool_type="basher"
    install_cmd="basher install gnomegl/${name}"
  elif [[ "$lang" == "Go" ]]; then
    tool_type="go"
    install_cmd="go install github.com/gnomegl/${name}@latest"
  else
    # Skip repositories that don't match our tool criteria
    continue
  fi

  # Check if tool already exists
  if [[ -f "content/tools/${name}.md" ]]; then
    # Check if it's a manually created tool
    if [[ "${manual_tools[$name]}" == "1" ]]; then
      echo "Skipping manually created tool: ${name}"
      continue
    fi

    # Update existing tool
    create_tool_file "$name" "$desc" "$url" "$topics_line" "$tool_type" "$install_cmd" "Updating"
  else
    # Add new tool
    create_tool_file "$name" "$desc" "$url" "$topics_line" "$tool_type" "$install_cmd" "Adding"
  fi
done < <(echo "$repos" | jq -c '.[]')

# Remove obsolete tools (those that exist locally but not in GitHub or are now private/forks)
for tool_name in "${!current_tools[@]}"; do
  # Skip manually created tools
  if [[ "${manual_tools[$tool_name]}" == "1" ]]; then
    continue
  fi

  # If tool doesn't exist in GitHub anymore, remove it
  if [[ "${github_tools[$tool_name]}" != "1" ]]; then
    echo "Removing obsolete tool: ${tool_name}"
    rm -f "content/tools/${tool_name}.md"
  fi
done

echo "Tools catalog updated!"

echo "Rebuilding Hugo site..."
if command -v hugo &>/dev/null; then
  hugo --minify
  echo "Site rebuilt successfully!"
else
  echo "Hugo not found. Please install Hugo to rebuild the site."
fi
