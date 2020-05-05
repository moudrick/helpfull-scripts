#!/bin/bash

# Usefull links
# https://www.2daygeek.com/category/dns-lookup/
# https://www.2daygeek.com/linux-host-command-check-find-dns-records-lookup/
# https://www.2daygeek.com/dig-command-check-find-dns-records-lookup-linux/

# Default data
dns_domain='google.eu'
dns_record='A CNAME NS MX DNAME AAAA TXT PTR'

#Colors
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
printf "I ${RED}love${NC} This Repo\n"

echo "*********************************************************************"
echo "Please enter domain for scan"
read in_domain
if [ ! -z $in_domain ]
then
  dns_domain=$in_domain
fi

echo "Please enter record type for scan"
read in_record
if [ ! -z $in_record ]
then
  dns_record=$in_record
fi

echo
echo "====================================================================="
echo "We will scan domain ${RED}$dns_domain${NC} for ${RED}$dns_record${NC} record"
echo "---------------------------------------------------------------------"
echo
for record in $dns_record
do
  echo "......................................................"
  echo -e "Data of ${RED}$record${NC} record with ${GREEN}~host~${NC}"
  host -t $record $dns_domain
  echo "......................................................"
  echo -e "Data of ${RED}$record${NC} with ${GREEN}~nslookup~${NC}"
  nslookup -query=$record $dns_domain
done
