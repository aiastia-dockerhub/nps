# NPS Docker 部署教程

## 简介

NPS 提供了三种不同的部署方案：

1. `aiastia/nps` - NPS 服务端：用于部署中央服务器
2. `aiastia/npc` - NPC 客户端：用于部署在需要内网穿透的客户端机器上
3. `aiastia/npsc` - NPS+NPC 集成版：同时包含服务端和客户端功能

## 方案一：部署 NPS 服务端

这个方案适用于需要部署中央服务器的场景。

```yaml
# docker-compose-nps.yml

services:
  nps:
    image: aiastia/nps:latest
    container_name: nps
    restart: unless-stopped
    ports:
      - "8080:8080"  # Web管理界面端口
      - "8024:8024"  # 网桥端口
      - "8088:8088"  # HTTP代理端口
      - "4443:4443"  # HTTPS代理端口
    environment:
      # Web界面设置
      - WEB_USERNAME=admin
      - WEB_PASSWORD=your_password
      - WEB_PORT=8080
      - WEB_IP=0.0.0.0
      - WEB_BASE_URL=
      - WEB_OPEN_SSL=true
      - WEB_CERT_FILE=/conf/server.pem
      - WEB_KEY_FILE=/conf/server.key
      
      # 网络设置
      - BRIDGE_PORT=8024
      - HTTP_PROXY_PORT=8088
      - HTTPS_PROXY_PORT=4443
      - PUBLIC_VKEY=your_vkey
      
      # 认证设置
      - AUTH_KEY=your_auth_key
      - AUTH_CRYPT_KEY=your_crypt_key
      
      # 功能开关
      - ALLOW_USER_LOGIN=true
      - ALLOW_USER_REGISTER=false
      - ALLOW_USER_CHANGE_USERNAME=false
      - ALLOW_FLOW_LIMIT=true
      - ALLOW_RATE_LIMIT=true
      - ALLOW_TUNNEL_NUM_LIMIT=true
      - ALLOW_LOCAL_PROXY=true
      - ALLOW_CONNECTION_NUM_LIMIT=true
      - ALLOW_MULTI_IP=false
      - SYSTEM_INFO_DISPLAY=true
      
      # 缓存设置
      - HTTP_CACHE=true
      - HTTP_CACHE_LENGTH=100
      
      # 运行模式
      - RUNMODE=pro
      - LOG_LEVEL=7
      - FLOW_STORE_INTERVAL=1

  # NPC 客户端
```

启动服务：
```bash
docker compose -f docker-compose-nps.yml up -d
```

## 方案二：部署 NPC 客户端

这个方案适用于需要进行内网穿透的客户端机器。

```yaml
# docker-compose-npc.yml
version: '3.8'

services:
  npc:
    image: aiastia/npc:latest
    container_name: npc
    restart: unless-stopped
    environment:
      - NPC_SERVER_ADDR=your.server.com  # 替换为你的NPS服务器地址
      - NPC_CONN_TYPE=tcp
      - NPC_VKEY=your_vkey              # 与NPS服务端配置的PUBLIC_VKEY相同
      - NPC_AUTO_RECONNECTION=true
      - NPC_CRYPT=true
      - NPC_COMPRESS=true
      - NPC_REMARK=my-client
      - NPC_WEB_ADMIN_MODE=https
      - NPC_WEB_FILE_MODE=http
      - NPC_FILE_MODE=file
      - NPC_FILE_SERVER_PORT=8081
      - NPC_FILE_LOCAL_PATH=/file/
      - NPC_FILE_STRIP_PRE=/
    # 如果需要映射本地端口，添加ports配置
    ports:
      - "8081:8081"  # 示例：映射本地8081端口
```

启动服务：
```bash
docker compose -f docker-compose-npc.yml up -d
```

## 方案三：部署 NPSC 集成版

这个方案适用于需要在同一台机器上同时运行服务端和客户端的场景。

```yaml
# docker-compose-npsc.yml
version: '3.8'

services:
  npsc:
    image: aiastia/npsc:latest
    container_name: npsc
    restart: unless-stopped
    network_mode: host   # 使用 host 模式，直接用宿主机端口
    volumes:
      - ./conf:/app/conf        # 映射配置文件目录
      - ./file:/file            # 映射本地文件目录（对应 NPS 的文件功能）
    environment:
      # Web界面设置
      - WEB_USERNAME=admin
      - WEB_PASSWORD=your_password
      - WEB_PORT=8080
      - WEB_IP=0.0.0.0
      - WEB_BASE_URL=
      - WEB_OPEN_SSL=false
      - WEB_CERT_FILE=/app/conf/server.pem
      - WEB_KEY_FILE=/app/conf/server.key
      
      # 网络设置
      - BRIDGE_PORT=8024
      - HTTP_PROXY_PORT=8088
      - HTTPS_PROXY_PORT=4443
      - PUBLIC_VKEY=your_vkey
      - DOMAIN=your.domain.com
      
      # 认证设置
      - AUTH_KEY=your_auth_key
      - AUTH_CRYPT_KEY=your_crypt_key
      
      # NPC客户端设置
      - NPC_SERVER_ADDR=127.0.0.1
      - NPC_CONN_TYPE=tcp
      - NPC_AUTO_RECONNECTION=true
      - NPC_CRYPT=true
      - NPC_COMPRESS=true
      - NPC_REMARK=npsc-client

```

