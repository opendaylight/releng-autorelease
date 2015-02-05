#!/bin/bash

project=${PWD##*/}

git apply /tmp/patches/${project}.patch
git commit -asm "Applying the Helium SR2 release patch"
find . -name pom.xml | xargs grep SNAPSHOT
version-bump.sh
git commit -asm "Bumping versions by 0.0.1 after the Helium SR2 release"
find . -name pom.xml | xargs grep Helium

