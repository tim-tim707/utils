#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo provide login file, practical number, file to copy
    exit 1
fi

number="$2"
file="$3"

for login in `cat $1`
do
    echo $login
    cp $file tp"$number"-"$login"/arrays/"$file"
done