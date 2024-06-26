#!/bin/bash

files=("ansible-install.md" "container-install.md" "systemd-install.md")

for file in "${files[@]}"; do
  echo "Converting $file to Docbook5..."
  pandoc --from=markdown_github --to=docbook5 "$file" -o "${file%.md}.xml"
  echo "Conversion complete: ${file%.md}.xml"
done