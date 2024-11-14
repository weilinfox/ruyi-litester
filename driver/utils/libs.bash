
function HOST_HAS_FEATURE() {
	for ft in $RIT_CASE_FEATURES; do
		if [[ "$ft" == "$1" ]]; then
			return 0
		fi
	done
	return 1
}

