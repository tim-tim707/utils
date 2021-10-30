#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 student_list_file" >&2
  exit 1
fi

exercices=""

CFLAGS="-Wall -Wextra -Werror -std=c99 -g -fsanitize=address"
EXEC="main"

for login in `cat $1`
do
    echo $login
    make -C tp03-"$login"/sdl
done