logFileDir := 'logs'
resultDir := 'output'
tag := 'covid19'

.PHONY: default run build

all: clean build

build:
	$(info Make: Building "$(tag)" tagged images.)
	@docker build -t ${tag} .
	@make -s tag
	@make -s clean

run:
	@sh run_pipeline.sh

clean:
	@rm -rf ${resultDir}/*
	@echo " > Result files cleaned"
	@rm -rf ${logFileDir}/*
	@echo " > log files cleaned"
	@echo " > All files cleaned"