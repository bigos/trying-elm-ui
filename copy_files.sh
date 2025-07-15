#!/bin/sh

rm -v ./public/index_halogen.js
ln -s /home/jacek/Programming/Pyrulis/Purescript/halogen//counter/prod/index.js ./public/index_halogen.js

rm -v ./public/index_flame.js
ln -s /home/jacek/Programming/Pyrulis/Purescript/flame/counter/prod/index.js ./public/index_flame.js
