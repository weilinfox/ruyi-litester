#!/bin/bash

set -e

SELF_VERSION=0.0.1
SOURCE_PATH="$(dirname $(realpath $0))"
RUN_PATH="$(realpath .)"
SCRIPT_PATH="$SOURCE_PATH"/scripts
SUITE_PATH="$SOURCE_PATH"/suites
CASE_PATH="$SOURCE_PATH"/testcases

suite_name=
profile_name=

function show_help() {
	echo "Usage: rit.bash [-p profile] suite"
	echo
	echo "Options:"
	echo "    -h, --help       Show this help message"
	echo "    -v, --version    Show version information"
	echo "    -p, --profile    Specify a profile (use suite name as default)"
	echo
}

function show_version() {
	echo "Ruyi Lit Tester"
	echo "Version: $SELF_VERSION"
}

function fatal_exit() {
	echo "Fatal: $1"
	exit 255
}

function parse_script_matrix() {
	# yaml/json content
	local ctt="$1"
	# dest list variable
	local dest="$2"
	local ctt_len="$(echo $ctt | yq --raw-output length)"

	[ "$ctt_len" -lt 1 ] && return
	for ((i=0; i<$ctt_len; i++)); do
		local tmp_ctt="$(echo $ctt | yq --raw-output .[$i])"
		local tmp_len="$(echo $tmp_ctt | yq --raw-output length)"
		local tmp_list=

		for ((j=0; j<$tmp_len; j++)); do
			tmp_list="$tmp_list $(echo $tmp_ctt | yq --raw-output .[$j])"
		done
		tmp_list="${tmp_list:1}"

		eval "$dest"'[${#'"$dest"'[@]}]="'"$tmp_list"'"'
	done
}

function script_test() {
	[ -x "$SCRIPT_PATH"/"$1".bash ] || fatal_exit "script not found $1.bash"
}

function script_run() {
	"$SCRIPT_PATH"/"$1".bash
}

if [[ "$#" -eq 0 ]]; then
	show_help
	exit 1
fi

while [[ "$#" -gt 0 ]]; do
	case $1 in
		-h|--help)
			show_help
			exit 0
			;;
		-v|--version)
			show_version
			exit 0
			;;
		-p|--profile)
			if [[ -n "$2" ]]; then
				profile_name="$2"
				shift
			else
				fatal_exit "--profile requires an argument."
			fi
			;;
		*)
			suite_name="$1"
			;;
	esac
	shift
done

[[ "$#" -gt 0 ]] && fatal_exit "too much arguments"
[[ -z "$suite_name" ]] && fatal_exit "missing argument <suite>"
[[ -z "${profile_name:=$suite_name}" ]] && fatal_exit "missing profile name"

# Check testsuite files
[[ -d "$CASE_PATH"/"$suite_name" ]] || fatal_exit "missing testcase directory"
[[ -f "$SUITE_PATH"/"$suite_name".yaml ]] || fatal_exit "missing testsuite yaml profile"

# parse profile
suite_profiles="$(yq --raw-output ."$profile_name" "$SUITE_PATH"/"$suite_name".yaml)"
[[ "$suite_profiles" == "null" ]] && fatal_exit "no such suite profile found \"$profile_name\""

pre_scripts=()
post_scripts=()

parse_script_matrix "$(echo $suite_profiles | yq --raw-output .pre)" pre_scripts
parse_script_matrix "$(echo $suite_profiles | yq --raw-output .post)" post_scripts

# test scripts
for ((i=0; i<${#pre_scripts[@]}; i++)); do
	for s in ${pre_scripts[$i]}; do
		script_test "$s"
	done
done
for ((i=0; i<${#post_scripts[@]}; i++)); do
	for s in ${post_scripts[$i]}; do
		script_test "$s"
	done
done

# TODO: multi-dimensional test

# run pre scripts
for ((i=0; i<${#pre_scripts[@]}; i++)); do
	script_run "${pre_scripts[i]}"
done

LOG_DATE="$(date '+%Y%m%d-%H%M%S')"
lit "${CASE_PATH}"/"$suite_name" 2>&1 | tee "$RUN_PATH"/"$suite_name"_"$profile_name"_"$LOG_DATE".log

# run post scripts
for ((i=0; i<${#post_scripts[@]}; i++)); do
	script_run "${post_scripts[i]}"
done

