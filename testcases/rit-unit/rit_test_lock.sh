#!/usr/bin/bash

# #############################################
# @Author    :   weilinfox
# @Contact   :   caiweilin@iscas.ac.cn
# @Date      :   2024/11/28
# @License   :   Apache-2.0
# @Desc      :   rit lock test
# #############################################

source "$(dirname $(realpath $0))"/common/common_lib.sh
source "${RIT_DRIVER_PATH}"/utils/mugen_libs.bash

EXECUTE_T=30s

function run_test() {
	LOG_INFO "Start rit EXPR_CALC/EXPR_MATCH test."
	$RIT --help
	CHECK_RESULT $? 2 0 "Check rit.bash --help failed"
	$RIT --help | grep "Find lock file"
	CHECK_RESULT $? 0 0 "Check find lock message failed"
	LOG_INFO "End of the test."
}

main "$@"

