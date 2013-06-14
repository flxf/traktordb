#!/bin/bash

if [[ ! -d /Volumes/traktorram ]]; then
  diskutil erasevolume HFS+ 'traktorram' `hdiutil attach -nomount ram://524288`
fi
