# logs and result directories
logFileDir := logs
resultDir := output

# tag of docker image
tag := covid19

# name of log file
logFile :='logs/launch.log'

# matlab executable, default: /usr/local/bin/matlab
matlab := '/usr/local/bin/matlab'

# name of mounted directory in Dockerfile
mountDir := 'covid19-reproductionNumber'

current_dir = $(shell pwd)

.PHONY: default run build

all: clean build run

build:
	$(info Make: Building "$(tag)" tagged images.)
	@docker build -t ${tag} .

run: reff rt

reff:
	@echo " + Staring Reff estimation ..." >> ${logFile}
	@docker run -v $(current_dir)/output:/${mountDir}/output ${tag}
	@echo " + Reff estimation done." >> ${logFile}

rt:
	@echo " + Staring Rt estimation ..." >> ${logFile}
	@${matlab} -nodesktop -nosplash -nodisplay -nojvm -r "run('src/rt_estimator.m'); exit();" >> ${logFile}
	@echo " + Rt estimation done." >> ${logFile}
	@echo " ----------------------------" >> ${logFile}

clean:
	@rm -rf ${resultDir}/*.pdf
	@rm -rf ${resultDir}/*.csv
	@echo " > Result files cleaned"
	@rm -rf ${logFileDir}/*.log
	@echo " > log files cleaned"
	@echo " > All files cleaned"