#!/usr/bin/env bash

buildperfbreakdownlambdalatencysummary() {

 echo USAGE: perfbreakdown arg1:FILE - arg2:Expected latency - arg3:Size of input file - arg4:Number of runs  	
 echo 1st arg: $1
 echo 2nd arg: $2
 echo 3rd arg: $3
 echo 4th arg: $4

 sleep 3 

 durationlambdalatencyaccnanosecs=0

 cat $1 | grep durationlatency > durationlambdalatency.out

 #cat durationio.out
 #cat durationprocess.out
 cat durationlambdalatency.out

 # Read Latency file
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   durationlambdalatencyaccnanosecs=$((durationlambdalatencyaccnanosecs+$measure))
 done < durationlambdalatency.out

 #echo $($durationnanoioacc/1000000)
 #echo $($durationnanocomputeacc/1000000)
 #echo $($durationnanosyncacc/1000000)

 durationlambdalatencyavgnanosecs=$((durationlambdalatencyaccnanosecs / $4))

 durationlambdalatencyavgnanosecs=$((durationlambdalatencyavgnanosecs / $3))

 durationlambdalatencyavgmicrosecs=$((durationlambdalatencyavgnanosecs / 1000))

 echo "Lambda Latency  - Performance Breakdown Summary"

 echo "duration Current Lambda Latency: $durationlambdalatencyavgmicrosecs microseconds"
 echo "duration Expected Lambda Latency: $2 microseconds"

 #echo "Overall duration: $durationoverall seconds"

}


buildperfbreakdownefsiosummary() {

 echo USAGE: perfbreakdown arg1:FILE - arg2:Size Type - arg3:Number of jobs - arg4:Number of runs  	
 echo 1st arg: $1
 echo 2nd arg: $2
 echo 3rd arg: $3
 echo 4rd arg: $4

 sleep 3 

 durationdownloadefsaccnanosecs=0
 durationuploadefsaccnanosecs=0

 cat $1 | grep durationdownloadefs > durationdownloadefs.out
 cat $1 | grep durationuploadefs > durationuploadefs.out

 #cat durationio.out
 #cat durationprocess.out

 # Read Download file 
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   durationdownloadefsaccnanosecs=$((durationdownloadefsaccnanosecs+$measure))
 done < durationdownloadefs.out

 # Read Upload file
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   durationuploadefsaccnanosecs=$((durationuploadefsaccnanosecs+$measure))
 done < durationuploadefs.out

 #echo $($durationnanoioacc/1000000)
 #echo $($durationnanocomputeacc/1000000)
 #echo $($durationnanosyncacc/1000000)

 durationdownloadefsavgnanosecs=$((durationdownloadefsaccnanosecs / $4))
 durationuploadefsavgnanosecs=$((durationuploadefsaccnanosecs / $4))

 durationdownloadefsavgnanosecs=$((durationdownloadefsavgnanosecs / $3))
 durationuploadefsavgnanosecs=$((durationuploadefsavgnanosecs / $3))

 durationdownloadefsaccsecs=$((durationdownloadefsaccnanosecs / 1000000000))
 durationuploadefsaccsecs=$((durationuploadefsaccnanosecs / 1000000000))

 echo "EFS I/O - Size $2  - Performance Breakdown Summary"

 echo "duration Download EFS: $durationdownloadefsaccnanosecs nanoseconds"
 echo "duration Upload EFS: $durationuploadefsaccnanosecs nanoseconds"

 echo "duration Download EFS: $durationdownloadefsavfsecs seconds"
 echo "duration Upload EFS: $durationuploadefsavgsecs seconds"
 #echo "Overall duration: $durationoverall seconds"

}

