#!/bin/sh


JAVA=$(/usr/libexec/java_home -v "1.8" 2> /dev/null)
STATUS="$?"

[ "$STATUS" -eq 0 ] && echo "export JAVA_HOME=$JAVA"
exit 0
