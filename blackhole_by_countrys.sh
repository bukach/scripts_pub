#!/bin/bash


BADCONTRYLIST="cn China ch1 in India in1 th Thailand th1 vn Vietnam vn1 hk HonkKong hk1"
TYPE="blk blackholeRoute list LISTips iptab iptables "


SCOUNTRY=$(dialog --stdout --title "list" --cancel-label "new" --checklist "select list:" 15 55 5 ${BADCONTRYLIST} )
STYPE=$(dialog --stdout --title "list" --cancel-label "new" --menu "select type:" 15 55 5 ${TYPE} )

if [ -z ${SCOUNTRY} ] ;then 
 echo kk
fi


for icountry in ${SCOUNTRY} ; do 

  ## type1 USE blackhole 
  #
  if [ "blk" == ${STYPE} ];then 
     wget -O -  "https://stat.ripe.net/data/country-resource-list/data.json?resource=${icountry}&v4_format=prefix" | ./jq '."data"."resources"."ipv4"[]' 2>&1 | xargs -l1 ip ro add blackhole 
  
  fi 
  
  ## type2 USE raw list
  #
  if [ "list" == ${STYPE} ];then 
     wget -O -  "https://stat.ripe.net/data/country-resource-list/data.json?resource=${icountry}&v4_format=prefix" | ./jq '."data"."resources"."ipv4"[]' 2>&1 | xargs -l1 echo 
  
  fi 
  
  ## type3 USE iptables 
  #
  if [ "iptab" == ${STYPE} ];then 
     iptables -N ban_${icountry}
     LIST2=`wget -O -  "https://stat.ripe.net/data/country-resource-list/data.json?resource=${icountry}&v4_format=prefix" | ./jq '."data"."resources"."ipv4"[]' 2>&1 `
     for IPS2 in ${LIST2};do 
       iptables -A ban_${icountry} -s ${IPS2} -j DROP 
     done
  
    iptables -I INPUT -j ban_${icountry}

fi 



done 
