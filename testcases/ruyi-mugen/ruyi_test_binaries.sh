#!/usr/bin/bash

# #############################################
# @Author    :   weilinfox
# @Contact   :   caiweilin@iscas.ac.cn
# @Date      :   2024/03/12
# @License   :   Apache-2.0
# @Desc      :   ruyisdk package binaries test
# #############################################

source "$(dirname $(realpath $0))"/common/common_lib.sh

EXECUTE_T=120m

function pre_test() {
	LOG_INFO "Start environmental preparation."
	# install_ruyi_bin || LOG_ERROR "Install ruyi error"
	LOG_INFO "End of environmental preparation!"
}

function test_oneshot() {
	local ret retc bp bpb
	for tc in `ruyi list | grep $1 | sed "s/^* $1\///"`; do
		ret=`ruyi install $tc 2>&1`
		retc=$?
		bp=`echo $ret | tail -n 1 | awk '{print $NF}'`
		bpb="$bp"/bin
		echo $ret | grep "no binary"
		if [[ "$?"x == "0x" ]] && [[ "$retc"x != "0x" ]]; then
			LOG_WARN "Check $1/$tc no binary for current host"
			continue
		fi
		if [[ "$retc"x != "0x" ]] || [ -z "$bp" ] || [ ! -d "$bp" ]; then
			CHECK_RESULT $retc 0 0 "Check ruyi install $1/$tc failed"
			continue
		fi
		if [ ! -d "$bpb" ]; then
			LOG_WARN "Check $1/$tc bin dir failed"
			continue
		fi
		for b in `ls $bpb`; do
			file "$bpb"/"$b" | grep ELF | grep executable | grep dynamic
			[ "$?"x != "0x" ] && continue
			ldd "$bpb"/"$b"
			CHECK_RESULT $? 0 0 "Check ruyi $1/$tc binary $b failed"
			ldd "$bpb"/"$b" | grep -vE "\(0x" | grep ".so"
			[ "$?"x = "0x" ] && LOG_WARN "Found extra message in ldd $b output"
			ldd "$bpb"/"$b" | grep -vE "\(0x" | grep ".so" | grep "not found"
			CHECK_RESULT $? 1 0 "Found .so not found in ldd $b output"
		done
	done
}

function run_test() {
	LOG_INFO "Start to run test."

	ruyi update
	CHECK_RESULT $? 0 0 "Check ruyi udpate failed"

	for i in toolchain emulator; do
		test_oneshot $i
	done

	LOG_INFO "End of the test."
}

function post_test() {
	LOG_INFO "start environment cleanup."
	# remove_ruyi_bin
	LOG_INFO "Finish environment cleanup!"
}

main "$@"

