#!/usr/bin/bash

rm /tmp/compile_purescript.txt
npm run build &>/tmp/compile_purescript.txt
cat /tmp/compile_purescript.txt | grep -P "Build succeeded|Error found"
