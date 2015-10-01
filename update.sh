#!/bin/bash

CMD=echo
SDIR=.
TDIR=.

function help() {
	echo "[options] <rootOfMediaRite>"	
	echo "-push      copy TO MediaRite"
	echo "-update    copy FROM MediaRite"
	echo "-meld      meld"
	echo "-echo      echo cmd"
}

function argerror() {
	echo $@
	help
	exit 1;
}

while [ -n "$1" ]; do
	case "$1" in
		-push)
			shift
			CMD=cp
			TDIR=$1

			;;
		-update)
			shift
			CMD=cp
			SDIR=$1
			;;
		-meld)
			shift
			CMD=meld
			TDIR=$1
			;;
		-echo)
			shift
			CMD=echo
			TDIR=$1
			;;
		--)
			break;
			;;
		-*)
			argerror "Unknown option $1";
			;;
		*)
			break;
			;;
	esac
done

if [ -z "$1" ] ; then
	argerror "MediaRite location param missing"
fi

if [ "$CMD" == "copy" ] ; then
$CMD ${SDIR}/Resource/Language/7702/locale/master.pot ${TDIR}/Resource/Language/7702/locale/master.pot
for dir in ${SDIR}/Resource/Language/7702/locale/; do
    [ -d "${dir}" ] || continue # if not a directory, skip
    dirname="$(basename "${dir}")"    
    $CMD ${SDIR}/Resource/Language/7702/locale/${dirname}/mediarite.po ${TDIR}/Resource/Language/7702/${dirname}/mediarite.po
done
for dir in ${SDIR}/Source/Android/Amoeba/app/src/main/res/values*; do
    [ -d "${dir}" ] || continue # if not a directory, skip
    dirname="$(basename "${dir}")"    
    $CMD ${SDIR}/Source/Android/Amoeba/app/src/main/res/${dirname}/strings.xml ${TDIR}/Source/Android/Amoeba/app/src/main/res/${dirname}/strings.xml
done
else
$CMD ${SDIR}/Resource/Language/7702/locale/ ${TDIR}/Resource/Language/7702/locale/
$CMD ${SDIR}/Source/Android/Amoeba/app/src/main/res/ ${TDIR}/Source/Android/Amoeba/app/src/main/res/
fi
