#!/bin/bash

RIT_MUGEN_ERROR_COUNT=0

if [ -z "$RIT_DRIVER_PATH" ]; then
	echo "Empty RIT_DRIVER_PATH environment variable!"
	exit -1
fi

source "${RIT_DRIVER_PATH}"/utils/mugen_libs.bash

if [ -z "$RIT_CASE_PATH" ] || [ ! -d "$RIT_CASE_PATH" ] ; then
	LOG_ERROR "Unreachable RIT_CASE_PATH"
	exit -1
fi

if [ -z "$RIT_SUDO" ]; then
	LOG_WARN "We recommend to run mugen testcases with rit -s or --sudo"
fi

function show_help() {
	echo "Usage:"
	echo "    -f: designated test suite"
	echo "    -r: designated test case"
	echo "    -x: the shell script is executed in debug mode"
	echo
}
