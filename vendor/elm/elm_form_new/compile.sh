#!/bin/bash

echo Compiling

elm make ./src/ElmFormNew.elm --output elm_form_new.js
mv ./elm_form_new.js ../../../public/elm_form_new.js
