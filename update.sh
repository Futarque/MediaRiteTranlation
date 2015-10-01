#!/bin/bash

CMD=ls
SDIR=.
TDIR=.

function help() {
	echo "[options] <rootOfMediaRite>"	
	echo "-push      copy TO MediaRite"
	echo "-update    copy FROM MediaRite"
	echo "-m         meld"

}

function argerror() {
	echo $@
	help
	exit 1;
}

EXP_OPT=''
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
	shift;

done


meld locale/ ${TDIR}/Resource/Language/7702/locale/ &
meld Amoeba/ $1/Source/Android/Amoeba/app/src/main/res/ &
