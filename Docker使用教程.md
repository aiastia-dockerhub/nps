# NPS Docker Compose 使用教程

## 简介

NPS 提供了三种不同的 Docker 镜像：
1. `aiastia/nps` - NPS 服务端
2. `aiastia/npc` - NPC 客户端
3. `aiastia/npsc` - NPS+NPC 集成版

## Docker Compose 配置文件

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'
```

services:
  # NPS 服务端
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
```

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
  npc:
    image: aiastia/npc:latest
    container_name: npc
    restart: unless-stopped
    depends_on:
      - nps
    environment:
      - NPC_SERVER_ADDR=nps
      - NPC_CONN_TYPE=tcp
      - NPC_VKEY=your_vkey
      - NPC_AUTO_RECONNECTION=true
      - NPC_CRYPT=true
      - NPC_COMPRESS=true
      - NPC_REMARK=npc-client
      - NPC_WEB_ADMIN_MODE=https
      - NPC_WEB_FILE_MODE=http
      - NPC_FILE_MODE=file
      - NPC_FILE_SERVER_PORT=8081
      - NPC_FILE_LOCAL_PATH=/file/
      - NPC_FILE_STRIP_PRE=/
```

  # NPSC 集成版
  npsc:
    image: aiastia/npsc:latest
    container_name: npsc
    restart: unless-stopped
    ports:
      - "8081:8080"  # Web管理界面端口
      - "8025:8024"  # 网桥端口
      - "8089:8088"  # HTTP代理端口
      - "4444:4443"  # HTTPS代理端口
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

## 使用说明

1. 创建并启动服务：
```bash
docker compose up -d
```

2. 停止服务：
```bash
docker compose down
```

3. 查看日志：
```bash
# 查看所有服务日志
docker compose logs

# 查看特定服务日志
docker compose logs nps
docker compose logs npc
docker compose logs npsc
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

## 注意事项

1. 请妥善保管配置文件和SSL证书
2. 建议修改默认的Web管理密码
3. 生产环境建议使用SSL加密
4. 确保防火墙开放相应端口
5. 定期备份配置文件

## 健康检查

所有镜像都包含了健康检查机制，可以通过以下命令查看容器状态：

```bash
docker ps -a --filter name=nps
docker ps -a --filter name=npc
docker ps -a --filter name=npsc
```

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
