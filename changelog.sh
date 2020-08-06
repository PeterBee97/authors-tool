#!/bin/bash
cat $1 | grep -iE "from|by" | sed 's/^.*by//i;s/^.*from//i;s/[^a-zA-Z0-9!@#$%&*()_+-=;:,.<>/? ]//g' > log.tmp
./process.py log.tmp | sed 's/^ //' | sort | uniq > names.txt
rm log.tmp

