#!/bin/sh
# https://stackoverflow.com/questions/22896955/apache-access-log-for-the-most-common-ip-address-bash-script

if [ -e $1 ]
then
in_file="ips_for_test.txt"
else
in_file="$1"
fi

echo "Scannig file $in_file:"

echo "--------------------------------------------------"
cat $in_file | awk '{print $1}'| uniq -c |sort -n -k 1| tail
echo

echo "--------------------------------------------------"
awk '{a[$1]++} END {for (i in a) print a[i],i | "sort -rnk1"}' $in_file
echo
echo "--------------------------------------------------"
#awk '{a[$1]++} END {for (i in a) print a[i],i | "sort -rnk1"}' $in_file
awk '{a[$1]++} END {for (i in a) print a[i],i}' $in_file | sort
echo

echo "--------------------------------------------------"
