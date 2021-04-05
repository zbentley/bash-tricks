#!/usr/bin/env bash

set -e

#nonexistent
#$(nonexistent)
#echo $(nonexistent)
#foo=$(nonexistent)
#export foo=$(nonexistent)
#echo rm -rf /$(nonexistent)
#
#printf 'set -e is not a seatbelt!'
#

foo() {
  echo begin foo
  nonexistent
  echo end foo
}

foo
foo && echo done

foo() {
  set -e
  echo begin foo
  nonexistent
  echo end foo
}

foo