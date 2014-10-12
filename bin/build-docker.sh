#!/bin/sh

repo=$(git remote -v | awk '/(push)/{print $2}' | sed 's/\/docker-/\//;s/\.git$//' | xargs basename)
ref=$(git show --oneline | head -1 | awk '{print $1}')
tag=$(git describe --tags 2> /dev/null || echo $ref)

repo=$(echo $repo | tr '[:upper:]' '[:lower:]')

exec docker build -t $repo:$tag .
