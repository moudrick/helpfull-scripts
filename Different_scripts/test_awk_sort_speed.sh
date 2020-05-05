#!/bin/bash
# Comparing speed of sort and awk
#data=${1}

data='test_lines_file'

export TIME="\t%E,\t%k"
#data='15000kb'

#touch "$data"
echo `date` > "$data"

for i in {1..5000}
do
od -vAn -N4 -tu4 < /dev/urandom >> $data
done
#exit 0


echo '==============================================================='
echo 'Used sort|uniq'
time sort "$data" | uniq -u > u1

echo
echo '---------------------------------------------------------------'
echo

echo 'Used awk'
time awk '{!seen[$0]++};END{for(i in seen) if(seen[i]==1)print i}' $data > u2
echo '==============================================================='

#rm "$data" u1 u2
