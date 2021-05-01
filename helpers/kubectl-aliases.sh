#!/bin/sh

DELIM=${1:-"-"}
REPLACE="$2"

for context in $(kubectl config get-contexts -o name);
do
    clean_ctx="$(echo "$context" | sed -e "s/$DELIM/$REPLACE/g")"
    alias_to_create="$(printf "%s%s" "k" "$clean_ctx")"
    echo alias "$alias_to_create='kubectl --context=$context '"
done
