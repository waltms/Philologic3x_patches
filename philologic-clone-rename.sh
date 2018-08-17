#!/bin/sh

# This script will replace all instances of a string within files and file names with
# another string. Written specifically to help run parallel versions of philologic.
# You will want to at least replace "philologic" with something else, e.g. "philologic31"
# and it is probably a good idea to also replace "nserver", "philoload", "search3" and "crapser".
#
# Usage: ./philologic-clone-rename.sh <NEW DIR> <FIND STRING> <REPLACE STRING>

DIR=$1
FINDNAME=$2
REPLACENAME=$3

if [ "$DIR" = "" ]; then
	echo "No Working Directory specified."
	exit
fi

if [ "$FINDNAME" = "" ]; then
	echo "No Search String specified."
	exit
fi

if [ "$REPLACENAME" = "" ]; then
	echo "No Replace String specified."
	exit
fi

cd $DIR

echo; echo "###STEP ONE###"
echo "Changing directory to $DIR"

echo; echo "###STEP TWO###"
for i in `find . | grep -vs "$REPLACENAME" | grep -s "$FINDNAME"`
do 
	NEWNAME=`echo $i | sed "s/$FINDNAME/$REPLACENAME/"`
	echo "Renaming $i to $NEWNAME"
	mv $i $NEWNAME
done

echo; echo "###STEP THREE###"
for i in `find . | xargs grep -vls "$REPLACENAME" | xargs grep -ls "$FINDNAME"`
do 
	echo "Replacing $FINDNAME with $REPLACENAME in $i"
	cat $i | sed "s/$FINDNAME/$REPLACENAME/g" > /tmp/file.tmp
	mv /tmp/file.tmp $i
	
done
echo; echo "###DONE###"
