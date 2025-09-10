#!/bin/sh
set -e

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 信号处理函数
cleanup() {
    echo "Received termination signal, shutting down..."
    if [ -n "$nps_pid" ]; then
        kill -TERM "$nps_pid" 2>/dev/null
    fi
    if [ -n "$npc_pid" ]; then
        kill -TERM "$npc_pid" 2>/dev/null
    fi
    wait
    exit 0
}

# 捕获信号
trap cleanup TERM INT

# 生成NPS配置
cat > /conf/nps.conf<< TEMPEOF
appname = nps
#Boot mode(dev|pro)
runmode = ${RUNMODE}

#HTTP(S) proxy port, no startup if empty
http_proxy_ip=0.0.0.0
http_proxy_port=${HTTP_PROXY_PORT}
https_proxy_port=${HTTPS_PROXY_PORT}
https_just_proxy=true
#default https certificate setting
https_default_cert_file=${WEB_CERT_FILE}
https_default_key_file=${WEB_KEY_FILE}

##bridge
bridge_type=tcp
bridge_port=${BRIDGE_PORT}
bridge_ip=0.0.0.0

# Public password, which clients can use to connect to the server
# After the connection, the server will be able to open relevant ports and parse related domain names according to its own configuration file.
public_vkey=${PUBLIC_VKEY}

#Traffic data persistence interval(minute)
#Ignorance means no persistence
flow_store_interval=${FLOW_STORE_INTERVAL}

# log level LevelEmergency->0  LevelAlert->1 LevelCritical->2 LevelError->3 LevelWarning->4 LevelNotice->5 LevelInformational->6 LevelDebug->7
log_level=${LOG_LEVEL}
#log_path=nps.log

#Whether to restrict IP access, true or false or ignore
#ip_limit=true

#p2p
#p2p_ip=127.0.0.1
#p2p_port=6000

#web
web_host=admin.${DOMAIN}
web_username=${WEB_USERNAME}
web_password=${WEB_PASSWORD}
web_port=${WEB_PORT}
web_ip=${WEB_IP}
web_base_url=${WEB_BASE_URL}
web_open_ssl=${WEB_OPEN_SSL}
web_cert_file=${WEB_CERT_FILE}
web_key_file=${WEB_KEY_FILE}
# if web under proxy use sub path. like http://host/nps need this.
#web_base_url=/nps

#Web API unauthenticated IP address(the len of auth_crypt_key must be 16)
auth_key=${AUTH_KEY}
auth_crypt_key=${AUTH_CRYPT_KEY}

#allow_ports=9001-9009,10001,11000-12000

#Web management multi-user login
allow_user_login=${ALLOW_USER_LOGIN}
allow_user_register=${ALLOW_USER_REGISTER}
allow_user_change_username=${ALLOW_USER_CHANGE_USERNAME}

#extension
allow_flow_limit=${ALLOW_FLOW_LIMIT}
allow_rate_limit=${ALLOW_RATE_LIMIT}
allow_tunnel_num_limit=${ALLOW_TUNNEL_NUM_LIMIT}
allow_local_proxy=${ALLOW_LOCAL_PROXY}
allow_connection_num_limit=${ALLOW_CONNECTION_NUM_LIMIT}
allow_multi_ip=${ALLOW_MULTI_IP}
system_info_display=${SYSTEM_INFO_DISPLAY}

#cache
http_cache=${HTTP_CACHE}
http_cache_length=${HTTP_CACHE_LENGTH}

TEMPEOF

# 生成NPC配置
cat > /conf/npc.conf<< TEMPEOF
[common]
server_addr=${NPC_SERVER_ADDR}:${BRIDGE_PORT}
conn_type=${NPC_CONN_TYPE}
vkey=${PUBLIC_VKEY}
auto_reconnection=${NPC_AUTO_RECONNECTION}
crypt=${NPC_CRYPT}
compress=${NPC_COMPRESS}
remark=${NPC_REMARK}

[web-admin]
mode=${NPC_WEB_ADMIN_MODE}
host=admin.${DOMAIN}
target_addr=127.0.0.1:${WEB_PORT}

[web-file]
mode=${NPC_WEB_FILE_MODE}
host=file.${DOMAIN}
target_addr=127.0.0.1:${NPC_FILE_SERVER_PORT}

[file]
mode=${NPC_FILE_MODE}
server_port=${NPC_FILE_SERVER_PORT}
local_path=${NPC_FILE_LOCAL_PATH}
strip_pre=${NPC_FILE_STRIP_PRE}

TEMPEOF

MODE=${MODE:-all}

if [ "$MODE" = "nps" ]; then
    echo "Starting NPS..."
    /nps &
    nps_pid=$!
    wait $nps_pid
elif [ "$MODE" = "npc" ]; then
    echo "Starting NPC..."
    /npc &
    npc_pid=$!
    wait $npc_pid
else
    echo "Starting NPS..."
    /nps &
    nps_pid=$!
    echo "Starting NPC..."
    /npc &
    npc_pid=$!
    wait $nps_pid
    wait $npc_pid
fi
