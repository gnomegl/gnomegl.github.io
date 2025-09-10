---
title: "gitslurp"
description: "Analyze GitHub user's commit history across repositories"
github: "https://github.com/gnomegl/gitslurp"
install: "go install github.com/gnomegl/gitslurp@latest"
type: "go"
---

OSINT tool to analyze GitHub user activity and highlights their contributions across repositories.

## Features

- User-centric analysis via GitHub username, email or organization
- Comprehensive commit history across public repositories  
- Visual highlighting with color-coding
- Multiple identity support for different emails/names
- Advanced secret detection powered by TruffleHog patterns
- Interesting pattern detection (URLs, UUIDs, IPs)
- Repository context showing own repos vs forks
- Organization scanning capabilities


## Usage

```bash
# Analyze user by username
gitslurp soxoj

# Search by email
gitslurp user@example.com

# Scan organization
gitslurp -o myorganization
```

## Requirements

- Go 1.19+
- GitHub API access (unauthenticated or with token)