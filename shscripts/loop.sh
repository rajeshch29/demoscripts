#!/bin/bash
for i in `cat list.txt`
do
#echo $i;
name=`echo $i|awk -F '##' '{print $1}'`
degn=`echo $i| awk -F '##' '{print $2}'`
age=`echo $i| awk -F '##' '{print $3}'`
echo "$name is a $degn and his age is $age"
done