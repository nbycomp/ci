#!/usr/bin/env bash
set -e

# This script updates CHANGELOG.md.
# It does commit the changes since that doesn't make sense during development.
# This needs to happen separately on CI.

echo
echo "FETCH GIT METADATA ..."
git fetch origin +refs/tags/*:refs/tags/*

echo
echo "INSTALL CHANGELOG GENERATOR ..."
npm install -g conventional-changelog-cli

echo
echo "GENERATE THE CHANGELOG ..."
npm exec -- conventional-changelog-cli -p conventionalCommits -r 0 -o CHANGELOG.md
npm exec -- doctoc CHANGELOG.md
sed -i "s/\*\*Table of Contents.*/**Table of Contents**/" CHANGELOG.md
sed -i "s/\*This Change Log was.*/This Change Log was automatically generated/" CHANGELOG.md
t=$(mktemp)
printf "# Changelog\n\n" | cat - CHANGELOG.md >"$t" && mv "$t" CHANGELOG.md

echo
echo "FORMAT THE CHANGELOG ..."
# NOTE: need to format twice because of https://github.com/prettier/prettier/issues/13213
npm exec -- prettier --write CHANGELOG.md
npm exec -- prettier --write CHANGELOG.md
npm exec -- prettier --check CHANGELOG.md