buildperfbreakdownparallelnoopsummary() {

 cat $1 | grep durationsleep > durationsleep.out
 cat $1 | grep durationoverall > durationoverall.out

 echo 1st arg: $1
 echo 2nd arg: $2
 echo 3rd arg: $3

 # Read Sleep file 
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   durationnanosleepacc=$((durationnanosleepacc+$measure))
 done < durationsleep.out

 # Read Overall file 
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   echo mesure overall: $measure
   durationoverall=$measure
 done < durationoverall.out

 durationsleepaccsecs=$((durationnanosleepacc / 1000000000))

 echo "Aggregated duration sleep: $durationsleepaccsecs seconds"

 durationsleepsecs=$((durationsleepaccsecs / $2))
 durationsleepavgsecs=$((durationsleepsecs / $3))
 durationoverallavg=$((durationoverall / $3))
 durationinvokeavg=$(($durationoverallavg-$durationsleepavgsecs))
 echo ===============================================
 echo "GNU Parallel NO OP - Performance Breakdown Summary"

 echo "duration sleep: $durationsleepavgsecs seconds"
 echo "duration parallel invoke: $durationinvokeavg seconds"
 echo "Overall duration: $durationoverallavg seconds"

}


buildperfbreakdownthumbnailsnoopsummary() {

 durationnanodownloadacc=0
 durationnanoconvertacc=0
 durationnanouploadacc=0

 cat $1 | grep durationsleep > durationsleep.out
 cat $1 | grep durationinvokesshell > durationinvokesshell.out
 cat $1 | grep durationoverall > durationoverall.out

 echo 1st arg: $1
 echo 2nd arg: $2
 echo 3rd arg: $3

 # Read Sleep file 
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   durationnanosleepacc=$((durationnanosleepacc+$measure))
 done < durationsleep.out

 # Read Invoke sshell file 
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   durationnanoinvokesshellacc=$((durationnanoinvokesshellacc+$measure))
 done < durationinvokesshell.out

 # Read Overall file 
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   echo measure overall: $measure
   durationoverall=$measure
 done < durationoverall.out

 echo "duration Invoke sshell: $durationnanoinvokesshellacc nanoseconds"
 echo "duration Sleep: $durationnanosleepacc nanoseconds"

 durationinvokesshellaccsecs=$((durationnanoinvokesshellacc / 1000000000))
 durationinvokesshellaccmsecs=$((durationnanoinvokesshellacc / 1000000))
 durationsleepaccsecs=$((durationnanosleepacc / 1000000000))

 echo "Aggregated duration Invoke sshell: $durationinvokesshellaccmsecs ms"
 echo "Aggregated duration sleep: $durationsleepaccsecs s"

 durationinvokesshellsecs=$((durationinvokesshellaccsecs / $2))
 durationinvokesshellmsecs=$((durationinvokesshellaccmsecs / $2))
 durationsleepsecs=$((durationsleepaccsecs / $2))
 durationinvokesshellavgsecs=$((durationinvokesshellsecs / $3))
 durationinvokesshellavgmsecs=$((durationinvokesshellmsecs / $3))
 durationsleepavgsecs=$((durationsleepsecs / $3))
 durationoverallavg=$((durationoverall / $3))

 durationremaininvoke=$(($durationoverallavg-$durationsleepavgsecs-$durationinvokesshellavgsecs))

 echo ===============================================
 echo "Thumbnails NO OP - Performance Breakdown Summary"

 echo "duration Sleep: $durationsleepavgsecs s"
 echo "duration invoke sshell latency: $durationinvokesshellavgmsecs ms"
 echo "duration remain invoke latency: $durationremaininvoke s"
 echo "Overall duration: $durationoverallavg s"

}

