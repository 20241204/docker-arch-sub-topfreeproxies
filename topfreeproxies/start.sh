#!/usr/bin/env bash

# 自定义删除文件多行内容
delete_black_lines() {
    # 定义文件路径
    file_path="$1"

    # 使用sed命令删除所有空行
    sed -i '/^$/d' "$file_path"
}

# 自定义删除文件多行内容
delete_multiple_lines() {
    # 定义要搜索的字符串
    search_string="$1"
    # 定义文件路径
    file_path="$2"

    # 删除所有匹配项
    # 使用perl命令删除所有匹配的字符串
    perl -0777 -i -pe "s/\Q$search_string\E//g" "$file_path"
}

# 自定义替换文件多行内容
replace_string_in_file() {
    # 定义要搜索的字符串
    search_string="$1"

    # 定义要替换的字符串
    replace_string="$2"

    # 定义文件路径
    file_path="$3"

    # 定义执行替换操作的标志默认1
    num="${4:-1}"
    # num 为1则只保留第一个其他部分全部替换
    if [ "$num" -eq 1 ]; then
        # 计算字符串在文件中出现的次数
        count=$(grep -Fo "$search_string" "$file_path" | wc -l)

        # 如果字符串出现两次以上，则只保留第一个其他部分全部替换
        if [ "$count" -gt 1 ]; then
            # 使用perl命令，当第一次匹配到字符串时，将其替换为一个临时字符串
            # 然后将文件中的其他匹配项替换为目标字符串
            # 最后，将临时字符串替换回原始字符串
            perl -0777 -i -pe "s/\Q$search_string\E/++\$n == 1 ? \$& : '$replace_string'/ge" "$file_path"
        fi
    # num 为0则全部替换一个不留
    elif [ "$num" -eq 0 ]; then
          # 使用perl命令进行替换
          perl -0777 -i -pe "s/\Q$search_string\E/$replace_string/g" "$file_path"
    fi
}

