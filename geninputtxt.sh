#!/bin/bash

for f in "$1"/*
do
   echo "file '$f'" >> $2.txt
done
