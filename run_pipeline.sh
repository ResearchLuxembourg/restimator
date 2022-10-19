#!/bin/bash

. /etc/profile

FILE=`find input/ -name '*.xlsx' -type f`
[ -f "$FILE" ] || {
	echo $0: expected a single .xlsx file in input directory >&2
	exit 1
}

log () {
	mkdir -p logs/
	tee "logs/$1-`basename \"$FILE\"`.log"
}

echo "found $FILE" | log find_input

IMAGE=ghcr.io/researchluxembourg/restimator
MOUNT="-v $PWD/input:/tool/input -v $PWD/output:/tool/output -v $PWD/logs:/tool/logs "
DOCKER="docker run --rm $MOUNT $IMAGE julia --project "

mkdir -p output logs
export RESTIMATOR_OUTDIR=output

$DOCKER components/check_input.jl "$FILE" 2>&1 | log check
if [ ${PIPESTATUS[0]} -eq 0 ]
then
	st=0
	$DOCKER components/estimate_r_t.jl "$FILE" 2>&1 | log rt
	[ ${PIPESTATUS[0]} -eq 0 ] || st=1
	$DOCKER components/estimate_r_eff.jl "$FILE" 2>&1 | log reff
	[ ${PIPESTATUS[0]} -eq 0 ] || st=1
	exit $st
else
	echo $0: check failed >&2
	exit 1
fi
