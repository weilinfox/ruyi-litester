#!/bin/bash

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
CASE_NAME=()
LOG_DIR="$RIT_RUN_PATH"/mugen_log

for ((i=0;i<$CASE_LEN;i++)); do
	case_name="$(jq --raw-output ".cases | .[$i].name" "$RIT_CASE_PATH/$SUITE/$SUITE.json")"

	if [ -n "$CASE" ] && [[ "$case_name" != "$CASE" ]]; then
		continue
	fi

	if [ -n "$MATCH" ] && ! EXPR_MATCH "$case_name" $MATCH; then
		LOG_INFO "Filter testcase $case_name."
		continue
	fi

	if [ -f "$RIT_CASE_PATH/$SUITE/$case_name.sh" ]; then
		case_path="$RIT_CASE_PATH/$SUITE/$case_name.sh"
	elif [ -f "$RIT_CASE_PATH/$SUITE/$case_name/$case_name.sh" ]; then
		case_path="$RIT_CASE_PATH/$SUITE/$case_name/$case_name.sh"
	else
		LOG_WARN "Testcase of suite $SUITE not found: $case_name."
		LOG_INFO "Skip testcase $case_name."
		continue
	fi
	CASE_NAME[${#CASE_NAME[@]}]="$case_name"
	CASE_PATH[${#CASE_PATH[@]}]="$case_path"
done

CASE_LEN="${#CASE_PATH[@]}"
if [ "$CASE_LEN" -lt 1 ]; then
	LOG_ERROR "No mugen testcases configured."
	exit 1
fi

CASE_SUCCESS=0
CASE_FAILURE=0
CASE_TIMEOUT=0

function exec_case() {
	local case_path="$2"
	local timeout="$(grep -E '^EXECUTE_T=[0-9]+[msh]$' "$2" | tail -n1 | cut -d'=' -f2)"
	local cmd="bash "
	local log_path="$LOG_DIR/$SUITE/$1"

	if [ -n "$XRUN" ]; then
		cmd="$cmd -x"
	fi

	mkdir -p "$log_path"

	exec 4>&1 5>&2
	exec > "$log_path/$(date +%Y-%m-%d-%T).log" 2>&1

	SLEEP_WAIT "${timeout:-15m}" "$cmd $case_path"

	local code="$?"

	exec 1>&4 2>&5
	exec 4>&- 5>&-

	if [ "$code" -eq 0 ]; then
		LOG_INFO "The case exit by code 0."
		((CASE_SUCCESS++))
	elif [ "$code" -eq 124 ]; then
		LOG_WARN "The case execution timeout."
		LOG_ERROR "The case exit by code 124."
		((CASE_TIMEOUT++))
	else
		LOG_ERROR "The case exit by code $code."
		((CASE_FAILURE++))
	fi
}

function test_all() {
	for ((i=0;i<$CASE_LEN;i++)); do
		LOG_INFO "start to run testcase:${CASE_NAME[$i]}."
		exec_case "${CASE_NAME[$i]}" "${CASE_PATH[$i]}"
		LOG_INFO "End to run testcase:${CASE_NAME[$i]}."
	done

	LOG_INFO "A total of $CASE_LEN use cases were executed, with $CASE_SUCCESS successes and $((CASE_TIMEOUT+CASE_FAILURE)) failures."
}

mkdir -p "$LOG_DIR"
mkdir -p "$LOG_DIR/$SUITE"
test_all 2>&1 | tee --append "$LOG_DIR/$SUITE/exec.log"

exit $((CASE_TIMEOUT+CASE_FAILURE))

