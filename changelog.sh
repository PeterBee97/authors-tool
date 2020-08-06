#!/bin/bash
cat ChangeLog | grep -iE "from|by" | sed 's/^.*by//i;s/^.*from//i;s/[^a-zA-Z0-9!@#$%&*()_+-=;:,.<>/? ]//g' > ChangeLog2
./process.py | sed 's/^ //' | sort | uniq > names.txt

