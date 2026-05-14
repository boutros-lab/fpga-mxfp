#!/usr/bin/env bash

for file in "$@"; do
	echo "==============================="
	echo " $file "
	echo "==============================="
	column -s, -t $file
done

