#!/bin/bash

echo Compiling

elm make ./src/UiExperiment.elm --output ui-experiment.js
mv -v ./ui-experiment.js ../../../public/ui-experiment.js
