#!/bin/bash
for file in test-*.png; do
  number=$(echo "$file" | grep -o '[0-9]\+' )
  echo $number
  new_file="$number.png"
  mv "$file" "$new_file"
done