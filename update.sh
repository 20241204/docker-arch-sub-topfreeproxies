#!/usr/bin/env bash
clear
set -e
set -u

echo $(pwd)
sudo apt update
sudo apt -y install unar
# unar 解压函数
extract_single_file() {
  # 第一个参数压缩包名
  local ARCHIVE=$1
  # 处理第二个参数提取路径
  local DIRNAME=${2%/*} ; echo ${DIRNAME}
  # 处理第二个参数提取文件名
  local FILE=${2##*/} ; echo ${FILE}
  # 第3个参数文件重命名
  local NEW_FILENAME=$3
  # 第4个参数创建临时目录
  local OUTPUT_DIR=$(mktemp -d)
  # 解压压缩包文件至临时目录
  unar -o "${OUTPUT_DIR}" "${ARCHIVE}" || return $?
  # 移动文件并重命名
  mv -fv "${OUTPUT_DIR}/${DIRNAME}/${FILE}" ./${NEW_FILENAME} ; chmod -v u+x ./${NEW_FILENAME} 
  # 删除临时目录和压缩包
  rm -rfv "${OUTPUT_DIR}" "${ARCHIVE}"
}

# 下载 Country.mmdb
rm -fv topfreeproxies/utils/Country.mmdb
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "https://github.com/Loyalsoldier/geoip/releases/latest/download/Country.mmdb" -O"topfreeproxies/utils/Country.mmdb"
chmod -v u+x "topfreeproxies/utils/Country.mmdb"

# 下载 linux amd64&aarch64 subconverter
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "https://github.com/tindy2013/subconverter/releases/latest/download/subconverter_linux64.tar.gz" -O"topfreeproxies/utils/subconverter/subconverter_linux64.tar.gz"
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "https://github.com/tindy2013/subconverter/releases/latest/download/subconverter_aarch64.tar.gz" -O"topfreeproxies/utils/subconverter/subconverter_aarch64.tar.gz"
TEMP=$(mktemp -d)

# 解压 linux amd64 subconverter 文件到临时目录
tar vxzf "topfreeproxies/utils/subconverter/subconverter_linux64.tar.gz" -C $TEMP/
#  将 subconverter/subconverter 文件移动到当前目录
mv -fv $TEMP/subconverter/subconverter "topfreeproxies/utils/subconverter/subconverter-amd64"
chmod -v u+x "topfreeproxies/utils/subconverter/subconverter-amd64"
# 删除 linux amd64 subconverter 
rm -rfv "topfreeproxies/utils/subconverter/subconverter_linux64.tar.gz" $TEMP/subconverter
# 解压 linux aarch64 subconverter 文件到临时目录
tar vxzf "topfreeproxies/utils/subconverter/subconverter_aarch64.tar.gz" -C $TEMP/
#  将 subconverter/subconverter 文件移动到当前目录
mv -fv $TEMP/subconverter/subconverter "topfreeproxies/utils/subconverter/subconverter-aarch64"
chmod -v u+x "topfreeproxies/utils/subconverter/subconverter-aarch64"
# 删除 linux aarch64 subconverter
rm -rfv "topfreeproxies/utils/subconverter/subconverter_aarch64.tar.gz" $TEMP

# 下载 lite
# github 项目 xxf098/LiteSpeedTest
URI="xxf098/LiteSpeedTest"
# 从 xxf098/LiteSpeedTest github中提取全部 tag 版本，获取最新版本赋值给 VERSION 后打印
VERSION=$(curl -sL "https://github.com/$URI/releases" | grep -oP '(?<=\/releases\/tag\/)[^"]+' | head -n 1)
echo $VERSION
# 获取 linux amd64&armv8 lite
URI_DOWNLOAD="https://github.com/$URI/releases/download/$VERSION/"

# 拼接下载链接 URI_DOWNLOAD 后打印
echo $URI_DOWNLOAD

# 打印下载链接
echo "${URI_DOWNLOAD}lite-linux-amd64-$VERSION.gz"
echo "${URI_DOWNLOAD}lite-linux-armv8-$VERSION.gz"

# 下载 linux amd64 lite
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "${URI_DOWNLOAD}lite-linux-amd64-$VERSION.gz" -O"topfreeproxies/utils/litespeedtest/lite-linux-amd64-$VERSION.gz"
# 解压 linux amd64 lite
gunzip -v -f "topfreeproxies/utils/litespeedtest/lite-linux-amd64-$VERSION.gz" -c > "topfreeproxies/utils/litespeedtest/lite-linux-amd64"
chmod -v u+x "topfreeproxies/utils/litespeedtest/lite-linux-amd64"
rm -fv "topfreeproxies/utils/litespeedtest/lite-linux-amd64-$VERSION.gz"

# 下载 linux armv8 lite
#wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "${URI_DOWNLOAD}lite-linux-amd64-$VERSION.gz" -O"topfreeproxies/utils/litespeedtest/lite-linux-armv8-$VERSION.gz"

