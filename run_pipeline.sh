#!/bin/bash

logFile="logs/launch.log" # name of log file
matlab="/usr/local/bin/matlab" # matlab executable, default: /usr/local/bin/matlab

# Python pipeline - Estimation of Reff
echo " + Staring Reff estimation ..." >> $logFile
docker run -v $(pwd)/output:/covid19-reproductionNumber/output covid19
echo " + Reff estimation done." >> $logFile

# MATLAB pipeline - Estimation of Rt
echo " + Staring Rt estimation ..." >> $logFile
$matlab -nodesktop -nosplash -nodisplay -nojvm -r "run('src/rt_estimator.m'); exit();" >> $logFile
echo " + Rt estimation done." >> $logFile
echo " ----------------------------" >> $logFile
