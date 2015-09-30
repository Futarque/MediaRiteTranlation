#!/bin/bash
#svn export https://svn/MediaRite/trunk/Resource/Language/7702/locale
svn export https://svn/MediaRite/trunk/Source/Android/Amoeba/app/src/main/res/values/strings.xml strings.tmp
cat strings.tmp |grep -v 'translatable="false"' > Amoeba/values/strings.xml
rm -f strings.tmp

#svn export https://svn/MediaRite/trunk/Source/Android/Amoeba/app/src/main/res/values-da/strings.xml Amoeba/values-da/strings.xml
#svn export https://svn/MediaRite/trunk/Source/Android/Amoeba/app/src/main/res/values-en/strings.xml Amoeba/values-en/strings.xml

