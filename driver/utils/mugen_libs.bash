
function LOG_PRINT() {
	local level=$1
	shift

	echo "$(date +%Y-%m-%d\ %T)  $0  [ $level  ]  $@"
}

function LOG_INFO() {
	LOG_PRINT "INFO" $@
}

function LOG_WARN() {
	LOG_PRINT "WARN" $@
}

function LOG_ERROR() {
	LOG_PRINT "ERROR" $@
}

function CHECK_RESULT() {
	local result=$1
	local result_expect=${2-0}
	local check_mode=${3-0}
	local error_msg=$4
	local exit_on_error=${5-0}

	if [ -z "$result" ] || [ -z "$result_expect" ] || [ -z "$check_mode" ]; then
		LOG_ERROR "Too few argument!"
	fi

	if [[ "$result" != "$result_expect" ]]; then
		LOG_ERROR "$error_msg"
		LOG_ERROR "${BASH_SOURCE[1]} line ${BASH_LINENO[0]}"
		((RIT_MUGEN_ERROR_COUNT++))
		if [ $exit_on_error -eq 1 ]; then
			exit 1
		fi
	fi

	return 0
}

function PKG_INSTALL() {
}

function PKG_REMOVE() {
}

