#!/bin/bash
#
#

MY_PATH="`dirname \"$0\"`"

# usual ddos country
BADCONTRYLIST="cn China ch1 in India in1 th Thailand th1 vn Vietnam vn1 hk HonkKong hk1 ro Romania ro1 eg Egypt eg1 id Indonesia id1"
# type 
# blackhole need #sysctl rp_filter=1
TYPE="blk blackholeRoute list LISTips iptab iptables "

####

if [ ! -f ${MY_PATH}/jq ] ;then 
URL_JQ32="https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux32"
URL_JQ64="https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"

MACHINE_TYPE=`uname -m`
#1
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  wget -O ${MY_PATH}/jq "${URL_JQ64}" 
else
  wget -O ${MY_PATH}/jq "${URL_JQ32}" 
fi
#-1
chmod a+x ${MY_PATH}/jq


fi 

if [ "ELF" != `file ${MY_PATH}/jq |grep -o "ELF"` ] ;then
echo not ELF / some is wrong on "${MY_PATH}/jq" parser ;
exit 1
fi
####


SCOUNTRY=$(dialog --stdout --title "list" --cancel-label "new" --checklist "select list:" 15 55 5 ${BADCONTRYLIST} )
STYPE=$(dialog --stdout --title "list" --cancel-label "new" --menu "select type:" 15 55 5 ${TYPE} )

if [ -z ${SCOUNTRY// /} ] ;then 
echo emptyset
exit 2
fi


for icountry in ${SCOUNTRY} ; do 
icountry=${icountry//\"/}
## type1 USE blackhole 
#
if [ "blk" == ${STYPE} ];then 
wget -O -  "https://stat.ripe.net/data/country-resource-list/data.json?resource=${icountry}&v4_format=prefix" | ${MY_PATH}/jq '."data"."resources"."ipv4"[]' 2>&1 | xargs -l1 ip ro add blackhole 

fi 

## type2 USE raw list
#
if [ "list" == ${STYPE} ];then 
wget -O -  "https://stat.ripe.net/data/country-resource-list/data.json?resource=${icountry}&v4_format=prefix" | ${MY_PATH}/jq '."data"."resources"."ipv4"[]' 2>&1 | xargs -l1 echo 

fi 

## type3 USE iptables 
#
if [ "iptab" == ${STYPE} ];then 
iptables -N ban_${icountry}
LIST2=`wget -O -  "https://stat.ripe.net/data/country-resource-list/data.json?resource=${icountry}&v4_format=prefix" | ${MY_PATH}/jq '."data"."resources"."ipv4"[]' 2>&1 `
for IPS2 in ${LIST2};do 
iptables -A ban_${icountry} -s ${IPS2//\"/} -j DROP 
done

iptables -I INPUT -j ban_${icountry}

fi 



done 
