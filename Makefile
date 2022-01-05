logFileDir := 'logs' # name of directory for logging
resultDir := 'output' # name of output directory
tag := 'covid19' # tag of docker image

logFile :='${logFileDir}/launch.log' # name of log file
matlab := '/usr/local/bin/matlab' # matlab executable, default: /usr/local/bin/matlab
mountDir := 'covid19-reproductionNumber' # name of mounted directory in Dockerfile

current_dir = $(shell pwd)

.PHONY: default run build

all: clean build

build:
	$(info Make: Building "$(tag)" tagged images.)
	@docker build -t ${tag} .
	@make -s tag
	@make -s clean

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
	@rm -rf ${resultDir}/*
	@echo " > Result files cleaned"
	@rm -rf ${logFileDir}/*
	@echo " > log files cleaned"
	@echo " > All files cleaned"