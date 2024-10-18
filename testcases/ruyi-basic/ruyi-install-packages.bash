# NOTE: Test ruyi install and extract
# RUN: bash %s | FileCheck %s

export RUYI_DEBUG=x

ruyi version
# CHECK-LABEL: Ruyi
# CHECK: License: Apache-2.0

ruyi update

ruyi list
# CHECK-LABEL: List of available packages:
# CHECK-NOT: Package declares
# CHECK: * source
# CHECK-NOT: Package declares
# CHECK: * toolchain
# CHECK-NOT: Package declares
# CHECK: * board-image
# CHECK-NOT: Package declares
# CHECK: * emulator
# CHECK-NOT: Package declares

ruyi list --verbose
# CHECK: ## source
# CHECK: * Package kind:
# CHECK: * Vendor:
# CHECK: Package declares {{[0-9]+}} distfile(s):
# CHECK: ## toolchain
# CHECK: * Package kind:
# CHECK: * Vendor:
# CHECK: Package declares {{[0-9]+}} distfile(s):
# CHECK: ### Binary artifacts
# CHECK: ### Toolchain metadata
# CHECK: * Target:
# CHECK: * Flavors:
# CHECK: * Components:
# CHECK: ## board-image
# CHECK: * Package kind:
# CHECK: * Vendor:
# CHECK: Package declares {{[0-9]+}} distfile(s):
# CHECK: ## emulator
# CHECK: * Package kind:
# CHECK: * Vendor:
# CHECK: Package declares {{[0-9]+}} distfile(s):
# CHECK: ### Binary artifacts

ruyi list profiles
# CHECK: needs flavor(s):

ruyi self clean --distfiles --installed-pkgs
# CHECK-SAME: info: removing installed packages
# CHECK-SAME: info: removing downloaded distfiles

# NOTE: binary download test
pkgnames=$(ruyi list | grep -e "^* toolchain" | cut -d'/' -f 2)
for p in $pkgnames; do
	s=$(ruyi list | awk '/\* / {if (f==1) f=2} /./ {if (f==1) {print $0}} /\* toolchain\/'$p'/ {if (f==0) f=1}' | grep -e "^  -" | grep -v "no binary for current host")
	v=$(ruyi list | awk '/\* / {if (f==1) f=2} /./ {if (f==1) {print $0}} /\* toolchain\/'$p'/ {if (f==0) f=1}' | grep -e "^  -" | grep -v "no binary for current host" | grep -v prerelease | grep latest | cut -d' ' -f4)
	if [ -n "$s" ] && [ -n "$v" ]; then
		pkgname="$p"
		pkgversion="$v"
		break
	fi
done

if [ -z "$pkgname" ]; then
	echo "No supported binary package found"
	# CHECK-NOT: No supported binary package found
else
	http_proxy=http://wrong.proxy https_proxy=http://wrong.proxy ruyi install $pkgname
	# CHECK-LABEL: info: downloading
	# CHECK-COUNT-3: warn: failed to fetch distfile
	# CHECK: fatal error: failed to fetch
	# CHECK: Downloads can fail for a multitude of reasons
	# CHECK: * Basic connectivity problems
	ruyi install $pkgname
	# CHECK-LABEL: info: downloading
	# CHECK: info: extracting
	# CHECK: info: package
	ruyi install $pkgname
	ruyi install name:$pkgname
	ruyi install ${pkgname}\(${pkgversion}\)
	# CHECK-COUNT-3: info: skipping already installed package
fi

# NOTE: source extract test
pkgname=$(ruyi list | grep -e "^* source" | head -n 1 | cut -d'/' -f 2)
old_path=$(pwd)
mkdir /tmp/rit-ruyi-basic-ruyi-install && cd /tmp/rit-ruyi-basic-ruyi-install
ruyi extract $pkgname
# CHECK-LABEL: info: extracting
# CHECK: info: package
ls -la coremark.h
# CHECK: coremark.h
cd "$old_path"
rm -rf /tmp/rit-ruyi-basic-ruyi-install

