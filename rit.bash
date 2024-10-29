#!/bin/bash

set -e

SELF_VERSION=0.0.1
SOURCE_PATH="$(dirname $(realpath $0))"
RUN_PATH="$(realpath .)"
DRIVER_PATH="$SOURCE_PATH"/driver
SCRIPT_PATH="$SOURCE_PATH"/scripts
SUITE_PATH="$SOURCE_PATH"/suites
CASE_PATH="$SOURCE_PATH"/testcases
ENV_PATH="$SOURCE_PATH"/rit.bash_env
LOCK_FILE="$SOURCE_PATH"/.rit.bash.lock

LOG_DATE="$(date '+%Y%m%d-%H%M%S')"

if [ -e "$LOCK_FILE" ]; then
	echo "Find lock file $LOCK_FILE"
	echo "exit now..."
	exit 2
fi

touch "$LOCK_FILE"
rm -rf "$ENV_PATH"
mkdir -p "$ENV_PATH"

. "$DRIVER_PATH"/utils/logging.bash

suite_name=
profile_name=

function show_help() {
	echo "Usage: rit.bash [options] suite"
	echo
	echo "Options:"
	echo "    -h, --help       Show this help message"
	echo "    -v, --version    Show version information"
	echo "    -p, --profile    Specify a profile (use suite name as default)"
	echo "    --scripts        Specify foreign script path"
	echo "    --suites         Specify foreign test suite path (to search yaml profiles)"
	echo "    --testcases      Specify foreign testcases path"
	echo "    -x, --debug      Debug bash scripts"
	echo "    -e               Run without -e shopt option (not recommend)"
	echo
}

function show_version() {
	echo "Ruyi Lit Tester"
	echo "Version: $SELF_VERSION"
}

function code_exit() {

	rm -rf "$ENV_PATH"
	rm -f "$LOCK_FILE"

	exit $1
}

function fatal_exit() {
	LOG_FATAL "$@"

	code_exit 255
}

function script_test() {
	[[ "$1" == "_" ]] && return 0
	[ -z "$1" ] && fatal_exit "empty script name"

	[ -x "$SCRIPT_PATH"/"$1".bash ] || fatal_exit "script not found $1.bash"
}

function script_run() {
	[[ "$1" == "_" ]] && return 0
	[ -z "$1" ] && fatal_exit "empty script name"

	"$SCRIPT_PATH"/"$1".bash
}

function env_create() {
	LOG_DEBUG fake env_create
}

function env_destroy() {
	LOG_DEBUG fake env_destroy
}

if [[ "$#" -eq 0 ]]; then
	show_help
	code_exit 1
fi

while [[ "$#" -gt 0 ]]; do
	case $1 in
		-h|--help)
			show_help
			code_exit 0
			;;
		-v|--version)
			show_version
			code_exit 0
			;;
		-p|--profile)
			if [[ -n "$2" ]]; then
				profile_name="$2"
				shift
			else
				fatal_exit "$1 requires an argument."
			fi
			;;
		--scripts)
			if [[ -n "$2" ]]; then
				SCRIPT_PATH="$2"
				shift
			else
				fatal_exit "--scripts requires an argument."
			fi
			;;
		--suites)
			if [[ -n "$2" ]]; then
				SUITE_PATH="$2"
				shift
			else
				fatal_exit "--suites requires an argument."
			fi
			;;
		--testcases)
			if [[ -n "$2" ]]; then
				CASE_PATH="$2"
				shift
			else
				fatal_exit "--testcases requires an argument."
			fi
			;;
		-x|--debug)
			set -x
			;;
		-e)
			set +e
			;;
		-*|--*)
			fatal_exit "unsupported argument $1"
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
[[ -f "$SUITE_PATH"/"$suite_name".yaml ]] || fatal_exit "missing testsuite yaml profile"