# 解压 linux armv8 lite
#gunzip -v -f "topfreeproxies/utils/litespeedtest/lite-linux-armv8-$VERSION.gz" -c > "topfreeproxies/utils/litespeedtest/lite-linux-armv8"
#chmod -v u+x "topfreeproxies/utils/litespeedtest/lite-linux-armv8"
#rm -fv "topfreeproxies/utils/litespeedtest/lite-linux-armv8-$VERSION.gz"


# github 项目 SagerNet/sing-box
URI="SagerNet/sing-box"
# 从 SagerNet/sing-box 官网中提取全部 tag 版本，获取最新版本赋值给 VERSION 后打印
VERSION=$(curl -sL "https://github.com/$URI/releases" | grep -oP '(?<=\/releases\/tag\/)[^"]+' | head -n 1)
echo $VERSION

# 拼接下载链接 URI_DOWNLOAD 后打印 
URI_DOWNLOAD="https://github.com/$URI/releases/download/$VERSION/"
echo $URI_DOWNLOAD

# 下载 linux amd64&arm64 sing-box
# 打印下载链接
echo "${URI_DOWNLOAD}sing-box-${VERSION#v}-linux-amd64.tar.gz"
echo "${URI_DOWNLOAD}sing-box-${VERSION#v}-linux-arm64.tar.gz"

# 下载 linux amd64&arm64 sing-box
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "${URI_DOWNLOAD}sing-box-${VERSION#v}-linux-amd64.tar.gz" -O"sing-box-${VERSION#v}-linux-amd64.tar.gz"
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "${URI_DOWNLOAD}sing-box-${VERSION#v}-linux-arm64.tar.gz" -O"sing-box-${VERSION#v}-linux-arm64.tar.gz"

# 覆盖解压 linux amd64 sing-box
ARCHIVE="sing-box-${VERSION#v}-linux-amd64.tar.gz"
FILE="sing-box-${VERSION#v}-linux-amd64/sing-box"
NEW_FILENAME="sing-box-linux-amd64"
extract_single_file "${ARCHIVE}" "${FILE}" "${NEW_FILENAME}"
mv -fv "${NEW_FILENAME}" "topfreeproxies/"

# 覆盖解压 linux arm64 sing-box
ARCHIVE="sing-box-${VERSION#v}-linux-arm64.tar.gz"
FILE="sing-box-${VERSION#v}-linux-arm64/sing-box"
NEW_FILENAME="sing-box-linux-arm64"
extract_single_file "${ARCHIVE}" "${FILE}" "${NEW_FILENAME}"
mv -fv "${NEW_FILENAME}" "topfreeproxies/"

# 获取 linux amd64&arm64 mihomo
# DOWNLOAD=`curl -SL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 -H "Connection: keep-alive" -k 'https://github.com/MetaCubeX/mihomo/releases' | sed 's;";\n;g;s;tag;download;g' | grep '/download/' | head -n 2 | tail -1`

# github 项目 MetaCubeX/mihomo
URI="MetaCubeX/mihomo"
# 从 MetaCubeX/mihomo github中提取全部 tag 版本，获取最新版本赋值给 VERSION 后打印
VERSION=$(curl -sL "https://github.com/$URI/releases" | grep -oP '(?<=\/releases\/tag\/)[^"]+' | grep -v Prerelease | head -n 1)
echo $VERSION
# 拼接下载链接 URI_DOWNLOAD 后打印 
URI_DOWNLOAD="https://github.com/$URI/releases/download/$VERSION/"
echo $URI_DOWNLOAD

# 打印下载链接
echo "${URI_DOWNLOAD}mihomo-linux-amd64-$VERSION.gz"
echo "${URI_DOWNLOAD}mihomo-linux-arm64-$VERSION.gz"

# 下载 linux amd64&arm64 mihomo
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "${URI_DOWNLOAD}mihomo-linux-amd64-$VERSION.gz" -O"mihomo-linux-amd64-$VERSION.gz"
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "${URI_DOWNLOAD}mihomo-linux-arm64-$VERSION.gz" -O"mihomo-linux-arm64-$VERSION.gz"

# 覆盖解压 linux amd64 mihomo
unar -f mihomo-linux-amd64-$VERSION.gz ; mv -fv mihomo-linux-amd64-$VERSION "topfreeproxies/mihomo-linux-amd64"
chmod -v u+x "topfreeproxies/mihomo-linux-amd64"

# 删除压缩包文件 linux amd64 mihomo
rm -rfv mihomo-linux-amd64-$VERSION.gz

# 覆盖解压 linux arm64 mihomo
unar -f mihomo-linux-arm64-$VERSION.gz ; mv -fv mihomo-linux-arm64-$VERSION "topfreeproxies/mihomo-linux-arm64"

chmod -v u+x "topfreeproxies/mihomo-linux-arm64"

# 删除压缩包文件 linux arm64 mihomo
rm -rfv mihomo-linux-arm64-$VERSION.gz
