#!/usr/bin/env bash
# Generates VERSIONS.md from VERSIONS.md.template by replacing the lines
#   {{PENDING}}    PHP versions of the version branches (origin/X.Y) without a tag on Docker Hub
#   {{PUBLISHED}}  table rows of all tags of the Docker Hub repository
set -euo pipefail

repo="alaugks/apache-php"
github="https://github.com/alaugks/docker-apache-php"
root="$(dirname "$0")/.."
out="${root}/VERSIONS.md"
template="$(dirname "$0")/VERSIONS.md.template"
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

if [ -n "$pending" ]; then
  pending="| PHP version | Branch |"$'\n'"|-------------|--------|"$'\n'"${pending}"
else
  pending="None."$'\n'
fi

while IFS= read -r line; do
  case "$line" in
    "{{PENDING}}") printf '%s' "$pending" ;;
    "{{PUBLISHED}}") printf '%s' "$rows" ;;
    *) printf '%s\n' "$line" ;;
  esac
done < "$template" > "$out"
