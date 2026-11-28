#!/usr/bin/env bash
# Writes all tags of the Docker Hub repository to VERSIONS.md, preceded by the PHP
# versions of the version branches (origin/X.Y) that have no tag on Docker Hub yet
set -euo pipefail

repo="alaugks/apache-php"
github="https://github.com/alaugks/docker-apache-php"
root="$(dirname "$0")/.."
out="${root}/VERSIONS.md"
url="https://hub.docker.com/v2/repositories/${repo}/tags?page_size=100&ordering=name"

tags=""
rows=""
while [ -n "$url" ] && [ "$url" != "null" ]; do
  page=$(curl -fsS "$url")
  tags+=$(jq -r '.results[].name' <<<"$page")$'\n'
  rows+=$(jq -r --arg repo "$repo" --arg github "$github" '.results[] | (.name | split(".")[:2] | join(".")) as $branch | "| [`\(.name)`](https://hub.docker.com/layers/\($repo)/\(.name)/images/\(([.images[] | select(.architecture == "amd64") | .digest][0] // .images[0].digest) | gsub(":"; "-"))) | [`\($branch)`](\($github)/tree/\($branch)) | `\(.digest[7:19])` | \(.last_updated[:10]) | \(.full_size / 1048576 | floor) | \([.images[].architecture] | map(select(. != "unknown")) | unique | join(", ")) |"' <<<"$page")$'\n'
  url=$(jq -r '.next' <<<"$page")
done

# PHP version of each version branch without a matching <version>-v<major>.<minor> tag
pending=""
branches=$(git -C "$root" for-each-ref --format='%(refname:lstrip=3)' refs/remotes/origin |
  grep -E '^[0-9]+\.[0-9]+$' | sort -t. -k1,1nr -k2,2nr)
for branch in $branches; do
  version=$(git -C "$root" show "origin/${branch}:Dockerfile" |
    sed -nE 's/^FROM php:([0-9]+\.[0-9]+\.[0-9]+)-apache.*/\1/p')
  if [ -z "$version" ]; then
    echo "No PHP version found in Dockerfile of branch ${branch}" >&2
    exit 1
  fi
  if ! grep -qE "^${version//./\\.}-v[0-9]+\.[0-9]+$" <<<"$tags"; then
    pending+="| \`${version}\` | [\`${branch}\`](${github}/tree/${branch}) |"$'\n'
  fi
done

{
  echo "# Versions"
  echo
  echo "## Not yet on Docker Hub"
  echo
  if [ -n "$pending" ]; then
    echo "PHP versions in the Dockerfile of a branch without an image on Docker Hub."
    echo "To build one of them locally, see [Local Build Script](README.md#local-build-script) in the README."
    echo
    echo "| PHP version | Branch |"
    echo "|-------------|--------|"
    printf '%s' "$pending"
  else
    echo "None."
  fi
  echo
  echo "## Published"
  echo
  echo "Tags of [${repo}](https://hub.docker.com/r/${repo}/tags) on Docker Hub."
  echo
  echo "| Tag | Branch | Digest | Last updated | Size (MB) | Architectures |"
  echo "|-----|--------|--------|--------------|-----------|---------------|"
  printf '%s' "$rows"
} > "$out"
