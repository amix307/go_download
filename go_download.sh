#!/bin/bash

json_url=$(curl -s https://go.dev/dl/?mode=json)
latest_stable_version=$(echo "$json_url" | jq -r '[.[] | select(.stable == true) | .version] | max')
os=$(uname | tr '[:upper:]' '[:lower:]')
arch=$(arch)

if [ "$arch" == "x86_64" ]; then
    arch="amd64"
fi

file_info=$(echo "$json_url" | jq -r --arg os "$os" --arg arch "$arch" --arg version "$latest_stable_version" '.[] | select(.version == $version) | .files[] | select(.os == $os and .arch == $arch)')
filename=$(echo "$file_info" | jq -r '.filename')
sha256=$(echo "$file_info" | jq -r '.sha256')
download_link="https://go.dev/dl/$filename"

curl -s -LO "$download_link"

downloaded_sha256=$(sha256sum "$filename" | cut -d ' ' -f 1)

if [ "$downloaded_sha256" != "$sha256" ]; then
    echo "Error: SHA256 of the downloaded file does not match the expected one. Deleting."
    rm -f "$filename"
    exit 1
fi

echo "$filename is OK"
