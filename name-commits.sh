#!/bin/bash
while read p;do
	echo "$p:" >> $2
	git log --no-merges --pretty=format:"%h" --author="$p" | xargs >> $2
	cat commits-patacongo.txt | grep "$p" | awk '{print $1}' | xargs >> $2 
done <$1