# parse testcases
case_profiles="$(yq --raw-output .\"$profile_name\".cases "$SUITE_PATH"/"$suite_name".yaml)"
case_dirs=()
case_len="$(echo $case_profiles | yq --raw-output length)"
for ((i=0; i<$case_len; i++)); do
	tmp_case="$(echo $case_profiles | yq --raw-output .[$i])"
	[[ -d "$CASE_PATH"/"$tmp_case" ]] || fatal_exit "missing testcase directory \"$tmp_case\""
	[[ -f "$CASE_PATH"/"$tmp_case"/rit.yaml ]] || fatal_exit "testcase \"$tmp_case\" missing rit.yaml"
	[[ "$(yq .type "$CASE_PATH"/"$tmp_case"/rit.yaml)" != "null" ]] || fatal_exit "testcase \"$tmp_case\" type unknown"
	case_dirs[${#case_dirs[@]}]="$tmp_case"
done
[ -z "${#case_dirs[@]}" ] && fatal_exit "no testcase configured"
unset tmp_case

# parse profile
suite_profiles="$(yq --raw-output .\"$profile_name\" "$SUITE_PATH"/"$suite_name".yaml)"
[[ "$suite_profiles" == "null" ]] && fatal_exit "no such suite profile found \"$profile_name\""

pre_yaml="$(echo $suite_profiles | yq --raw-output .pre)"
post_yaml="$(echo $suite_profiles | yq --raw-output .post)"
pre_len="$(echo $pre_yaml | yq --raw-output length)"
post_len="$(echo $post_yaml | yq --raw-output length)"
[[ "$pre_len" == "$post_len" ]] || fatal_exit "pre and post script list have different dimensions"
[ "$pre_len" -lt 1 ] && fatal_exit "script list have 0 dimension"

pre_scripts=()
post_scripts=()
for ((i=0; i<$pre_len; i++)); do
	tmp_pre="$(echo $pre_yaml | yq --raw-output .[$i])"
	tmp_post="$(echo $post_yaml | yq --raw-output .[$i])"
	tmp_pre_len="$(echo $tmp_pre | yq --raw-output length)"
	tmp_post_len="$(echo $tmp_post | yq --raw-output length)"
	tmp_pre_list=
	tmp_post_list=

	[[ "$tmp_pre_len" == "$tmp_post_len" ]] || fatal_exit "pre and post script list $i dimension have different length"

	for ((j=0; j<$tmp_pre_len; j++)); do
		tmp_pre_list="$tmp_pre_list $(echo $tmp_pre | yq --raw-output .[$j])"
		tmp_post_list="$tmp_post_list $(echo $tmp_post | yq --raw-output .[$j])"
	done
	tmp_pre_list="${tmp_pre_list:1}"
	tmp_post_list="${tmp_post_list:1}"

	pre_scripts[$i]="$tmp_pre_list"
	post_scripts[$i]="$tmp_post_list"
done
unset pre_yaml post_yaml pre_len post_len
unset tmp_pre tmp_post tmp_pre_len tmp_post_len tmp_pre_list tmp_post_list

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

# run test
function test_run() {
	local dim=$1
	local test_type=
	local lit_order=
	local lit_concurrent=
	local lit_logging=
	local lit_options=
	local i=

	# run env pre scripts
	for i in $(ls $ENV_PATH/*.pre); do
		source "$i"
	done

	for ((i=0; i<$case_len; i++)); do
		test_type="$(yq --raw-output .type ${CASE_PATH}/${case_dirs[$i]}/rit.yaml)"

		if [[ "$test_type" == "lit" ]]; then
			lit_order="$(yq --raw-output .order ${CASE_PATH}/${case_dirs[$i]}/rit.yaml)"
			lit_concurrent="$(yq --raw-output .concurrent ${CASE_PATH}/${case_dirs[$i]}/rit.yaml)"
			lit_logging="$(yq --raw-output .logging ${CASE_PATH}/${case_dirs[$i]}/rit.yaml)"
			lit_options=

			if [ -z "$lit_order" ] || [[ "$lit_order" == "random" ]]; then
				lit_options="$lit_options --order random"
			elif [[ "$lit_order" == "lexical" ]]; then
				lit_options="$lit_options --order lexical"
			elif [[ "$lit_order" == "smart" ]]; then
				lit_options="$lit_options --order smart"
			else
				LOG_WARN "Unknown lit order setting \"$lit_order\", use default value"
				lit_options="$lit_options --order random"
			fi

			if [ -z "$lit_concurrent" ] || [[ "$lit_concurrent" == "true" ]]; then
				lit_options="$lit_options --workers 4"
			elif [[ "$lit_concurrent" == "false" ]]; then
				lit_options="$lit_options --workers 1"
			else
				LOG_WARN "Unknown lit concurrent setting \"$lit_concurrent\", use default value"
				lit_options="$lit_options --workers 4"
			fi

			if [ -z "$lit_logging" ] || [[ "$lit_logging" == "fail" ]]; then
				lit_options="$lit_options —verbose"
			elif [[ "$lit_logging" == "all" ]]; then
				lit_options="$lit_options --show-all"
			elif [[ "$lit_logging" == "none" ]]; then
				lit_options="$lit_options"
			else
				LOG_WARN "Unknown lit logging setting \"$lit_logging\", use default value"
				lit_options="$lit_options --verbose"
			fi

			LOG_DEBUG Run lit "$lit_options" "$(basename $CASE_PATH)"/"${case_dirs[$i]}"
			"$DRIVER_PATH"/lit.bash $lit_options "${CASE_PATH}"/"${case_dirs[$i]}" 2>&1 | tee "$RUN_PATH"/"$suite_name"_"$profile_name"_"$dim"_"$LOG_DATE".log
		else
			LOG_ERROR "Unknown test type \"$test_type\""
		fi
	done

	# run env post scripts
	for i in $(ls $ENV_PATH/*.post); do
		source "$i"
	done
}

function multi_dimensional_test() {
	local depth=$1
	local dim=$2
	local max_depth=$(( ${#pre_scripts[@]} - 1 ))

	local pre_list=()
	local post_list=()
	local list_len=
	local i=

	depth="${depth:-0}"
	for s in ${pre_scripts[$depth]}; do
		pre_list[${#pre_list[@]}]=$s
	done
	for s in ${post_scripts[$depth]}; do
		post_list[${#post_list[@]}]=$s
	done
	list_len="${#pre_list[@]}"

	[ "$depth" -eq 0 ] && env_create

	for ((i=0; i<$list_len; i++)); do
		script_run "${pre_list[$i]}"
		if [ "$depth" -eq "$max_depth" ]; then
			test_run "$dim$i"
		else
			multi_dimensional_test $((depth+1)) "$dim$i"
		fi
		script_run "${post_list[$i]}"
	done

	[ "$depth" -eq 0 ] && env_destroy

	return 0
}

multi_dimensional_test

code_exit 0

