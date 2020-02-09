#!/bin/bash

disk1="/Volumes/FinalCutPro-1994-2009/"
disk2="/Users/sarosi/Movies/"
fcpDir="FinalCutPro-1994-2009 1.fcpbundle/"
mediaDir="Original Media/"
disk1MovieDir="HomeMovies/"
disk2MovieDir="HomeMovies/"

for f in "$disk1$fcpDir$1/$mediaDir"*.dv
do 
   echo "file '$f'" >> input.txt
done

ffmpeg -f concat -safe 0 -i input.txt -c:v libx264 -profile:v main -level 3.1 -c:a aac -strict -2 -ab 128k -b:v 6800k -pix_fmt yuv420p -movflags faststart -vf "yadif=0:-1:0" -metadata "genre="$2$3 $disk2$disk2MovieDir$2/$1.mp4
rm input.txt

cp $disk2$disk2MovieDir$2/$1.mp4 $disk1$disk1MovieDir/$2
