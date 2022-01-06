# logs and result directories
logFileDir := logs
resultDir := output

# tag of docker image
tag := covid19

# name of log file
logFile :='logs/launch.log'

current_dir = $(shell pwd)
# name of mounted directory in Dockerfile
mountDir := 'covid19-reproductionNumber'

# matlab executable, default: /usr/local/bin/matlab
matlab_cmd := ''

# working cmd
#docker run -it -v $(pwd)/input:/home/matlab/covid19-reproductionNumber/input -v $(pwd)/output:/home/matlab/covid19-reproductionNumber/output -v ${MATLAB_LICENSE}:/license.dat --rm -e MLM_LICENSE_FILE=/license.dat --shm-size=512M mymatlab matlab -r "run('src/rt_estimator.m'); exit();"

.PHONY: default run build

all: clean build run

build:
	$(info Make: Building "$(tag)" tagged images.)
	@docker build -t ${tag} .

run: reff rt

reff:
	@echo " + Staring Reff estimation ..." >> ${logFile}
	@docker run -v $(current_dir)/output:/${mountDir}/output -v $(current_dir)/input:/${mountDir}/input ${tag}
	@echo " + Reff estimation done." >> ${logFile}

rt:
	@echo " + Staring Rt estimation ..." >> ${logFile}
	docker run -it -v $(current_dir)/output:/home/matlab/covid19-reproductionNumber/output -v $(current_dir)/input:/home/matlab/covid19-reproductionNumber/input -v ${MATLAB_LICENSE}:/license.dat --rm -e MLM_LICENSE_FILE=/license.dat --shm-size=512M mymatlab matlab -r "run('src/rt_estimator.m'); exit();" >> ${logFile}
	@echo " + Rt estimation done." >> ${logFile}
	@echo " ----------------------------" >> ${logFile}

clean:
	@rm -rf ${resultDir}/*.pdf
	@rm -rf ${resultDir}/*.csv
	@echo " > Result files cleaned"
	@rm -rf ${logFileDir}/*.log
	@echo " > log files cleaned"
	@echo " > All files cleaned"