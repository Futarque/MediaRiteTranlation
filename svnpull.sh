#!/bin/bash
svn export https://svn/MediaRite/trunk/Resource/Language/7702/locale
svn export https://svn/MediaRite/trunk/Source/Android/Amoeba/app/src/main/res/values/strings.xml strings.tmp
cat strings.tmp |grep -v 'translatable="false"' > Amoeba/values/strings.xml
rm -f strings.tmp

mkdir -p Amoeba/values-da/
svn export https://svn/MediaRite/trunk/Source/Android/Amoeba/app/src/main/res/values-da/strings.xml Amoeba/values-da/strings.xml
mkdir -p Amoeba/values-en/
svn export https://svn/MediaRite/trunk/Source/Android/Amoeba/app/src/main/res/values-en/strings.xml Amoeba/values-en/strings.xml
#mkdir -p Amoeba/values-nl/
#mkdir -p Amoeba/values-it/
#mkdir -p Amoeba/values-fr/
#mkdir -p Amoeba/values-pl/
#mkdir -p Amoeba/values-fi/
#mkdir -p Amoeba/values-es/
#mkdir -p Amoeba/values-hu/
#mkdir -p Amoeba/values-nb/
#mkdir -p Amoeba/values-ro/
#mkdir -p Amoeba/values-sv/
#mkdir -p Amoeba/values-de/

