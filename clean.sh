#!/bin/bash

logFileDir='logs'
resultDir='output'

# remove all the results
rm -rf $resultDir/*
echo " > Result files cleaned"

# remove all the logs
rm -rf $logFileDir/*
echo " > log files cleaned"

echo " > All files cleaned"