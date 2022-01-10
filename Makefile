# logs and result directories
logFileDir := logs
resultDir := output

# tag of docker image
tag_reff := covid-19_reproductionnumber_reff
tag_rt := covid-19_reproductionnumber_rt

# commands
cmd_reff := python src/reff_estimator.py
cmd_rt := matlab -r "run('src/rt_estimator.m'); exit();"

datestamp := $(date +%FT%T%z)

# name of log file
logFile :='logs/launch.log'

current_dir = $(shell pwd)

# name of mounted directory in Dockerfile
mountDir := 'covid19-reproductionNumber'

# definitions
.PHONY: default run build

all: clean build run

build: build_reff build_rt

run: reff rt

# build the container for Reff
build_reff:
	@echo " [$$(date +%FT%T%z)] + Starting building container for Reff ..." >> ${logFile}
	@cd components/reff/ && docker build -t ${tag_reff} .
	@echo " [$$(date +%FT%T%z)] + Container for Reff generated." >> ${logFile}

build_rt:
	@echo " [$$(date +%FT%T%z)] + Starting building container for Rt ..." >> ${logFile}
	@cd components/rt/ && docker build -t ${tag_rt} .
	@echo " [$$(date +%FT%T%z)] + Container for Rt generated." >> ${logFile}

reff:
	@echo " [$$(date +%FT%T%z)] + Starting Reff estimation ..." >> ${logFile}
	@docker run -v $(current_dir)/output:/${mountDir}/output -v $(current_dir)/input:/${mountDir}/input ${tag_reff} ${cmd_reff} >> ${logFile}
	@echo " [$$(date +%FT%T%z)] + Reff estimation done." >> ${logFile}

rt:
	@echo " [$$(date +%FT%T%z)] + Starting Rt estimation ..." >> ${logFile}
	@docker run -it -v $(current_dir)/output:/home/matlab/covid19-reproductionNumber/output -v $(current_dir)/input:/home/matlab/covid19-reproductionNumber/input -v ${MATLAB_LICENSE}:/license.dat --rm -e MLM_LICENSE_FILE=/license.dat --shm-size=512M ${tag_rt} ${cmd_rt} >> ${logFile}
	@echo " [$$(date +%FT%T%z)] + Rt estimation done." >> ${logFile}

clean:
	@rm -rf ${resultDir}/*.pdf
	@rm -rf ${resultDir}/*.csv
	@rm -rf ${logFileDir}/*.log
	@echo " [$$(date +%FT%T%z)] + All files cleaned" >> ${logFile}