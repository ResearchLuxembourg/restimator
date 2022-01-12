# logs and result directories
logFileDir := logs
resultDir := output

# tag of docker image
tag_check := covid19-check
tag_reff := covid19-reff
tag_rt := covid19-rt

# commands
cmd_check := python src/checkfile.py
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

build: build_check build_reff build_rt

run: check reff rt

# build the containers
build_check:
	@echo " [$$(date +%FT%T%z)] + Starting building container for check ..." >> ${logFile}
	@cd components/check/ && docker build -t ${tag_check} .
	@echo " [$$(date +%FT%T%z)] + Container for check generated." >> ${logFile}

build_reff:
	@echo " [$$(date +%FT%T%z)] + Starting building container for Reff ..." >> ${logFile}
	@cd components/reff/ && docker build -t ${tag_reff} .
	@echo " [$$(date +%FT%T%z)] + Container for Reff generated." >> ${logFile}

build_rt:
	@echo " [$$(date +%FT%T%z)] + Starting building container for Rt ..." >> ${logFile}
	@cd components/rt/ && docker build -t ${tag_rt} .
	@echo " [$$(date +%FT%T%z)] + Container for Rt generated." >> ${logFile}

check:
	@echo " [$$(date +%FT%T%z)] + Starting check ..." >> ${logFile}
	@docker run -v $(current_dir)/input:/${mountDir}/input ${tag_check} ${cmd_check} >> ${logFile}
	@echo " [$$(date +%FT%T%z)] + Check done." >> ${logFile}

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