# 函数使用示例：replace_config "config.yaml"
replace_config() {
    local config_file=$1

    echo "正在编辑 ${config_file}，请稍候..."

    declare -a delete_params=(
    "port: "
    "mixed-port: "
    "socks-port: "
    "allow-lan: "
    "external-controller: "
    "mode: "
    "log-level: "
    "redir-port: "
    "tproxy-port: "
    "secret: "
    "external-ui: "
    "external-ui-name: "
    "external-ui-url: "
    "tun:"
    "[[:space:]]*enable: "
    "[[:space:]]*device: "
    "[[:space:]]*stack: "
    "[[:space:]]*auto-route: "
    "[[:space:]]*auto-redirect: "
    "[[:space:]]*auto-detect-interface: "
    "[[:space:]]*dns-hijack:"
    "[[:space:]]*- any:"
    "[[:space:]]*route-exclude-address: "
    "[[:space:]]*mtu: "
    )

    declare -a add_params=(
    "port: 7891"
    "socks-port: 7892"
    "mixed-port: 7893"
    "external-controller: :7894"
    "external-ui: ui"
    "external-ui-name: xd"
    "external-ui-url: https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"
    "redir-port: 7895"
    "tproxy-port: 7896"
    "allow-lan: true"
    "mode: rule"
    "log-level: debug"
    "tun:\n  enable: false\n  device: Mihomo\n  stack: mixed\n  auto-route: true\n  auto-redirect: false\n  auto-detect-interface: true\n  dns-hijack:\n    - any:53\n  route-exclude-address: []\n  mtu: 1500"
    )

    for param in "${delete_params[@]}"; do
        echo "删除 ${config_file} 中开头为 \"${param}\" 的行："
        sed -i "/^${param}/d" "${config_file}"
        echo sed -i "/^${param}/d" "${config_file}"
    done

    for ((i=0; i<${#add_params[@]}; i++)); do
        echo "在第$((i+1))行开头添加 ${add_params[i]}"
        sed -i "$((i+1))i${add_params[i]}" "${config_file}"
        echo sed -i "$((i+1))i${add_params[i]}" "${config_file}"
    done
}

clear
timedatectl set-timezone 'Asia/Shanghai'

# 下载 nekowarp 订阅文件
wget -t 3 -T 10 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "https://neko-warp.nloli.xyz/neko_warp.yaml" -O"nekowarp.yaml"

# 检测系统架构
ARCH=$(uname -m)

case $ARCH in
    x86_64)
        # 如果是 amd64 架构
        echo "Running on amd64 architecture"
        cp -fv utils/subconverter/subconverter-amd64 utils/subconverter/subconverter
        cp -fv utils/litespeedtest/lite-linux-amd64 utils/litespeedtest/lite
        cp -fv mihomo-linux-amd64 mihomo-linux
        cp -fv sing-box-linux-amd64 sing-box-linux
        ;;
    aarch64)
        # 如果是 arm64 架构
        echo "Running on arm64 architecture"
        cp -fv utils/subconverter/subconverter-aarch64 utils/subconverter/subconverter
        cp -fv utils/litespeedtest/lite-linux-armv8 utils/litespeedtest/lite
        cp -fv mihomo-linux-arm64 mihomo-linux
        cp -fv sing-box-linux-arm64 sing-box-linux
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

#chmod -v +x utils/subconverter/subconverter-amd64 utils/subconverter/subconverter-aarch64
#chmod -v +x utils/litespeedtest/lite-linux-amd64 utils/litespeedtest/lite-linux-armv8
#chmod -v +x mihomo-linux-amd64 mihomo-linux-arm64
#chmod -v +x sing-box-linux-amd64 sing-box-linux-arm64
chmod -v +x utils/subconverter/subconverter
chmod -v +x utils/litespeedtest/lite
chmod -v +x mihomo-linux
chmod -v +x sing-box-linux

# Initialize mihomo-linux
chmod +x ./mihomo-linux && ./mihomo-linux &
# Setup proxychains
chmod -v 777 /etc/proxychains.conf
cp -fv proxychains.conf /etc/proxychains.conf
# Run mihomo-linux
sudo pkill -f mihomo-linux
./mihomo-linux -f mihomo_config.yml &

python utils/main.py

replace_config "Eternity.yaml"

# 删除多行空行
file_path="Eternity.yaml"
delete_black_lines "$file_path"

# 调用筛选删除多行
search_string='  - name: GLOBAL
    type: select
    proxies:
      - ♻️ 自动选择
      - 🤘 手动选择'
delete_multiple_lines "$search_string" "$file_path"

# 调用筛选删除多行
search_string='  - name: GLOBAL
    proxies:
      - ♻️ 自动选择
      - 🤘 手动选择
    type: select'
delete_multiple_lines "$search_string" "$file_path"

# 调用替换多行参数2
search_string='proxy-groups:'
replace_string='proxy-groups:
  - name: GLOBAL
    type: select
    proxies:
      - ♻️ 自动选择
      - 🤘 手动选择
'
num=0
replace_string_in_file "$search_string" "$replace_string" "$file_path" "$num"

# 替换协议
sed -i 's;cipher: chacha20-poly1305;cipher: chacha20-ietf-poly1305;g' Eternity.yaml
sed -i 's;cipher: xchacha20-poly1305;cipher: chacha20-ietf-poly1305;g' Eternity.yaml
sed -i 's;cipher: ss;cipher: chacha20-ietf-poly1305;g' Eternity.yaml

# 关闭开启本地 http 协议访问
kill -9 $(ps -ef | grep -v grep | grep "http.server" | awk '{print $2}')
python -m http.server &

# clone sing-box-subscribe.git 订阅 clash/v2ray 转换 singbox
rm -rfv sing-box-subscribe.bak/* sing-box-subscribe.bak/.*
git clone https://github.com/Toperlock/sing-box-subscribe sing-box-subscribe.bak
git config --global --add safe.directory sing-box-subscribe.bak
git config --global --add safe.directory /topfreeproxies/sing-box-subscribe.bak
cd sing-box-subscribe.bak
git fetch --all
git reset --hard origin/main
git pull

# 替换解析模板配置文件
# 添加 str() 函数
#sed -i "s;share_link\['name'\];str(share_link\['name'\]);g" parsers/clash2base64.py
#grep -i "str(share_link\['name'\])" parsers/clash2base64.py

# 使用命令替换 sing-box 模板配置文件端口 http: 7897 socks: 7898 mixed: 7899 controller: 7900
#perl -i -pe 'BEGIN{undef $/;} s/,\n    {\n      "type": "mixed",\n      "listen": "127.0.0.1",\n      "listen_port": 2080,\n      "sniff": true,\n      "users": \[\]\n    }/,\n    {\n      "type": "http",\n      "listen": "0.0.0.0",\n      "listen_port": 7897,\n      "sniff": true,\n      "users": \[\]\n    },\n    {\n      "type": "socks",\n      "listen": "0.0.0.0",\n      "listen_port": 7898,\n      "sniff": true,\n      "users": \[\]\n    },\n    {\n      "type": "mixed",\n      "listen": "0.0.0.0",\n      "listen_port": 7899,\n      "sniff": true,\n      "users": \[\]\n    }/smg' config_template/sb-config-1.11.json
#sed -i 's;127.0.0.1;0.0.0.0;g;s;0.0.0.0:9090;:7900;g;s;"strict_route": true;"strict_route": false;g;s;_port": 2080;_port": 7897;g' config_template/sb-config-1.11.json
cp -fv ../sb-config-1.11.json config_template/sb-config-1.11.json

# 写入订阅解析配置
cp -fv ../providers.json providers.json

# 新增 singbox 转换生成
# 执行转换项目程序
echo -e '4\n' | python main.py

cd ..

# sed 替换全部 "max_early_data": xxxxxxx 为 "max_early_data": 3999999999
sed -i 's/"max_early_data":.[^,}]*/"max_early_data": 3999999999/g' "singbox-config.json"

# 备份测试修改对比
#cp -fv "singbox-config.json" "singbox-config.json.bak"

# 调用替换多行参数1
search_string='"
      ]
    },
    {
      "tag": "topfreeproxies",
      "type": "selector",
      "outbounds": ['
replace_string='",'
file_path="singbox-config.json"
num=1
replace_string_in_file "$search_string" "$replace_string" "$file_path" "$num"

# 调用替换多行参数2
search_string=',
      "endpoint_independent_nat": false,
      "stack": "system",
      "platform": {
        "http_proxy": {
          "enabled": true,
          "server": "0.0.0.0",
          "server_port": 7891
        }
      }'
replace_string=''
file_path="singbox-config.json"
num=0
replace_string_in_file "$search_string" "$replace_string" "$file_path" "$num"

# 替换协议
sed -i 's;"chacha20-poly1305";"chacha20-ietf-poly1305";g' singbox-config.json
sed -i 's;"method": "ss";"method": "aes-128-gcm";g' singbox-config.json

# 删除订阅文件
rm -fv nekowarp.yaml

# 删除python cache
IFS_BAK=$IFS
IFS=$'\n'
for i in $(find ${SOURCE_PATH} -type d -iname "__pycache__")
do
    echo $i ; rm -rfv $i
done
IFS=$IFS_BAK

# 校验 Eternity.yaml 
./mihomo-linux -t Eternity.yaml > mihomo-check.log

# 校验 sing-box-config.json
./sing-box-linux format -c singbox-config.json > singbox-config-format.json
./sing-box-linux check -c singbox-config-format.json > singbox-config-check.log

# 移动 Eternity.yaml singbox-config.json singbox-config-format.json 到 /root/topfreeproxies 目录让 docker 挂在目录不至于为空
if [ ! -d /root/topfreeproxies ] ; then
    mkdir -pv /root/topfreeproxies/
    cp -fv Eternity.yaml singbox-config.json singbox-config-format.json /root/topfreeproxies/

    # 清理记录
    rm -rfv update/*

    # 使用 Asia/Shanghai 时区获取当前日期的年、月、日
    year=$(TZ="Asia/Shanghai" date +%Y)
    month=$(TZ="Asia/Shanghai" date +%m)
    day=$(TZ="Asia/Shanghai" date +%d)
    
    # 组合目录路径和文件名
    directory="update/${year:2}${month}"
    file="${directory}/${year:2}${month}${day}.txt"
    
    # 创建目录并创建文件
    mkdir -p "$directory"
    touch "$file"
    
    echo "Created directory: $directory"
    echo "Created file: $file"
fi
