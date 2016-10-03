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

if [ "$CMD" == "cp" ] ; then
if [ "$TDIR" == "." ] ; then
    $CMD ${SDIR}/Resource/Language/7702/locale/master.pot ${TDIR}/Resource/Language/7702/locale/master.pot
else
    for dir in ${SDIR}/Resource/Language/7702/locale/??; do
	[ -d "${dir}" ] || continue # if not a directory, skip
	dirname="$(basename "${dir}")"    
	$CMD ${SDIR}/Resource/Language/7702/locale/${dirname}/mediarite.po ${TDIR}/Resource/Language/7702/locale/${dirname}/mediarite.po
    done
    make -C ${TDIR}/Resource/Language update_from_master
    echo "Processing Web Translations"
    ./webtrans.pl 7702
    $CMD ${SDIR}/Resource/Gui/7702/tv-gateway-web/bundle/* ${TDIR}/Resource/Gui/7702/tv-gateway-web/bundle/
fi
if [ "$TDIR" == "." ] ; then
    $CMD ${SDIR}/Source/Android/Amoeba/app/src/main/res/values/strings.xml strings.tmp
    cat strings.tmp |grep -v 'translatable="false"' > ${TDIR}/Source/Android/Amoeba/app/src/main/res/values/strings.xml
    rm -f strings.tmp
else
    for dir in ${SDIR}/Source/Android/Amoeba/app/src/main/res/values-??; do
	[ -d "${dir}" ] || continue # if not a directory, skip
	dirname="$(basename "${dir}")"    
	mkdir -p ${TDIR}/Source/Android/Amoeba/app/src/main/res/${dirname}
	$CMD ${SDIR}/Source/Android/Amoeba/app/src/main/res/${dirname}/strings.xml ${TDIR}/Source/Android/Amoeba/app/src/main/res/${dirname}/strings.xml
#	cat ${SDIR}/Source/Android/Amoeba/app/src/main/res/${dirname}/strings.xml | sed 's/&lt;b&gt;/<b>/'| sed 's/&lt;\/b&gt;/<\/b>/' > ${SDIR}/Source/Android/Amoeba/app/src/main/res/${dirname}/strings.xml.tmp
#	$CMD ${SDIR}/Source/Android/Amoeba/app/src/main/res/${dirname}/strings.xml.tmp ${TDIR}/Source/Android/Amoeba/app/src/main/res/${dirname}/strings.xml
#	rm -f ${SDIR}/Source/Android/Amoeba/app/src/main/res/${dirname}/strings.xml.tmp
    done
fi
if [ "$TDIR" == "." ] ; then
    $CMD ${SDIR}/Source/Android/AuroraLauncher/app/src/main/res/values/strings.xml strings.tmp
    cat strings.tmp |grep -v 'translatable="false"' > ${TDIR}/Source/Android/AuroraLauncher/app/src/main/res/values/strings.xml
    rm -f strings.tmp
else
    for dir in ${SDIR}/Source/Android/AuroraLauncher/app/src/main/res/values-??; do
	[ -d "${dir}" ] || continue # if not a directory, skip
	dirname="$(basename "${dir}")"    
	mkdir -p ${TDIR}/Source/Android/AuroraLauncher/app/src/main/res/${dirname}
	$CMD ${SDIR}/Source/Android/AuroraLauncher/app/src/main/res/${dirname}/strings.xml ${TDIR}/Source/Android/AuroraLauncher/app/src/main/res/${dirname}/strings.xml
    done
fi

if [ "$TDIR" == "." ] ; then
    $CMD ${SDIR}/Source/Android/AuroraWizard/app/src/main/res/values/strings.xml strings.tmp
    cat strings.tmp |grep -v 'translatable="false"' > ${TDIR}/Source/Android/AuroraWizard/app/src/main/res/values/strings.xml
    rm -f strings.tmp
else
    for dir in ${SDIR}/Source/Android/AuroraWizard/app/src/main/res/values-??; do
	[ -d "${dir}" ] || continue # if not a directory, skip
	dirname="$(basename "${dir}")"    
	mkdir -p ${TDIR}/Source/Android/AuroraWizard/app/src/main/res/${dirname}
	$CMD ${SDIR}/Source/Android/AuroraWizard/app/src/main/res/${dirname}/strings.xml ${TDIR}/Source/Android/AuroraWizard/app/src/main/res/${dirname}/strings.xml
    done
fi

else
$CMD ${SDIR}/Resource/Language/7702/locale/ ${TDIR}/Resource/Language/7702/locale/
$CMD ${SDIR}/Source/Android/Amoeba/app/src/main/res/ ${TDIR}/Source/Android/Amoeba/app/src/main/res/
$CMD ${SDIR}/Source/Android/AuroraLauncher/app/src/main/res/ ${TDIR}/Source/Android/AuroraLauncher/app/src/main/res/
$CMD ${SDIR}/Source/Android/AuroraWizard/app/src/main/res/ ${TDIR}/Source/Android/AuroraWizard/app/src/main/res/
fi
