#!/bin/bash

exec 6>foo

echo output 1>&6

exec 5<&1
exec 1>/dev/null
echo foo1
exec 1<&5
echo foo2


exec 3<>/dev/tcp/www.google.com/80
echo -e "HEAD / HTTP/1.1\n\n" >&3
cat <&3
