
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

function PKG_INSTALL() {
}

function PKG_REMOVE() {
}

