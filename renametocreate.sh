#!/bin/bash

i=1
for f in "$1"/*
do 
   oldname=${f%.*}
   extension=`echo ${f##*.} | tr [:upper:] [:lower:]`
   dir=$(dirname $f)
   newname=`mdls -raw -name kMDItemContentCreationDate $f | tr -d "+ :"`
   #echo $dir $oldname $newname $extension
   echo "renaming $f to $dir/$newname.$extension"
   mv $f $dir/$newname.$extension
   i=`expr $i + 1`
done
echo "Total Files Renamed: $i"
