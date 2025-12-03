# NOTE: Test wps-office installation
#
# RUN: bash %s 2>&1 | FileCheck %s

ruyi update

ruyi install --host x86_64 extra/wps-office
# CHECK-LABEL: info: instructions on fetching this file:
# CHECK: https://linux.wps.cn

if [[ "$(ruyi install --host x86_64 wps-office 2>&1 | tail -n1)" =~ wps-office_([0-9]+\.[0-9]+\.[0-9]+)\.([0-9]+)_amd64.deb ]]; then
	version="${BASH_REMATCH[1]}"
	build="${BASH_REMATCH[2]}"
else
	echo "Failed to get wps-office package version"
	exit 0
fi

#####
# view-source:https://linux.wps.cn/#
#
# line 177
#
# <a href="#" onClick="downLoad('https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/17900/wps-office_12.1.0.17900_amd64.deb','64位 Deb格式','For X64')" class="version_btn" style="width: 115px;padding-right: 10px;" >For X64</a>
#
# line 225
#
# <script>
#     function downLoad(url,eventType,eventName){
#         _czc.push(['_trackEvent', eventType, '点击', eventName]);
#         _hmt.push(['_trackEvent', eventType, '点击', eventName]);
#         var urlObj = new URL(url);
#         var uri = urlObj.pathname;
#         var secrityKey = "7f8faaaa468174dc1c9cd62e5f218a5b";
#         var timestamp10 = Math.floor(new Date().getTime() / 1000);
#         var md5hash = CryptoJS.MD5(secrityKey+uri+timestamp10);
#         url += '?t='+timestamp10+'&k='+md5hash
#
#         var link = document.createElement('a')
#       link.href = url
#       link.style.display = 'none'
#       document.body.appendChild(link)
#       link.click()
#       document.body.removeChild(link)
#
#
#
#     }
# </script>
#####
file=wps-office_${version}.${build}_amd64.deb
url="https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/$build/$file"
uri="${url#https://wps-linux-personal.wpscdn.cn}"
timestamp10="$(date '+%s')"
secrityKey=7f8faaaa468174dc1c9cd62e5f218a5b
md5hash=$(echo -n "${secrityKey}${uri}${timestamp10}" | md5sum)
url+="?t=${timestamp10}&k=${md5hash%% *}"

if curl --help >/dev/null; then
	curl -L $url -o ~/.cache/ruyi/distfiles/$file
else
	wget $url -O ~/.cache/ruyi/distfiles/$file
fi

ruyi install --host x86_64 extra/wps-office
# CHECK: info: extracting wps-office_{{.*}}_amd64.deb for package wps-office-{{.*}}
# CHECK: info: package wps-office-{{.*}} installed to

