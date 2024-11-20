
source "${RIT_DRIVER_PATH}"/driver/utils/libs.bash

# here use mugen logging format
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

RIT_MUGEN_DNF_TMP="$RIT_TMP_PATH"/rit_mugen_dnf.tmp
RIT_MUGEN_APT_TMP="$RIT_TMP_PATH"/rit_mugen_apt.tmp
RIT_MUGEN_PACMAN_TMP="$RIT_TMP_PATH"/rit_mugen_pacman.tmp

function DNF_INSTALL() {
	local pkgs="$1"
	local tool="$(whereis -b dnf | cut -d':' -f2)"
	local output=
	local repos=
	local updates=
	local ret=

	if [ -z "$tool" ]; then
		LOG_ERROR "Unsupported package manager: dnf"
		return 1
	elif ! SUDO_CHECK; then
		LOG_ERROR "This function will call sudo dnf, early return"
		return 1
	fi

	output="$(sudo LC_ALL=C dnf --assumeno install $pkgs)"
	if [[ "$output" =~ "already installed" ]] && [[ "$output" =~ "Nothing to do" ]]; then
		LOG_INFO "pkgs:($pkgs) already installed"
		return 0
	fi

	repos="$(sudo LC_ALL=C dnf repolist | awk '{print $NF}' | sed -e '1d;:a;N;$!ba;s/\\n/ /g')"
	ret="$?"
	if [ "$ret" -ne "0" ]; then
		LOG_ERROR "dnf repolist check script return none zero value($ret) with output ($repos)"
		return 1
	fi

	updates="$(sudo LC_ALL=C dnf --assumeno install $pkgs 2>&1 | grep -A 1226 "Upgrading:" | grep update | grep -wE "$(uname -m)|noarch" | awk '{print $1}' | xargs)"
	ret="$?"
	if [ "$ret" -ne "0" ]; then
		LOG_ERROR "dnf --assumeno install check script return none zero value($ret) with output ($updates)"
		return 1
	fi

	# real package list
	if [ -z "$updates" ]; then
		output="$(sudo LC_ALL=C dnf --assumeno install $pkgs 2>&1 | grep -wE "$(echo $repos | sed 's/ /|/g')" | grep -wE "$(uname -m)|noarch" | awk '{print $1}')"
		ret="$?"
	else
		# exclude update packages
		output="$(sudo LC_ALL=C dnf --assumeno install $pkgs 2>&1 | grep -wE "$(echo $repos | sed 's/ /|/g')" | grep -wE "$(uname -m)|noarch" | grep -vE "$(echo $updates | sed 's/ /|/g')" | awk '{print $1}')"
		ret="$?"
	fi
	if [ "$ret" -ne "0" ]; then
		LOG_ERROR "dnf --assumeno install script return none zero value($ret) with output ($output)"
		return 1
	fi

	sudo LC_ALL=C dnf -y install $pkgs
	ret="$?"
	if [ "$ret" -ne 0 ]; then
		LOG_ERROR "dnf install exit with none zero value ($ret)"
		return 1
	fi
	pkgs=
	for ret in $output; do
		pkgs="$pkgs $ret"
	done

	LOG_INFO "Installed packages: ($pkgs)"
	echo "$pkgs" >> $RIT_MUGEN_DNF_TMP

	return 0
}

function APT_INSTALL() {
	local pkgs="$1"
	local tool="$(whereis -b apt-get | cut -d':' -f2)"
	local output=
	local ret=

	if [ -z "$tool" ]; then
		LOG_ERROR "Unsupported package manager: apt-get"
		return 1
	elif ! SUDO_CHECK; then
		LOG_ERROR "This function will call sudo apt-get, early return"
		return 1
	fi

	sudo apt-get update
	if [ "$?" -ne 0 ]; then
		LOG_ERROR "apt-get update failed to fetch releases"
		return 1
	fi

	output="$(sudo LC_ALL=C apt-get --simulate --no-show-upgraded --no-install-recommends install $pkgs)"
	ret="$?"
	if [[ "$output" =~ " 0 newly installed" ]]; then
		LOG_INFO "pkgs:($pkgs) already installed"
		return 0
	fi
	# 0 already the newest version, 1 something can be done but, 100 no such package
	if [ "$ret" -ne 0 ]; then
		LOG_ERROR "apt-get --simulate find something wrong with package installation ($ret) ($output)"
		return 1
	fi

	output="$(sudo LC_ALL=C apt-get --simulate --no-show-upgraded --no-install-recommends install $pkgs 2>&1 | grep -iA 1898 "NEW packages will be installed" | grep -E "^  ")"
	if [ "$?" -ne 0 ]; then
		LOG_ERROR "apt-get --simulate failed to get package list"
		return 1
	fi

	sudo apt-get --assume-yes --no-install-recommends install $pkgs
	pkgs=
	for ret in $output; do
		pkgs="$pkgs $ret"
	done
	LOG_INFO "Installed packages: ($pkgs)"
	echo "$pkgs" >> $RIT_MUGEN_APT_TMP
}

