#!/bin/sh


JAVA=$(/usr/libexec/java_home -v "1.8" 2> /dev/null)
STATUS="$?"

[ "$STATUS" ] || echo "export JAVA_HOME=$JAVA"
