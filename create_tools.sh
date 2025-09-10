#!/bin/bash

# Create tool pages from GitHub repos
tools=(
"wayslurp:wayback machine bulk downloader"
"twoe:twitter osint tool"
"twhist:twitter history analyzer"
"toto:osint automation tool"
"sx:search tool"
"rcrd:screen recording tool with audio"
"pubacc:public account checker"
"odcrawl:open directory crawler"
"linkedin:linkedin api client"
"intls:intel lookup service"
"facecheck:facial recognition search tool"
"bvip:bulk ip lookup tool"
"nosint:osint tool using nosint.org api"
"whoxy:whoxy api client for domain intelligence"
"tdla:telegram download assistant - tdl wrapper"
"fdt:discord token validator and extractor"
"monerosms:monerosms.com cli for sms verification"
"gofile-get:download files from gofile.io links"
"cdx:internet archive cdx api search for historical web data"
"merklemap:certificate transparency search for domains and subdomains"
"dehashed:search leaked credentials and breach data"
"shrt:gray hat warfare api client for exposed file search"
"igslurp:instagram data collection tool"
"hunter:hunter.io api client for email intelligence"
"gh-search:github repository search with contributor enumeration"
)

for tool in "${tools[@]}"; do
    name="${tool%%:*}"
    desc="${tool#*:}"
    
    cat > "content/tools/${name}.md" << EOT
---
title: "${name}"
description: "${desc}"
github: "https://github.com/gnomegl/${name}"
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

View the source code on [GitHub](https://github.com/gnomegl/${name})
EOT
done

chmod +x /home/gnome/projects/gnomegl.github.io/create_tools.sh
