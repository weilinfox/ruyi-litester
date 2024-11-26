
function HOST_HAS_FEATURE() {
	for ft in $RIT_CASE_FEATURES; do
		if [[ "$ft" == "$1" ]]; then
			return 0
		fi
	done
	return 1
}

function SUDO_CHECK() {
	local ans=
	[[ "$RIT_SUDO"x == "xx" ]]; ans=$?

	return "$ans"
}

function EXPR_CALC() {
	# EXPR_CALC str sub1 op sub2
	local str="$1"
	local sub1="$2"
	local op="$3"
	local sub2="$4"

	if [ -n "$sub1" ] && [[ "$sub1" != "1" ]] && [[ "$sub1" != "0" ]]; then
		sub1=$([[ "$str" =~ "$sub1" ]]; echo $?)
	fi
	if [ -n "$sub2" ] && [[ "$sub2" != "1" ]] && [[ "$sub2" != "0" ]]; then
		sub2=$([[ "$str" =~ "$sub2" ]]; echo $?)
	fi

	case $op in
		not)
			if [ "$sub2" -gt 0 ]; then
				return 0
			else
				return 1
			fi
			;;
		and)
			if [ "$sub1" -gt 0 ] || [ "$sub2" -gt 0 ]; then
				return 1
			else
				return 0
			fi
			;;
		or)
			if [ "$sub1" -eq 0 ] || [ "$sub2" -eq 0 ]; then
				return 0
			else
				return 1
			fi
			;;
	esac

	return 1
}

function EXPR_MATCH() {
	local str="$1"
	local nums=()
	local ops=()
	local op=
	local num=
	local opl=
	local num1=
	local num2=

	shift

	while [ "$#" -gt 0 ] || [ "${#ops[@]}" -gt 0 ] ; do

	op=
	num=
	opl=
	if [ "$#" -gt 0 ]; then
		case $1 in
			"("|")"|or|and)
				op="$1"
				;;
			not)
				op="$1"
				nums[${#nums[@]}]=
				;;
			*)
				num="$1"
				nums[${#nums[@]}]="$1"
				;;
		esac

		shift
	fi

	while true; do
		if [ -n "$num" ]; then
			break
		fi
		if [ "${#ops[@]}" -lt 1 ]; then
			break
		fi
		opl="${ops[$((${#ops[@]}-1))]}"
		case "$op" in
			"(")
				break
				;;
			")")
				if [[ "$opl" == "(" ]]; then
					op=
					unset ops[$((${#ops[@]}-1))]
					break
				fi
				;;
			and)
				if [[ "or (" =~ "$opl" ]]; then
					break
				fi
				;;
			or)
				if [[ "(" == "$opl" ]]; then
					break
				fi
		esac

		unset ops[$((${#ops[@]}-1))]
		num2="${nums[$((${#nums[@]}-1))]}"
		unset nums[$((${#nums[@]}-1))]
		num1="${nums[$((${#nums[@]}-1))]}"
		unset nums[$((${#nums[@]}-1))]
		EXPR_CALC "$str" "$num1" "$opl" "$num2"
		nums[${#nums[@]}]=$?
	done

	if [ -n "$op" ]; then
		ops[${#ops[@]}]="$op"
	fi

	done

	return "${nums[0]}"
}

