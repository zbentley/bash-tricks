#!/bin/bash

# Setup
cd scratch

echo foo > tst.txt
for i in {1..10000}; do
  echo buzz >> tst.txt;
done


echo first
grep -q foo tst.txt && echo FOUND || echo NOT FOUND
grep -q bar tst.txt && echo FOUND || echo NOT FOUND

echo second
cat tst.txt | grep -q foo && echo FOUND || echo NOT FOUND
cat tst.txt | grep -q bar && echo FOUND || echo NOT FOUND

echo third
if grep -q foo tst.txt; then echo FOUND; else echo NOT FOUND; fi
if grep -q bar tst.txt; then echo FOUND; else echo NOT FOUND; fi

echo fourth
grep -q foo tst.txt
if [ $? -eq 0 ]; then echo FOUND; else echo NOT FOUND; fi
grep -q bar tst.txt
if [ $? -eq 0 ]; then echo FOUND; else echo NOT FOUND; fi


echo -e '\n\nSETTING SAFE MODE\n\n'
set -euo pipefail

echo first
grep -q foo tst.txt && echo FOUND || echo NOT FOUND
grep -q bar tst.txt && echo FOUND || echo NOT FOUND

echo second
cat tst.txt | grep -q foo && echo FOUND || echo NOT FOUND
cat tst.txt | grep -q bar && echo FOUND || echo NOT FOUND

echo third
if grep -q foo tst.txt; then echo FOUND; else echo NOT FOUND; fi
if grep -q bar tst.txt; then echo FOUND; else echo NOT FOUND; fi

echo fourth
grep -q foo tst.txt
if [ $? -eq 0 ]; then echo FOUND; else echo NOT FOUND; fi
grep -q bar tst.txt
if [ $? -eq 0 ]; then echo FOUND; else echo NOT FOUND; fi
