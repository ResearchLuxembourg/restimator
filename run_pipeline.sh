#!/bin/bash

. /etc/profile

FILE=`find input/ -type f`
[ -f "$FILE" ] || {
	echo $0: could not find any input >&2
	exit 1
}

log () {
	mkdir -p logs/
	tee "logs/$1-`basename \"$FILE\"`"
}

IMAGE=researchluxembourg/covid-reproduction-number
MOUNT="-v $PWD/input:/tool/input -v $PWD/output:/tool/output"
DOCKER="docker run --rm $MOUNT $IMAGE julia"

mkdir -p output
export RESTIMATOR_OUTDIR=output

if $DOCKER check_input.jl /"$FILE" | log check
then
	$DOCKER estimate_r_t.jl "$FILE" | log rt
	$DOCKER estimate_r_eff.jl "$FILE" | log reff
else
	echo $0: check failed >&2
	exit 1
fi
