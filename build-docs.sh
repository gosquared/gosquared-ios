#!/usr/bin/env bash

appledoc \
--project-name "GoSquared iOS SDK" \
--project-company GoSquared \
--create-html \
--no-create-docset \
--keep-intermediate-files \
--keep-undocumented-objects \
--keep-undocumented-members \
--output . \
GoSquared*/*.h
