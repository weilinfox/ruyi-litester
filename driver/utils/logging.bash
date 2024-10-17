
function LOG_LEVEL() {
	local level=$1
	shift

	echo "[$level] $@"
}

function LOG_DEBUG() {
	LOG_LEVEL "debug" "$@"
}

function LOG_INFO() {
	LOG_LEVEL "info" "$@"
}

function LOG_WARN() {
	LOG_LEVEL "warn" "$@"
}

function LOG_ERROR() {
	LOG_LEVEL "error" "$@"
}

function LOG_FATAL() {
	LOG_LEVEL "fatal" "$@"
}

