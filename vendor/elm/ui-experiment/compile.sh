#!/bin/bash

echo Compiling

elm make ./src/UiExperiment.elm --output ui-experiment.js
mv ./ui-experiment.js ../../../public/ui-experiment.js
