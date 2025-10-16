#!/bin/bash

echo Compiling Cocktails

elm make ./src/Cocktails.elm --output elm-cocktails.js
mv ./elm-cocktails.js ../../../public/elm-cocktails.js
