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

if $DOCKER components/check_input.jl "$FILE"
then
	$DOCKER components/estimate_r_t.jl "$FILE" 2>&1 | log rt
	$DOCKER components/estimate_r_eff.jl "$FILE" 2>&1 | log reff
else
	echo $0: check failed >&2
	exit 1
fi 2>&1 | log check
