#!/bin/bash
DT=`date "+%m%d%H%M"`
SRCPATH="/data/"
OUTPUTPATH="/date/output/IPGET"
IPFNMTEMP=$OUTPUTPATH"/IP_FNM_Temp"_$DT
IPTEMP=$OUTPUTPATH"/IP_Tenp"_$DT
WRONGFNM=$OUTPUTPATH"/IP_WRONG_FNM"_$DT
CUTIPFILENAME=$OUTPUTPATH"/IP_CUT_Temp"_$DT
ONLYIP=$OUTPUTPATH"/IP_ONLY_Temp"_$DT
SORTONLYIP=$OUTPUTPATH"/IP_TOT"_$DT
SECONDS=0
mkdir -p "$OUTPUTPATH"
rm -rf "$OUTPUTPATH"/*
echo "$DT"
extensions=("jsp" "html" "java" "js" "xml" "sh")
duration=SECONDS
for ext in "${extensions[@]}"; do
             echo "Searching for IP addr infiles with extension .$ext ..."
             find "$SRCPATH" -type f -name "*.$ext" > $IPFNMTEMP.$ext
             while read line; do
                       if [ ! -s "$line" ]; then
                                echo "Wrong file : $line" >> $WRONGFNM
                                continue
                       fi
 
  grep -o -H -n -E "\b( [ 1-9 ] | [ 1-9 ] [ 0-9 ] |1[ 0-9 ]{2}|2[ 0-4 ] [ 0-9 ]|25[ 0-5 ])\.([ 0-9 ]{1,2}|1[ 0-9 ] {2}|2[ 0-4 ] [ 0-9] |25[ 0-5])\.( [ 0-9 ]{1,2}|1[ 0-9 ] {2}|2[ 0-4 ] [ 0-9 ] |25[ 0-5 ])\b" "$line" >> $IPTEMP.$ext
                      done < $IPFNMTEMP.$ext
  grep -o -E "\b([ 1-9 ] | [ 1-9 ] [ 0-9] | 1[ 0-9 ]{2}|2[ 0-4 ] [ 0-9] |25[ 0-5 ])\.([ 0-9]{1,2}|1[0-9]{2}|2[ 0-4 ][ 0-9 ]|25[ 0-5 ])\.( [ 0-9 ] {1,2}|1[ 0-9 ]{2}|2[ 0-4 ][ 0-9 ]|25[ 0-5 ])\.([ 0-9 ]{1,2}|1[ 0-9 ]{2}|2[ 0-4 ][ 0-9 ]|25[ 0-5 ])\b" $IPTEMP.$ext > $ONLYIP.$ext
 sort -u $ONLYIP.$ext > $SORTONLYIP.$ext
done
duration=$SECONDS
echo "Duration Time !!!"
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds."