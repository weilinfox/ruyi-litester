#!/bin/bash

RIT_MUGEN_ERROR_COUNT=0

if [ -z "$RIT_DRIVER_PATH" ]; then
	echo "Empty RIT_DRIVER_PATH environment variable!"
	exit -1
fi
if [ -z "$RIT_RUN_PATH" ]; then
	echo "Empty RIT_RUN_PATH environment variable!"
	exit -1
fi

source "${RIT_DRIVER_PATH}"/utils/mugen_libs.bash

if [ -z "$RIT_CASE_PATH" ] || [ ! -d "$RIT_CASE_PATH" ] ; then
	LOG_ERROR "Unreachable RIT_CASE_PATH"
	exit -1
fi

function show_help() {
	echo "Usage:"
	echo "    -f: designated test suite"
	echo "    -r: designated test case"
	echo "    -x: the shell script is executed in debug mode"
	echo "    -m: --match"
	echo
}

if [[ "$#" -eq 0 ]]; then
	show_help
	exit 1
fi

SUITE=
CASE=
XRUN=
MATCH=

while getopts "f:r:xm:" OPTION; do
	case $OPTION in
		f)
			SUITE=$OPTARG
			;;
		r)
			CASE=$OPTARG
			;;
		x)
			XRUN=x
			;;
		m)
			MATCH="$OPTARG"
			;;
		*)

			show_help
			exit 1
			;;
	esac
done

echo $SUITE $CASE $XRUN "$MATCH"

if [ -z "$RIT_SUDO" ]; then
	LOG_WARN "We recommend to run mugen testcases with rit -s or --sudo"
fi

if [ -z "$SUITE" ]; then
	LOG_ERROR "No suite configured."
	exit 1
elif [ ! -f "$RIT_CASE_PATH/$SUITE/$SUITE.json" ]; then
	LOG_ERROR "No mugen suite configure file $SUITE.json found."
	exit 1
fi

CASE_LEN="$(jq --raw-output '.cases | length' "$RIT_CASE_PATH/$SUITE/$SUITE.json")"
CASE_PATH=()
LOG_DIR="$RIT_RUN_PATH"/mugen_log

for ((i=0;i<$CASE_LEN;i++)); do
	CASE_NAME="$(jq --raw-output ".cases.[$i].name" "$RIT_CASE_PATH/$SUITE/$SUITE.json")"

	if [ -n "$CASE" ] && [[ "$CASE_NAME" != "$CASE" ]]; then
		continue
	fi

	if [ -n "$MATCH" ] && ! EXPR_MATCH "$CASE_NAME" $MATCH; then
		LOG_INFO "Filter testcase $CASE_NAME."
		continue
	fi

	if [ -f "$RIT_CASE_PATH/$SUITE/$CASE_NAME.sh" ]; then
		CASE_P="$RIT_CASE_PATH/$SUITE/$CASE_NAME.sh"
	elif [ -f "$RIT_CASE_PATH/$SUITE/$CASE_NAME/$CASE_NAME.sh" ]; then
		CASE_P="$RIT_CASE_PATH/$SUITE/$CASE_NAME/$CASE_NAME.sh"
	else
		LOG_WARN "Testcase of suite $SUITE not found: $CASE_NAME."
		LOG_INFO "Skip testcase $CASE_NAME."
		continue
	fi
	CASE_PATH[${#CASE_PATH[@]}]="$CASE_P"
done

CASE_LEN="${#CASE_PATH[@]}"
if [ "$CASE_LEN" -lt 1 ]; then
	LOG_ERROR "No mugen testcases configured."
	exit 1
fi

mkdir -p "$LOG_DIR"

