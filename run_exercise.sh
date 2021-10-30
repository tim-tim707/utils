#!/bin/bash

if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]; then
  echo "Usage: $0 student_list_file, exercise, optional args" >&2
  exit 1
fi

EXEC="$2"
ARGS="$3"

for login in `cat $1`
do
    echo
    echo $login
    echo =====
    timeout 1 ./tp03-"$login"/sdl/"$2" "$3"
done