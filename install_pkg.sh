#!/bin/sh

pkg="./package.json ../package.json "

for f in $(ls *.js); do
  mods="$mods $(sed -n "s/^.*require('\([^.].*\)'.*/\1/p" $f | cut -d\' -f1)"
done

for m in $(echo $mods | tr ' ' '\n' | sort | uniq); do
  ver=$(grep "\"$m\":" $pkg | cut -d\" -f4)
  echo installing $m@$ver ..
  npm --loglevel=error install --save $m@$ver || exit $?
done
