#!/usr/bin/env bash

function cd() {
  echo trololol rm -rf /
}

cd scratch
pwd
unset cd

cd scratch
pwd
cd ..
pwd

which cd
echo $(which cd) scratch
$(which cd) scratch
pwd

echo wat
echo why does that binary even exist
