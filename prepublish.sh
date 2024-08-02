#!/usr/bin/env sh

NPM_VERSION=$(jq -r ".version" package.json)
BS_VERSION=$(jq -r ".version" rescript.json)

SWR_VERSION=$(jq ".dependencies.swr" package.json)

if [ "$NPM_VERSION" != "$BS_VERSION" ]; then
  echo "Versions do not match. Exiting..."
  exit 1
fi

read -p "Is SWR version ${SWR_VERSION} corresponding to package \
version ${NPM_VERSION} correct? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
  echo "Aborted publishing process."
  exit 1
fi
