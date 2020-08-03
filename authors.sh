#!/bin/bash
FILE=$1
DBNAME=authors.db

[ ! -f $DBNAME ] && sqlite3 $DBNAME "create table n ( \
	id INTEGER PRIMARY KEY, \
	file TEXT NOT NULL, \
	license TEXT NOT NULL, \
	copyright0 TEXT NOT NULL, \
	copyright1 TEXT, \
	copyright2 TEXT, \
	declared_author TEXT, \
	author0 TEXT NOT NULL, \
	email0 TEXT, \
	lines0 INTEGER, \
	author1 TEXT, \
	email1 TEXT, \
	lines1 INTEGER, \
	author2 TEXT, \
	email2 TEXT, \
	lines2 INTEGER, \
	NOTE TEXT);"
LICENSE="OTHER"
head -10 $FILE | grep -i 'Apache' && LICENSE="APACHE"
CP=$(head -20 $FILE | grep -iE "copyright.*[19,20][0-9][0-9]" | sed 's/^.*[19,20][0-9][0-9]. \([[:alnum:]]* [[:alnum:]]*\).*$/\1/')
CP0="$(head -1 <<< $CP)"
CP1=
CP2=
[ $(wc -l <<< $CP) > 1 ] && CP1="$(head -2 <<< $CP | tail -n +2)"
[ $(wc -l <<< $CP) > 2 ] && CP2="$(head -3 <<< $CP | tail -n +3)"
DECLARED_AUTHOR="$(head -20 $FILE | grep -iE -A2 'author[s]*:' | xargs | sed 's/.*author[s]*:\(.*<.*@.*>\).*$/\1/i;s/[\*]//g')"
echo "Declared author(s) for $FILE: $DECLARED_AUTHOR"
echo "Top 3 committers:"
AUTHORS=$(git log --no-merges --pretty=format:"%an;%ae"  --stat --follow $FILE | \
sed '/./{H;$!d} ; x ; s/\n\(.*\);\(.*\)\n.*| \([0-9]*\).[+,-]*.*/\1,\2,\3/' | \
sort | \
awk -F, 'BEGIN{sum=0;}{for(i=0;i<NR;i++)sum+=$3} {n1=$1;if(n1!=n0) {print n0","e0","sum;sum=$3;e0=$2;}n0=$1;}END{print n0","e0","sum;}' | \
sed '1d' | \
sort -t, -k3nr | \
sed '1,3!d' | tee /dev/tty
)
case $(wc -l <<< $AUTHORS) in

1) DBCMD=$(echo $AUTHORS | xargs | sed "s|\(.*\),\(.*\),\([0-9]*\)|insert into n(file,license,copyright0,copyright1,copyright2,declared_author,author0,email0,lines0) values('$FILE','$LICENSE','$CP0','$CP1','$CP2','$DECLARED_AUTHOR','\1','\2',\3)|")
    ;;
2) DBCMD=$(echo $AUTHORS | xargs | sed "s|\(.*\),\(.*\),\([0-9]*\) \(.*\),\(.*\),\([0-9]*\)|insert into n(file,license,copyright0,copyright1,copyright2,declared_author,author0,email0,lines0,author1,email1,lines1) values('$FILE','$LICENSE','$CP0','$CP1','$CP2','$DECLARED_AUTHOR','\1','\2',\3,'\4','\5',\6)|")
    ;;
3) DBCMD=$(echo $AUTHORS | xargs | sed "s|\(.*\),\(.*\),\([0-9]*\) \(.*\),\(.*\),\([0-9]*\) \(.*\),\(.*\),\([0-9]*\)|insert into n(file,license,copyright0,copyright1,copyright2,declared_author,author0,email0,lines0,author1,email1,lines1,author2,email2,lines2) values('$FILE','$LICENSE','$CP0','$CP1','$CP2','$DECLARED_AUTHOR','\1','\2',\3,'\4','\5',\6,'\7','\8',\9)|")
    ;;
esac

echo "Executing SQL command:"
echo $DBCMD
sqlite3 $DBNAME "$DBCMD"
