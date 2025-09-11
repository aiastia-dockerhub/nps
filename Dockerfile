FROM alpine:3.8

# 设置元数据标签
LABEL maintainer="docker <docker@gmail.com>" \
      version="0.26.10" \
      description="NPS - A lightweight, high-performance intranet penetration proxy server"

# 设置环境变量
ENV WEB_PASSWORD=!password \
    PUBLIC_VKEY=12345678 \
    BRIDGE_PORT=8024 \
    HTTP_PROXY_PORT=8088 \
    HTTPS_PROXY_PORT=4443 \
    DOMAIN=nps.youdomain.com \
    TZ=Asia/Shanghai \
    NPS_VERSION=0.26.10 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    WEB_OPEN_SSL=true \
    WEB_USERNAME=admin \
    WEB_PORT=8080 \
    WEB_IP=0.0.0.0 \
    WEB_BASE_URL= \
    WEB_CERT_FILE=conf/server.pem \
    WEB_KEY_FILE=conf/server.key \
    AUTH_KEY=test \
    AUTH_CRYPT_KEY=1234567812345678 \
    ALLOW_USER_LOGIN=true \
    ALLOW_USER_REGISTER=false \
    ALLOW_USER_CHANGE_USERNAME=false \
    ALLOW_FLOW_LIMIT=true \
    ALLOW_RATE_LIMIT=true \
    ALLOW_TUNNEL_NUM_LIMIT=true \
    ALLOW_LOCAL_PROXY=true \
    ALLOW_CONNECTION_NUM_LIMIT=true \
    ALLOW_MULTI_IP=false \
    SYSTEM_INFO_DISPLAY=true \
    HTTP_CACHE=true \
    HTTP_CACHE_LENGTH=100 \
    NPC_SERVER_ADDR=127.0.0.1 \
    NPC_CONN_TYPE=tcp \
    NPC_AUTO_RECONNECTION=true \
    NPC_CRYPT=true \
    NPC_COMPRESS=true \
    NPC_REMARK=nps \
    NPC_WEB_ADMIN_MODE=https \
    NPC_WEB_FILE_MODE=http \
    NPC_FILE_MODE=file \
    NPC_FILE_SERVER_PORT=8081 \
    NPC_FILE_LOCAL_PATH=/file/ \
    NPC_FILE_STRIP_PRE=/ \
    RUNMODE=dev \
    LOG_LEVEL=7 \
    FLOW_STORE_INTERVAL=1


# 安装必要的工具和设置时区
RUN set -x && \
    apk add --no-cache --virtual .build-deps wget tzdata ca-certificates && \
    apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/${TZ:-Asia/Shanghai} /etc/localtime && \
    echo "${TZ:-Asia/Shanghai}" > /etc/timezone && \
    apk del .build-deps

# 设置工作目录
WORKDIR /app

# 下载并解压NPS和NPC
RUN set -x && \
    # 下载NPS服务端和客户端
    wget --no-check-certificate https://github.com/ehang-io/nps/releases/download/v${NPS_VERSION}/linux_amd64_server.tar.gz && \
    tar xzf linux_amd64_server.tar.gz && \
    mv ./nps /app/nps && \
    wget --no-check-certificate https://github.com/ehang-io/nps/releases/download/v${NPS_VERSION}/linux_amd64_client.tar.gz && \
    tar xzf linux_amd64_client.tar.gz && \
    mv ./npc /app/npc && \
    chmod +x /app/nps /app/npc && \
    rm -rf *.tar.gz && \
    mkdir -p /file && \
    # 下载其他平台的客户端（用于提供下载）
    wget --no-check-certificate https://github.com/ehang-io/nps/releases/download/v${NPS_VERSION}/windows_amd64_client.tar.gz -O /file/windows_amd64_client.tar.gz && \
    wget --no-check-certificate https://github.com/ehang-io/nps/releases/download/v${NPS_VERSION}/windows_386_client.tar.gz -O /file/windows_386_client.tar.gz && \
    wget --no-check-certificate https://github.com/ehang-io/nps/releases/download/v${NPS_VERSION}/linux_amd64_client.tar.gz -O /file/linux_amd64_client.tar.gz

# 创建必要的目录
RUN mkdir -p /conf

# 复制entrypoint脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 创建数据卷
VOLUME ["/conf"]

# 暴露端口
#EXPOSE 8088 4443 8024 8080

# 添加健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:8080/ || exit 1

# 设置入口点
ENTRYPOINT ["/entrypoint.sh"]
