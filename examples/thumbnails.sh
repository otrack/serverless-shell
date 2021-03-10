#!/bin/bash -x

THUMBNAILSBASES3="s3://amaheo/thumbnails"
THUMBNAILSBASE="http://amaheo.s3-website-us-east-1.amazonaws.com/thumbnails"

echo "Display AWS S3 THUMBNAILS content : "
#aws s3 ls $THUMBNAILSBASE/
#aws s3 ls $THUMBNAILSBASE/ | wc -l
aws s3 ls $THUMBNAILSBASES3/ > thumbnails_content.out
awk '{ print $4 }' thumbnails_content.out > thumbnails_refined_content.out

echo ""
echo ""
echo cat thumbnails content :
cat thumbnails_content.out 

echo ""
echo ""
echo cat refined thumbnails content :
cat thumbnails_refined_content.out 

sshell "rm -rf /tmp/*"

echo ""
echo ""
echo START PROCESSING

clock1=`date +%s`

cat thumbnails_refined_content.out | parallel -j500 -I,, --env sshell "sshell \" rm -rf /tmp/* ; echo ======= ; echo BEGIN ; echo  ======= ; echo do pwd ; pwd ; export HOME=/var/task ; echo HOME ; echo echo \\\$HOME ; echo LD_LIBRARY_PATH ; echo \\\$LD_LIBRARY_PATH ; cd /tmp ; BASEFILE=${THUMBNAILSBASE}/,, ; echo BASEFILE ; echo \\\$BASEFILE ; FILEINDEX=\\\$(echo \\\$BASEFILE | awk -F'[/.]' '{print \\\$8}') ; echo FILEINDEX : ; echo \\\$FILEINDEX ; wget ${THUMBNAILSBASE}/,, ; cd --  ; echo Check /tmp content : ; ls -alsth /tmp ; echo SLEEP ; sleep 5 ; magick convert -define png:size=300x100 /tmp/*.png -auto-orient -thumbnail 180x110 -unsharp 0x.5 /tmp/THUMBNAIL\\\$FILEINDEX.png ; echo CHECK thumbnail result ; ls -alsth /tmp ; echo SLEEP ; sleep 5 ; echo ======== ; echo END ; echo ======== \"" 

clock2=`date +%s`

durationthumbnails=`expr $clock2 - $clock1`

echo ""
echo ""
echo ""
echo DURATION THUMBNAILS : $durationthumbnails seconds


echo "CHECK AWS LAMBDA /tmp"
sshell "ls -alsth /tmp"