buildperfbreakdownthumbnailssummary() {

 durationnanodownloadacc=0
 durationnanoconvertacc=0
 durationnanouploadacc=0

 cat $1 | grep durationdownload > durationdownload.out
 cat $1 | grep durationconvert > durationconvert.out
 cat $1 | grep durationupload > durationupload.out
 cat $1 | grep durationoverall > durationoverall.out

 echo 1st arg: $1
 echo 2nd arg: $2

 #cat durationio.out
 #cat durationprocess.out

 # Read Download file 
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   durationnanodownloadacc=$((durationnanodownloadacc+$measure))
 done < durationdownload.out

 # Read Convert file
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   durationnanoconvertacc=$((durationnanoconvertacc+$measure))
 done < durationconvert.out

 # Read Upload file
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
 #  echo "time upload: $measure"
   durationnanouploadacc=$((durationnanouploadacc+$measure))
 done < durationupload.out

 # Read Overall file 
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   echo mesure overall: $measure
   durationoverall=$measure
 done < durationoverall.out

 echo "Aggregated duration Download: $durationnanodownloadacc nanoseconds"
 echo "Aggregated duration Convert: $durationnanoconvertacc nanoseconds"
 echo "Aggregated duration Upload: $durationnanouploadacc nanoseconds"

 #echo $($durationnanoioacc/1000000)
 #echo $($durationnanocomputeacc/1000000)
 #echo $($durationnanosyncacc/1000000)

 durationdownloadaccsecs=$((durationnanodownloadacc / 1000000000))
 durationconvertaccsecs=$((durationnanoconvertacc / 1000000000))
 durationuploadaccsecs=$((durationnanouploadacc / 1000000000))

 #durationioavg=$((durationioaccsecs / ${INPUT}))
 #durationcomputeavg=$((durationcomputeaccsecs / ${INPUT}))
 #durationsyncavg=$((durationsyncaccsecs / ${INPUT}))

 #durationioacc=$((durationnanoioacc / 1000000))
 #durationcomputeacc=$((durationnanocomputeacc / 1000000))
 #durationsyncacc=$((durationnanosyncacc / 1000000))

 durationdownloadsecs=$((durationdownloadaccsecs/$2))
 durationconvertsecs=$((durationconvertaccsecs/$2))
 durationuploadsecs=$((durationuploadaccsecs/$2))

 #durationdownloadavgsecs=$((durationdownloadsecs/$3))
 #durationconvertavgsecs=$((durationconvertsecs/$3))
 #durationuploadavgsecs=$((durationuploadsecs/$3))

 #durationoverallavg=$((durationoverall / $3))

 #durationinvoke=$(($durationoverallavg-$durationdownloadavgsecs-$durationconvertavgsecs-$durationuploadavgsecs))
 durationinvoke=$(($durationoverall-$durationdownloadsecs-$durationconvertsecs-$durationuploadsecs))

 echo "Thumbnails - Performance Breakdown Summary"

 echo "duration Download: $durationdownloadsecs seconds"
 echo "duration Convert: $durationconvertsecs seconds"
 echo "duration Upload: $durationuploadsecs seconds"
 echo "duration lambda invoke: $durationinvoke seconds"
 echo "Overall duration: $durationoverall seconds"

}

buildperfbreakdownthumbnailsasynccksummary() {

 durationnanodownloadacc=0
 durationnanoconvertacc=0
 durationnanouploadacc=0

 cat $1 | grep durationdownload > durationdownload.out
 cat $1 | grep durationconvert > durationconvert.out
 cat $1 | grep durationupload > durationupload.out
 cat $1 | grep durationoverall > durationoverall.out

 echo 1st arg: $1
 echo 2nd arg: $2

 #cat durationio.out
 #cat durationprocess.out

 # Read Download file 
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   durationnanodownloadacc=$((durationnanodownloadacc+$measure))
 done < durationdownload.out

 # Read Convert file
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   durationnanoconvertacc=$((durationnanoconvertacc+$measure))
 done < durationconvert.out

 # Read Upload file
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
 #  echo "time upload: $measure"
   durationnanouploadacc=$((durationnanouploadacc+$measure))
 done < durationupload.out

 # Read Overall file 
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   echo mesure overall: $measure
   durationoverall=$measure
 done < durationoverall.out

 echo "duration Download: $durationnanodownloadacc nanoseconds"
 echo "duration Convert: $durationnanoconvertacc nanoseconds"
 echo "duration Upload: $durationnanouploadacc nanoseconds"

 #echo $($durationnanoioacc/1000000)
 #echo $($durationnanocomputeacc/1000000)
 #echo $($durationnanosyncacc/1000000)

 numinputelmts=$2
 cksize=$3
 numckruns=$(($numinputelmts / $cksize))
 remain=$(($numckruns * $cksize))
 remain=$(($numinputelmts - $remain))
 
 if [ "$remain" -ne 0 ]
 then
	 numckruns=$(($numckruns+1))
 fi

 durationdownloadaccsecs=$((durationnanodownloadacc / 1000000000))
 durationconvertaccsecs=$((durationnanoconvertacc / 1000000000))
 durationuploadaccsecs=$((durationnanouploadacc / 1000000000))

 #durationioavg=$((durationioaccsecs / ${INPUT}))
 #durationcomputeavg=$((durationcomputeaccsecs / ${INPUT}))
 #durationsyncavg=$((durationsyncaccsecs / ${INPUT}))

 #durationioacc=$((durationnanoioacc / 1000000))
 #durationcomputeacc=$((durationnanocomputeacc / 1000000))
 #durationsyncacc=$((durationnanosyncacc / 1000000))

 durationdownloadaccsecs=$((durationdownloadaccsecs/$2))
 durationconvertaccsecs=$((durationconvertaccsecs/$2))
 durationuploadaccsecs=$((durationuploadaccsecs/$2))
 durationinvoke=$(($durationoverall-$durationdownloadaccsecs-$durationconvertaccsecs-$durationuploadaccsecs))

 echo "Thumbnails - Performance Breakdown Summary"

 echo "duration Download: $durationdownloadaccsecs seconds"
 echo "duration Convert: $durationconvertaccsecs seconds"
 echo "duration Upload: $durationuploadaccsecs seconds"
 echo "duration lambda invoke: $durationinvoke seconds"
 echo "Overall duration: $durationoverall seconds"

}

