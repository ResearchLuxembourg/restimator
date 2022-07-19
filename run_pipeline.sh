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

IMAGE=researchluxembourg/restimator
MOUNT="-v $PWD/input:/tool/input -v $PWD/output:/tool/output -v $PWD/logs:/tool/logs "
DOCKER="docker run --rm $MOUNT $IMAGE julia --project "

mkdir -p output logs
export RESTIMATOR_OUTDIR=output

if $DOCKER check_input.jl "$FILE" | log check
then
	$DOCKER estimate_r_t.jl "$FILE" | log rt
	$DOCKER estimate_r_eff.jl "$FILE" | log reff
else
	echo $0: check failed >&2
	exit 1
fi
