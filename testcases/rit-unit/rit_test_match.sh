#!/usr/bin/bash

# #############################################
# @Author    :   weilinfox
# @Contact   :   caiweilin@iscas.ac.cn
# @Date      :   2024/11/27
# @License   :   Apache-2.0
# @Desc      :   rit EXPR_CALC/EXPR_MATCH test
# #############################################

source "${RIT_DRIVER_PATH}"/utils/mugen_libs.bash

EXECUTE_T=1m

CASES=("ab-a" "ab-b" "ab-f" "bc-d")
MATCH=(0      0      1      0)
EXPRS=('ab- and ( -a or -b ) or bc-'
	'ab- and not -f or bc-'
	'not ab-f')

function run_test() {
	LOG_INFO "Start rit EXPR_CALC/EXPR_MATCH test."

	local i j
	for ((i=0;i<${#CASES[@]};i++)); do
		for ((j=0;j<${#EXPRS[@]};j++)); do
			EXPR_MATCH ${CASES[$i]} ${EXPRS[$j]}
			CHECK_RESULT $? ${MATCH[$i]} 0 "Check EXPR_MATCH CASES[$i] EXPRS[$j] failed"
		done
	done

	LOG_INFO "End of the test."
}

main "$@"

