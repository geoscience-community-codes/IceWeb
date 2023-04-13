#!/usr/bin/tcsh
################################################################################################
# called by a cronjob once an hour
# grab hourly weather reports from remote ftp server
# Data from the National Weather Service's
# Interactive Weather Information Network (IWIN)
################################################################################################

set WIND_DATA=$HOME/DATA/WIND
set WIND_CODE=$HOME/WIND_CODE

# get weather data from remote ftp site
ftp -inv iwin.nws.noaa.gov << EOF
user anonymous guy@giseis.alaska.edu
ascii
lcd $WIND_DATA
cd data/text/abak32
get PANC.TXT 
quit
EOF

# Get rid of the ^M character from the PC generated ascii file.
dos2unix ${WIND_DATA}/PANC.TXT > ${WIND_DATA}/temp.txt
mv ${WIND_DATA}/temp.txt ${WIND_DATA}/PANC.TXT

# note - sometimes ftp does not get connected in time
# so PANC.TXT stays the same, and data is repeated
# need to put in checking for this
  
# the Cold Bay wx data
grep PACD ${WIND_DATA}/PANC.TXT | cut -c49-52 > ${WIND_DATA}/cbwind

# the Dutch Harbor wx data
grep PADU ${WIND_DATA}/PANC.TXT | cut -c49-52 > ${WIND_DATA}/dhwind

# the King Salmon wx data
grep PAKN ${WIND_DATA}/PANC.TXT | cut -c49-52 > ${WIND_DATA}/kswind

# the Homer wx data
grep PAHO ${WIND_DATA}/PANC.TXT | cut -c49-52 > ${WIND_DATA}/howind

# the Iliamna wx data
grep PAIL ${WIND_DATA}/PANC.TXT | cut -c49-52 > ${WIND_DATA}/ilwind
                              
# the Glennallen wx data
grep PAGK ${WIND_DATA}/PANC.TXT | cut -c49-52 > ${WIND_DATA}/gkwind
                              
# the time record
#grep 199  ${WIND_DATA}/PANC.TXT | cut -c1-27 > ${WIND_DATA}/wxt	
#grep 200  ${WIND_DATA}/PANC.TXT | cut -c1-27 > ${WIND_DATA}/wxt	
cat ${WIND_DATA}/PANC.TXT | head -5 | tail -1 > ${WIND_DATA}/wxt


paste ${WIND_DATA}/wxt ${WIND_DATA}/cbwind > ${WIND_DATA}/cbwind.tmp
paste ${WIND_DATA}/wxt ${WIND_DATA}/dhwind > ${WIND_DATA}/dhwind.tmp
paste ${WIND_DATA}/wxt ${WIND_DATA}/kswind > ${WIND_DATA}/kswind.tmp
paste ${WIND_DATA}/wxt ${WIND_DATA}/howind > ${WIND_DATA}/howind.tmp
paste ${WIND_DATA}/wxt ${WIND_DATA}/ilwind > ${WIND_DATA}/ilwind.tmp
paste ${WIND_DATA}/wxt ${WIND_DATA}/gkwind > ${WIND_DATA}/gkwind.tmp

#rm ${WIND_DATA}/{wxt,cbwind,PANC.TXT,dhwind,kswind,howind,ilwind,gkwind}

# get weather data from buoys for Augustine and Redoubt
ftp -inv www.ndbc.noaa.gov << EOF2
user anonymous guy@giseis.alaska.edu
ascii
lcd $WIND_DATA
cd data/realtime
get AUGA2.txt
get DRFA2.txt
quit
EOF2

set AUGline = `cat ${WIND_DATA}/AUGA2.txt | head -2 | tail -1`
# Get wind velocity in m/s...
set AUGwind = `echo $AUGline | cut -d' ' -f6`
# Convert to MPH...
@ windU = ($AUGwind:r * 2237)
@ windD = ($AUGwind:e * 224)
@ wind = ($windU + $windD)
@ wind1 = ($wind / 1000)
@ wind2 = ($wind % 1000)
set wind = ${wind1}"."${wind2}
set AUGyr = `echo $AUGline | cut -d' ' -f1`
set AUGmo = `echo $AUGline | cut -d' ' -f2`
set AUGdy = `echo $AUGline | cut -d' ' -f3`
set AUGhr = `echo $AUGline | cut -d' ' -f4`
echo ${AUGhr}00 AmPm zone day month ${AUGdy} ${AUGyr}	NSEW${wind} > ${WIND_DATA}/auwind.tmp

set DRFline = `cat ${WIND_DATA}/DRFA2.txt | head -2 | tail -1`
# Get wind velocity in m/s...
set DRFwind = `echo $DRFline | cut -d' ' -f6`
# Convert to MPH...
@ windU = ($DRFwind:r * 2237)
@ windD = ($DRFwind:e * 224)
@ wind = ($windU + $windD)
@ wind1 = ($wind / 1000)
@ wind2 = ($wind % 1000)
set wind = ${wind1}"."${wind2}
set DRFyr = `echo $DRFline | cut -d' ' -f1`
set DRFmo = `echo $DRFline | cut -d' ' -f2`
set DRFdy = `echo $DRFline | cut -d' ' -f3`
set DRFhr = `echo $DRFline | cut -d' ' -f4`
echo ${DRFhr}00 AmPm zone day month ${DRFdy} ${DRFyr}	NSEW${wind} > ${WIND_DATA}/rewind.tmp

$WIND_CODE/convertwind.pl
