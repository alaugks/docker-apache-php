#!/usr/bin/env bash
# Writes all tags of the Docker Hub repository to VERSIONS.md
set -euo pipefail

repo="alaugks/apache-php"
out="$(dirname "$0")/../VERSIONS.md"
url="https://hub.docker.com/v2/repositories/${repo}/tags?page_size=100&ordering=name"

{
  echo "# Versions"
  echo
  echo "Tags of [${repo}](https://hub.docker.com/r/${repo}/tags) on Docker Hub."
  echo
  echo "| Tag | Digest | Last updated | Size (MB) | Architectures |"
  echo "|-----|--------|--------------|-----------|---------------|"
  while [ -n "$url" ] && [ "$url" != "null" ]; do
    page=$(curl -fsS "$url")
    jq -r --arg repo "$repo" '.results[] | "| [`\(.name)`](https://hub.docker.com/layers/\($repo)/\(.name)/images/\(([.images[] | select(.architecture == "amd64") | .digest][0] // .images[0].digest) | gsub(":"; "-"))) | `\(.digest[7:19])` | \(.last_updated[:10]) | \(.full_size / 1048576 | floor) | \([.images[].architecture] | map(select(. != "unknown")) | unique | join(", ")) |"' <<<"$page"
    url=$(jq -r '.next' <<<"$page")
  done
} > "$out"