```

## 常用操作命令

### 查看日志
```bash
# 查看服务端日志
docker compose -f docker-compose-nps.yml logs -f

# 查看客户端日志
docker compose -f docker-compose-npc.yml logs -f

# 查看集成版日志
docker compose -f docker-compose-npsc.yml logs -f
```

### 停止服务
```bash
# 停止服务端
docker compose -f docker-compose-nps.yml down

# 停止客户端
docker compose -f docker-compose-npc.yml down

# 停止集成版
docker compose -f docker-compose-npsc.yml down
```

### 更新镜像
```bash
# 更新服务端
docker compose -f docker-compose-nps.yml pull
docker compose -f docker-compose-nps.yml up -d

# 更新客户端
docker compose -f docker-compose-npc.yml pull
docker compose -f docker-compose-npc.yml up -d

# 更新集成版
docker compose -f docker-compose-npsc.yml pull
docker compose -f docker-compose-npsc.yml up -d
```

4. 更新服务：
```bash
# 拉取最新镜像
docker compose pull

# 重新部署服务
docker compose up -d
```

## 环境变量说明

### 通用环境变量

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| WEB_USERNAME | Web管理界面用户名 | admin |
| WEB_PASSWORD | Web管理界面密码 | your_password |
| WEB_PORT | Web管理界面端口 | 8080 |
| PUBLIC_VKEY | 客户端连接密钥 | your_vkey |
| RUNMODE | 运行模式(dev/pro) | pro |
| LOG_LEVEL | 日志级别(0-7) | 7 |

### NPS/NPSC 特有环境变量

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| BRIDGE_PORT | 网桥端口 | 8024 |
| HTTP_PROXY_PORT | HTTP代理端口 | 8088 |
| HTTPS_PROXY_PORT | HTTPS代理端口 | 4443 |
| AUTH_KEY | API认证密钥 | your_auth_key |
| AUTH_CRYPT_KEY | 加密密钥(16位) | your_crypt_key |
| ALLOW_USER_LOGIN | 允许用户登录 | true |
| ALLOW_USER_REGISTER | 允许用户注册 | false |

### NPC 特有环境变量

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| NPC_SERVER_ADDR | NPS服务器地址 | nps |
| NPC_CONN_TYPE | 连接类型 | tcp |
| NPC_AUTO_RECONNECTION | 自动重连 | true |
| NPC_CRYPT | 启用加密 | true |
| NPC_COMPRESS | 启用压缩 | true |

## 注意事项

1. 使用前请修改所有的默认密码和密钥
2. 确保配置的端口未被其他服务占用
3. 生产环境建议启用SSL
4. 建议定期备份数据
5. 注意检查防火墙设置，确保端口开放

## 安全建议

1. 修改默认的 Web 管理密码
2. 使用复杂的 VKEY 和 AUTH_KEY
3. 限制 IP 访问范围
4. 启用 SSL 加密
5. 禁用不需要的功能
6. 定期更新镜像版本

## 常见问题排查

1. 服务无法启动
   - 检查端口占用
   - 检查环境变量配置
   - 查看容器日志

2. 客户端无法连接
   - 确认 VKEY 配置正确
   - 检查网络连接
   - 确认服务端状态

3. Web界面无法访问
   - 确认端口映射正确
   - 检查防火墙设置
   - 验证用户名密码

## 部署建议

1. **服务端部署 (NPS)**
   - 建议部署在有公网IP的服务器上
   - 确保配置的端口都已开放
   - 使用复杂的 PUBLIC_VKEY 和密码
   - 建议启用SSL以保证安全性

2. **客户端部署 (NPC)**
   - 确保 NPC_SERVER_ADDR 配置正确
   - VKEY 需要与服务端的 PUBLIC_VKEY 匹配
   - 根据需要映射相应的本地端口

3. **集成版部署 (NPSC)**
   - 适用于测试环境或小规模部署
   - 注意端口冲突问题
   - 客户端部分配置了连接到本地服务端

## 注意事项

1. 修改默认密码
2. 使用复杂的 VKEY
3. 及时更新镜像版本
4. 配置合适的端口映射
5. 正确设置防火墙规则

## 日志查看

```bash
# 查看容器日志
docker logs -f nps
docker logs -f npc
docker logs -f npsc
```

## 更新镜像

```bash
# 更新指定镜像
docker pull aiastia/nps:latest
docker pull aiastia/npc:latest
docker pull aiastia/npsc:latest

# 停止并删除旧容器
docker stop nps npc npsc
docker rm nps npc npsc

# 使用新镜像重新启动容器
# (使用上述启动命令重新启动容器)
```