function PACMAN_INSTALL() {
	local pkgs="$1"
	local tool="$(whereis -b pacman | cut -d':' -f2)"
	local output=
	local ret=

	if [ -z "$tool" ]; then
		LOG_ERROR "Unsupported package manager: pacman"
		return 1
	elif ! SUDO_CHECK; then
		LOG_ERROR "This function will call sudo pacman, early return"
		return 1
	fi

	# Archlinux cannot be upgrade partly
	sudo pacman -Syuu
	ret="$?"
	if [ "$ret" -ne 0 ]; then
		LOG_ERROR "pacman -Syuu return none zero value($ret)"
		return 1
	fi

	output="$(sudo LC_ALL=C pacman --need --noconfirm -Sw "$pkgs" 2>&1 | grep -E "^ there is nothing to do$")"
	if [ "$ret" -eq 0 ]; then
		LOG_INFO "pkgs:($pkgs) is already installed"
		return 0
	fi

	# check /var/log/pacman.log
	output="$(tail -n1 /var/log/pacman.log | grep 'pacman --need --noconfirm -Sw')"
	if [ "$?" -ne 0 ]; then
		LOG_ERROR "failed to check /var/log/pacman.log"
		return 1
	fi

	sudo LC_ALL=C pacman --need --noconfirm -S $pkgs
	if [ "$?" -ne 0 ]; then
		LOG_ERROR "failed to install packages($pkgs)"
		return 1
	fi

	output="$(grep -FA 1024 "$output" /var/log/pacman.log | grep -F "[ALPM] installed" | cut -d" " -f4)"
	pkgs=
	for ret in $output; do
		pkgs="$pkgs $ret"
	done

	LOG_INFO "Installed packages: ($pkgs)"
	echo "$pkgs" >> $RIT_MUGEN_PACMAN_TMP
}

function EMERGE_INSTALL() {
	local pkgs="$1"
	local tool="$(whereis -b emerge | cut -d':' -f2)"

	if [ -z "$tool" ]; then
		LOG_ERROR "Unsupported package manager: emerge"
		return 1
	elif ! SUDO_CHECK; then
		LOG_ERROR "This function will call sudo emerge, early return"
		return 1
	fi
}

function PKG_INSTALL() {
	local arch_flag=
	local arch_pkg=
	local debian_flag=
	local debian_pkg=
	local fedora_flag=
	local fedora_pkg=
	local gentoo_flag=
	local gentoo_pkg=
	local openeuler_flag=
	local openeuler_pkg=
	local openkylin_flag=
	local openkylin_pkg=
	local revyos_flag=
	local revyos_pkg=
	local ubuntu_flag=
	local ubuntu_pkg=
	local pkg_flag=
	local pkg_list=

	while [ "$#" -gt 0 ]; do
	case $1 in
		--archlinux)
			arch_flag=x
			[ -z "$pkg_list" ] || { arch_flag=o; pkg_flag=x; }
			;;
		--debian)
			debian_flag=x
			[ -z "$pkg_list" ] || { debian_flag=o; pkg_flag=x; }
			;;
		--fedora)
			fedora_flag=x
			[ -z "$pkg_list" ] || { fedora_flag=o; pkg_flag=x; }
			;;
		--gentoo)
			gentoo_flag=x
			[ -z "$pkg_list" ] || { gentoo_flag=o; pkg_flag=x; }
			;;
		--openeuler)
			openeuler_flag=x
			[ -z "$pkg_list" ] || { openeuler_flag=o; pkg_flag=x; }
			;;
		--openkylin)
			openkylin_flag=x
			[ -z "$pkg_list" ] || { openkylin_flag=o; pkg_flag=x; }
			;;
		--revyos)
			revyos_flag=x
			[ -z "$pkg_list" ] || { revyos_flag=o; pkg_flag=x; }
			LOG_WARN "--revyos is not recommended, please use --debian"
			;;
		--ubuntu)
			ubuntu_flag=x
			[ -z "$pkg_list" ] || { ubuntu_flag=o; pkg_flag=x; }
			;;
		--*)
			LOG_WARN "Unknown distro argument $1"
			;;
		*)
			pkg_list="$pkg_list $1"
			;;
	esac
	shift

	if [[ "$pkg_flag" == "x" ]] || [ "$#" -eq 0 ]; then
		[[ "$arch_flag" == "x" ]] && { arch_flag= ; arch_pkg="$pkg_list"; }
		[[ "$debian_flag" == "x" ]] && { debian_flag= ; debian_pkg="$pkg_list"; }
		[[ "$fedora_flag" == "x" ]] && { fedora_flag= ; fedora_pkg="$pkg_list"; }
		[[ "$openeuler_flag" == "x" ]] && { openeuler_flag= ; openeuler_pkg="$pkg_list"; }
		[[ "$openkylin_flag" == "x" ]] && { openkylin_flag= ; openkylin_pkg="$pkg_list"; }
		[[ "$gentoo_flag" == "x" ]] && { gentoo_flag= ; gentoo_pkg="$pkg_list"; }
		[[ "$revyos_flag" == "x" ]] && { revyos_flag= ; revyos_pkg="$pkg_list"; }
		[[ "$ubuntu_flag" == "x" ]] && { ubuntu_flag= ; ubuntu_pkg="$pkg_list"; }

		pkg_list=
		pkg_flag=

		[[ "$arch_flag" == "o" ]] && arch_flag=x
		[[ "$debian_flag" == "o" ]] && debian_flag=x
		[[ "$fedora_flag" == "o" ]] && fedora_flag=x
		[[ "$openeuler_flag" == "o" ]] && openeuler_flag=x
		[[ "$openkylin_flag" == "o" ]] && openkylin_flag=x
		[[ "$gentoo_flag" == "o" ]] && gentoo_flag=x
		[[ "$revyos_flag" == "o" ]] && revyos_flag=x
		[[ "$ubuntu_flag" == "o" ]] && ubuntu_flag=x
	fi
	done

	if HOST_HAS_FEATURE "archlinux"; then
		PACMAN_INSTALL "$arch_pkg"
	elif HOST_HAS_FEATURE "debian"; then
		APT_INSTALL "$debian_pkg"
	elif HOST_HAS_FEATURE "fedora"; then
		DNF_INSTALL "$fedora_pkg"
	elif HOST_HAS_FEATURE "openeuler"; then
		DNF_INSTALL "$openeuler_pkg"
	elif HOST_HAS_FEATURE "openkylin"; then
		APT_INSTALL "$openkylin_pkg"
	elif HOST_HAS_FEATURE "gentoo"; then
		EMERGE_INSTALL "$gentoo_pkg"
	elif HOST_HAS_FEATURE "revyos"; then
		APT_INSTALL "$revyos_pkg"
	elif HOST_HAS_FEATURE "ubuntu"; then
		APT_INSTALL "$ubuntu_pkg"
	else
		LOG_ERROR "Unsupported distro?"
	fi
}

