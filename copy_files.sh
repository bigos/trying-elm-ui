#!/bin/sh

rm -v ./public/index_halogen.js
ln -s /home/jacek/Programming/Rails/trying-elm-ui/vendor/purescript/halogen/counter/prod/index.js  ./public/index_halogen.js

rm -v ./public/index_flame.js
ln -s /home/jacek/Programming/Rails/trying-elm-ui/vendor/purescript/flame/counter/prod/index.js ./public/index_flame.js
