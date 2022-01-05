#!/bin/bash
logFile="logs/launch.log"                # name of log file
matlab="/Applications/MATLAB_R2019b.app/bin/matlab"

echo " + Staring Reff estimation ..." >> $logFile
python src/reff_estimator.py
echo " + Reff estimation done." >> $logFile
echo " + Staring Rt estimation ..." >> $logFile
$matlab -nodesktop -nosplash -nodisplay -nojvm -r "run('src/rt_estimator.m'); exit();" >> $logFile
echo " + Rt estimation done." >> $logFile