buildperfbreakdownsummary() {

 durationnanoioacc=0
 durationnanocomputeacc=0
 durationnanosyncacc=0

 cat $1 | grep durationio > durationio.out
 cat $1 | grep durationprocess > durationprocess.out
 cat $1 | grep durationsync > durationsync.out

 #cat durationio.out
 #cat durationprocess.out

 # Read S3 IO file
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   #echo "time io: $measure"
   durationnanoioacc=$((durationnanoioacc+$measure))
 done < durationio.out

 # Read Compute file
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
   #echo "time compute: $measure"
   durationnanocomputeacc=$((durationnanocomputeacc+$measure))
 done < durationprocess.out

 # Read Sync file
 while read l; do
   measure=$(echo ${l} | awk '{print $3}')
 #  echo "time sync: $measure"
   durationnanosyncacc=$((durationnanosyncacc+$measure))
 done < durationsync.out

 echo "duration S3 IO: $durationnanoioacc nanoseconds"
 echo "duration Compute: $durationnanocomputeacc nanoseconds"
 echo "duration Sync: $durationnanosyncacc nanoseconds"

 #echo $($durationnanoioacc/1000000)
 #echo $($durationnanocomputeacc/1000000)
 #echo $($durationnanosyncacc/1000000)

 durationioaccsecs=$((durationnanoioacc / 1000000000))
 durationcomputeaccsecs=$((durationnanocomputeacc / 1000000000))
 durationsyncaccsecs=$((durationnanosyncacc / 1000000000))

 #durationioavg=$((durationioaccsecs / ${INPUT}))
 #durationcomputeavg=$((durationcomputeaccsecs / ${INPUT}))
 #durationsyncavg=$((durationsyncaccsecs / ${INPUT}))

 #durationioacc=$((durationnanoioacc / 1000000))
 #durationcomputeacc=$((durationnanocomputeacc / 1000000))
 #durationsyncacc=$((durationnanosyncacc / 1000000))

 echo "Performance Breakdown Summary"

 echo "Overall duration S3 IO: $durationioaccsecs seconds"
 echo "Overall duration Compute: $durationcomputeaccsecs seconds"
 echo "Overall duration Sync: $durationsyncaccsecs seconds"

}

buildperfbreakdownthumbnailssummary $1 $2
#buildperfbreakdownparallelnoopsummary $1 $2 $3
#buildperfbreakdownthumbnailsnoopsummary $1 $2 $3
#buildperfbreakdownthumbnailsasynccksummary $1 $2 $3
#buildperfbreakdownefsiosummary $1 $2 $3 $4
#buildperfbreakdownlambdalatencysummary $1 $2 $3 $4
