# OpenVPN Client Xray

**基于 Docker 和 Xray，转化 OpenVPN 为 Socks、HTTP、端口转发等**

**Based on Docker and Xray, transform OpenVPN to Socks, HTTP, port forward, etc.**

[Docker Hub](https://hub.docker.com/r/pillarszhang/openvpn-client-xray)

![Docker Image Version](https://img.shields.io/docker/v/pillarszhang/openvpn-client-xray)
![Docker Image Size for amd64](https://flat.badgen.net/docker/size/pillarszhang/openvpn-client-xray/latest/amd64?label=amd64)
![Docker Image Size for arm64](https://flat.badgen.net/docker/size/pillarszhang/openvpn-client-xray/latest/arm64?label=arm64)
![Docker Image Size for ppc64le](https://flat.badgen.net/docker/size/pillarszhang/openvpn-client-xray/latest/ppc64le?label=ppc64le)
![Docker Image Size for s390x](https://flat.badgen.net/docker/size/pillarszhang/openvpn-client-xray/latest/s390x?label=s390x)
![Docker Image Size for arm/v7](https://flat.badgen.net/docker/size/pillarszhang/openvpn-client-xray/latest/arm/v7?label=arm/v7)
![Docker Image Size for arm/v7](https://flat.badgen.net/docker/size/pillarszhang/openvpn-client-xray/latest/arm/v6?label=arm/v6)

[Github](https://github.com/PillarsZhang/openvpn-client-xray)

![GitHub release (latest by date)](https://img.shields.io/github/v/release/PillarsZhang/openvpn-client-xray)

## 背景

- [Xray (Project X)](https://xtls.github.io/)：高可定制化的路由系统，满足各类使用需求，充分发挥网络性能。
- [OpenVPN](https://openvpn.net/)：Secure access and network connectivity reimagined.

将 Xray 和 OpenVPN 运行在同一容器，提供了一些配置模板和启动脚本。

## 开始（Quick Start）

### 配置

当前目录下：

- `config`
    - `config/openvpn.ovpn` -> OpenVPN 配置文件
    - `config/xray.json` -> Xray 配置文件 [模板](config/xray.json)
- `docker-compose.yml` -> 如果使用 docker compose（推荐）[模板](docker-compose.yml)

将 OpenVPN 配置文件重命名并放入 `config/openvpn.ovpn`；

修改 `config/xray.json` 文件，根据需求增删 [`inbounds`](https://xtls.github.io/config/inbound.html#inboundobject) 内的入站连接；

以下两种启动方式将 `config` 目录挂载至容器内的 `/root/config`，并且对应 Xray 配置文件 [模板](config/xray.json) 进行端口映射：14850（端口转发）、14851（Socks 代理）、14852（HTTP 代理）。

### 使用 [docker compose](https://docs.docker.com/compose/cli-command/)（推荐）

**启动**
```
# docker compose up
docker compose up -d
```

**日志**
```
docker compose logs
# docker compose logs -t -f
```

<details><summary>正常输出（示例）</summary>
<p>

```
> start-openvpn-xray ...
> Replace '${DOCKER_IP}' to '172.17.0.2' in /root/config/xray.json ...
< Replace done
> Launch OpenVPN ...
> Launch Xray ...
< Wait OpenVPN or Xray exit ...
2022-04-21 14:20:16 --cipher is not set. Previous OpenVPN version defaulted to BF-CBC as fallback when cipher negotiation failed in this case. If you need this fallback please add '--data-ciphers-fallback BF-CBC' to your configuration and/or add BF-CBC to --data-ciphers.
2022-04-21 14:20:16 OpenVPN 2.5.6 x86_64-alpine-linux-musl [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [MH/PKTINFO] [AEAD] built on Mar 24 2022
2022-04-21 14:20:16 library versions: OpenSSL 1.1.1l  24 Aug 2021, LZO 2.10
Xray 1.5.4 (Xray, Penetrates Everything.) Custom (go1.17.8 linux/amd64)
A unified platform for anti-censorship.
2022-04-21 14:20:16 NOTE: the current --script-security setting may allow this configuration to call user-defined scripts
2022/04/21 14:20:16 [Info] infra/conf/serial: Reading config: /dev/stdin
2022-04-21 14:20:16 TCP/UDP: Preserving recently used remote address: [AF_INET]*.*.*.*:*
2022-04-21 14:20:16 UDP link local: (not bound)
2022-04-21 14:20:16 UDP link remote: [AF_INET]*.*.*.*:*
2022/04/21 14:20:16 [Warning] core: Xray 1.5.4 started
2022-04-21 14:20:16 WARNING: 'link-mtu' is used inconsistently, local='link-mtu 1541', remote='link-mtu 1542'
2022-04-21 14:20:16 WARNING: 'comp-lzo' is present in remote config but missing in local config, remote='comp-lzo'
2022-04-21 14:20:16 [*.*.*.*] Peer Connection Initiated with [AF_INET]*.*.*.*:*
2022-04-21 14:20:18 Options error: Unrecognized option or missing or extra parameter(s) in [PUSH-OPTIONS]:1: block-outside-dns (2.5.6)
2022-04-21 14:20:18 TUN/TAP device tun0 opened
2022-04-21 14:20:18 /sbin/ip link set dev tun0 up mtu 1500
2022-04-21 14:20:18 /sbin/ip link set dev tun0 up
2022-04-21 14:20:18 /sbin/ip addr add dev tun0 local 192.168.255.6 peer 192.168.255.5
2022-04-21 14:20:18 /etc/openvpn/up.sh tun0 1500 1552 192.168.255.6 192.168.255.5 init
2022-04-21 14:20:18 WARNING: this configuration may cache passwords in memory -- use the auth-nocache option to prevent this
2022-04-21 14:20:18 Initialization Sequence Completed
```

</p>
</details>

**关闭**

```
docker compose down
```

可选：更新 geo-data（如果需要使用 Xray 路由预定义策略）
```
docker compose run openvpn-client-xray update-geo-data --from-cdn
```

### 使用 docker run

可以参考 [tool](tool) 下的 PowerShell 脚本。

**启动**

```
docker run --rm -it `
    --mount type=bind,source=$(Get-Location)/config,target=/root/config,readonly `
    --mount type=volume,source=openvpn-client-xray_xray-asset,target=/usr/share/xray `
    --device=/dev/net/tun --cap-add=NET_ADMIN `
    -p 127.0.0.1:14850:14850 `
    -p 127.0.0.1:14851:14851 `
    -p 127.0.0.1:14852:14852 `
    pillarszhang/openvpn-client-xray
```

可选：更新 geo-data（如果需要使用 Xray 路由预定义策略）
```
docker run --rm -it `
    --mount type=bind,source=$(Get-Location)/config,target=/root/config,readonly `
    --mount type=volume,source=openvpn-client-xray_xray-asset,target=/usr/share/xray `
    pillarszhang/openvpn-client-xray update-geo-data `
    --from-cdn
```

## 命令行

默认参数请参考 [docker-compose.yml](docker-compose.yml)

```
pillarszhang/openvpn-client-xray <command> [arguments]

commands:
    start-openvpn-xray      启动服务
    update-geo-data         更新 geo-data

arguments for start-openvpn-xray:
    --openvpn-config-file   OpenVPN 配置文件路径
    --openvpn-args          OpenVPN 启动参数
    --openvpn-args-append   OpenVPN 启动附加参数（有需要请在此设置）
    --xray-config-file      Xray 配置文件路径
    --xray-args             Xray 启动参数
    --xray-args-append      Xray 启动附加参数（有需要请在此设置）
    --disable-replace       取消变量替换

arguments for update-geo-data:
    --from-cdn              从 jsDelivr CDN 更新（否则是 Github）
```

## 进阶

在 OpenVPN 服务端没有配置 `duplicate-cn` 的情况下，单个客户端证书只能产生一个连接。此时将该服务部署于公共服务器上，就能被动实现多用户访问。

在将 Docker 内的端口直接映射到公网前（0.0.0.0:14850:14850），请注意安全问题，使用 Xray 的 VLESS 或 VMESS 或许是更好的选择。

`start-openvpn-xray` 命令自动将 Xray 配置文件中的 `${DOCKER_IP}` 占位符替换为该容器在主机中的 IP， 主要用于 Xray 的 listen 监听端口。这是因为在使用 `0.0.0.0` 监听所有网卡时，处于 OpenVPN 虚拟网段中的其它 IP 也能访问这个端口，有安全隐患（可以使用 `--disable-replace` 取消变量替换）。