function DNF_REMOVE() {
	local tool="$(whereis -b dnf | cut -d':' -f2)"

	if [ -z "$tool" ]; then
		LOG_ERROR "Unsupported package manager: dnf"
		return 1
	elif ! SUDO_CHECK; then
		LOG_ERROR "This function will call sudo dnf, early return"
		return 1
	fi

	local pkgs="$(tail --lines 1 "$RIT_MUGEN_DNF_TMP")"
	head --lines -1 "$RIT_MUGEN_DNF_TMP" > "$RIT_MUGEN_DNF_TMP".new
	mv "$RIT_MUGEN_DNF_TMP".new "$RIT_MUGEN_DNF_TMP"

	sudo dnf -y remove $pkgs
}

function APT_REMOVE() {
	local tool="$(whereis -b apt-get | cut -d':' -f2)"

	if [ -z "$tool" ]; then
		LOG_ERROR "Unsupported package manager: apt-get"
		return 1
	elif ! SUDO_CHECK; then
		LOG_ERROR "This function will call sudo apt-get, early return"
		return 1
	fi

	local pkgs="$(tail --lines 1 "$RIT_MUGEN_APT_TMP")"
	head --lines -1 "$RIT_MUGEN_APT_TMP" > "$RIT_MUGEN_APT_TMP".new
	mv "$RIT_MUGEN_APT_TMP".new "$RIT_MUGEN_APT_TMP"

	sudo apt-get -y remove $pkgs
}

function PACMAN_REMOVE() {
	local tool="$(whereis -b pacman | cut -d':' -f2)"

	if [ -z "$tool" ]; then
		LOG_ERROR "Unsupported package manager: pacman"
		return 1
	elif ! SUDO_CHECK; then
		LOG_ERROR "This function will call sudo pacman, early return"
		return 1
	fi

	local pkgs="$(tail --lines 1 "$RIT_MUGEN_PACMAN_TMP")"
	head --lines -1 "$RIT_MUGEN_PACMAN_TMP" > "$RIT_MUGEN_PACMAN_TMP".new
	mv "$RIT_MUGEN_PACMAN_TMP".new "$RIT_MUGEN_PACMAN_TMP"

	sudo pacman --noconfirm -R $pkgs
}

function EMERGE_REMOVE() {
	local tool="$(whereis -b emerge | cut -d':' -f2)"

	if [ -z "$tool" ]; then
		LOG_ERROR "Unsupported package manager: emerge"
		return 1
	elif ! SUDO_CHECK; then
		LOG_ERROR "This function will call sudo emerge, early return"
		return 1
	fi
}

function PKG_REMOVE() {
	if HOST_HAS_FEATURE "archlinux"; then
		PACMAN_REMOVE
	elif HOST_HAS_FEATURE "debian"; then
		APT_REMOVE
	elif HOST_HAS_FEATURE "fedora"; then
		DNF_REMOVE
	elif HOST_HAS_FEATURE "openeuler"; then
		DNF_REMOVE
	elif HOST_HAS_FEATURE "openkylin"; then
		APT_REMOVE
	elif HOST_HAS_FEATURE "gentoo"; then
		EMERGE_REMOVE
	elif HOST_HAS_FEATURE "revyos"; then
		APT_REMOVE
	elif HOST_HAS_FEATURE "ubuntu"; then
		APT_REMOVE
	else
		LOG_ERROR "Unsupported distro?"
	fi
}

