#!/bin/bash

#foo()
#{
#	owner_lowercase=`echo $1 |  sed -e 's/\(.*\)/\L\1/'`
#	echo $owner_lowercase
#	return $owner_lowercase
#}

lc(){
    case "$1" in
        [A-Z])
        n=$(printf "%d" "'$1")
        n=$((n+32))
        printf \\$(printf "%o" "$n")
        ;;
        *)
        printf "%s" "$1"
        ;;
    esac
}
word="$1"
for((i=0;i<${#word};i++))
do
    ch="${word:$i:1}"
    lc "$ch"
done
