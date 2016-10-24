#!/bin/ksh

# v2 - now caters for long and short disk listing options
# v3 - now reports volume numbers as well as LUNIDs

# Robert Dawson
# Fujitsu Services
# 08/10/2015

#initialise temporary files
>/var/tmp/disk.out
>/var/tmp/disk.tmp
>/var/tmp/disk.tmp2
>/var/tmp/disk.tmp3
>/var/tmp/disk.tmp4

# loop round all disks gathering raw data
for i in `luxadm probe | grep "rdsk" | awk -F: '{ print $2 }'`
do
                luxadm display $i | egrep -e "DEVICE|Product ID|Serial Num|capacity|Device Address" > /var/tmp/disk.tmp
                disk=`echo $i | cut -d/ -f4`
# this disk entry can be of 2 forms - short or long
# short form has 16 chars for disk meaning between 33 and 35 chars for the whole string
# long form has 32 chars for disk meaning between 49 and 51 chars for the whole string
                LENGTH=long
                [ `echo "$disk" | wc -m` -le 36 ] && LENGTH=short

                if [ $LENGTH == "short" ]
                # short form of disk specification
                then
                                VOLNO=`echo "$disk" | cut -dd -f2 | cut -ds -f1`
                                echo "$i,\c" >>/var/tmp/disk.tmp2
                                echo "$VOLNO,\c" >> /var/tmp/disk.tmp2
                                cat /var/tmp/disk.tmp | awk '{ORS=","} $1 == "Product" { print $3 }' >> /var/tmp/disk.tmp2
                                cat /var/tmp/disk.tmp| awk '{ORS=","} $1 == "Serial" { print $3 }' >> /var/tmp/disk.tmp2
                                cat /var/tmp/disk.tmp | awk '{ORS=","} $1 == "Unformatted" { print $3 }' >> /var/tmp/disk.tmp2
                                echo "$disk" | cut -dd -f2 | cut -ds -f1 >> /var/tmp/disk.tmp2     
                else
                # long form of disk specification
                                VOLNO=`echo "$disk" | cut -dt -f2 | cut -c25-28`
                                echo "$i,\c" >>/var/tmp/disk.tmp2
                                echo "$VOLNO,\c" >> /var/tmp/disk.tmp2
                                cat /var/tmp/disk.tmp | awk '{ORS=","} $1 == "Product" { print $3 }' >> /var/tmp/disk.tmp2
                                cat /var/tmp/disk.tmp| awk '{ORS=","} $1 == "Serial" { print $3 }' >> /var/tmp/disk.tmp2
                                cat /var/tmp/disk.tmp | awk '{ORS=","} $1 == "Unformatted" { print $3 }' >> /var/tmp/disk.tmp2
                                cat /var/tmp/disk.tmp | awk '{ORS=","} $1 == "Device" { print $3 }' >> /var/tmp/disk.tmp2
                fi
echo >> /var/tmp/disk.tmp2
done

# re-order the output
# again, this will be different depending on the original disk device length
if [ $LENGTH == "short" ]
then
                for i in `cat /var/tmp/disk.tmp2`
                do
        echo $i | awk -F, '{ print $6 "," $2 "," $5 "," $1 "," $3 "," $4 }' >> /var/tmp/disk.tmp3
        echo >> /var/tmp/disk.tmp3
                done
else
                for i in `cat /var/tmp/disk.tmp2`
                do
        echo $i | awk -F, '{ print $7 "," $2 "," $5 "," $1 "," $3 "," $4 }' >> /var/tmp/disk.tmp3
        echo >> /var/tmp/disk.tmp3
                done
fi

# remove empty lines and sort the output file
# field order:
# LUNID,VOL NO,CAPACITY(MB),DISK_DEVICE,ARRAY_TYPE,ARRAY_SERIAL

cat /var/tmp/disk.tmp3 | sed '/^$/d' >> /var/tmp/disk.tmp4
echo "LUNID,VOL No,CAPACITY(MB),DISK_DEVICE,ARRAY_TYPE,ARRAY_SERIAL" >> /var/tmp/disk.out
sort +0 /var/tmp/disk.tmp4 >> /var/tmp/disk.out
rm -f /var/tmp/disk.tmp*
echo "contents of /var/tmp/disk.out for `uname -n`:"
cat /var/tmp/disk.out