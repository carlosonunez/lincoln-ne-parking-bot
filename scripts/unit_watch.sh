#!/usr/bin/env bash
if ! which fswatch >/dev/null
then
  >&2 echo "ERROR: You don't have fswatch installed. Install it with \
Homebrew: brew install fswatch"
  exit 1
fi

>&2 echo "INFO: Unit test monitor started."
things_to_exclude="scripts,docker-compose.*.yml,README.md,Gemfile,bash_aliases,\
include,.*.Dockerfile,.git"
excludes=""
for item in $(echo "$things_to_exclude" | tr ',' "\n")
do
  excludes="${excludes}-e "$PWD/$item" "
done
command="fswatch -o ${excludes} ."
eval "$command" | \
  xargs -n1 -I{} bash -c "echo 'INFO: Running unit tests...' && \
scripts/unit || true;
echo 'INFO: Unit tests done.'"
>&2 echo "INFO: Monitor ended."
