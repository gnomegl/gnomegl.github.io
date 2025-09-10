---
title: "twoe"
description: "Twitter/X tweet fetcher using public oEmbed API"
github: "https://github.com/gnomegl/twoe"
install: "go install github.com/gnomegl/twoe@latest"
type: "go"
category: "osint"
date: 2025-09-09T23:27:23-04:00
---

Command-line tool to fetch tweets using Twitter's public oEmbed API. Minimal, efficient, and easy to use.

## Features

- Parallel fetching using multiple goroutines
- Read tweet IDs from file
- Incremental CSV output
- Error handling with retries
- Optional progress bar

## Installation

```bash
go install github.com/gnomegl/twoe@latest
```

## Usage

```bash
# Fetch tweets from ID file
twoe tweet_ids.txt

# With custom output file
twoe -o results.csv tweet_ids.txt

# With progress bar
twoe -p tweet_ids.txt

# Adjust worker count
twoe -w 20 tweet_ids.txt
```

## Requirements

- Go 1.24.4+
- No API keys required (uses public oEmbed API)
