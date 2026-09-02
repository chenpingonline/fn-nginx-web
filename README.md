# Fn-Nginx

Fn-Nginx 是一个面向飞牛 fnOS 的原生 Nginx 反向代理可视化管理应用。

它自带独立的 Nginx Open Source 1.30.4，不读取、不修改、也不会重启飞牛系统 Nginx；不依赖 Docker，管理后台通过 fnOS 统一网关和 Unix Socket 提供。

## 功能

- HTTP 与手动证书 HTTPS 反向代理
- 多域名、独立监听端口、默认站点 `*`
- WebSocket、SSE/流式传输和大文件请求体
- 上游 HTTP/HTTPS、上游 TLS 校验开关
- Nginx 配置生成与 `nginx -t` 预检
- 原子替换、平滑 reload、激活失败自动回滚
- 配置历史与恢复为草稿
- Nginx 访问日志、错误日志和管理服务日志
- fnOS 管理员 Header 校验与变更请求标识
- 普通 `fnproxy` package 用户运行
- x86_64 与 ARM64 原生 FPK，不依赖 Docker

## 架构

```text
fnOS 桌面
   ↓
fnOS 统一网关 /app/fnproxy/
   ↓
TRIM_APPDEST/app.sock
   ↓
Fn-Nginx Go 管理服务
   ↓
配置生成、nginx -t、平滑重载与回滚
   ↓
应用自带的独立 Nginx 1.30.4
   ↓
NAS 服务 / Docker 服务 / 局域网设备
```

默认无规则时，独立 Nginx 监听 `9080` 并返回 404。首版只允许 `1024–65535` 端口，因此不需要 root 权限。

## 与系统 Nginx 的隔离

Fn-Nginx 只使用自己的 `TRIM_APPDEST`、`TRIM_PKGETC`、`TRIM_PKGVAR` 和 `TRIM_PKGTMP` 目录，不会访问 `/etc/nginx`、`/usr/trim/nginx`，也不会执行 `systemctl restart nginx`。

> 为兼容已经安装的测试版，内部应用 ID、统一网关路径和运行用户仍保留为 `fnproxy`；这不会影响桌面展示名称和 FPK 文件名。

## Nginx 核心

x86_64 与 ARM64 核心现在都从同一份 Nginx 1.30.4 官方源码编译，并使用相同的模块和静态链接参数。两个包不依赖 fnOS 自带的 glibc、OpenSSL、PCRE 或 zlib 版本。

```text
官方源码 SHA-256：4261dc90e9e47c1c4041276e9aaa3d48ebe2e664f728e14fa95ae6c67d57a08b

x86_64 核心 SHA-256：8801e2de7cd4aee8153ca6bd68d5c13a0dcf62827e5e8de6bf1fc1e7c1482486
ARM64  核心 SHA-256：2eb14d5f26aad8066b0a3ce206915a7b591a735ef12fe9d23baf62fac0d6720c
```

核心包含 HTTPS、HTTP/2、Real IP、状态页、Auth Request，以及 Stream、Stream TLS 和 TLS SNI 预读取模块。当前 0.1.0 管理页面只开放 HTTP/HTTPS 反向代理，TCP/UDP 规则编辑器留待后续版本。

完整构建参数和来源记录见 `third_party/nginx/BUILD.md`。已编译核心发布在 `nginx-core-1.30.4-r1` Release 中。

## 构建 FPK

要求：Go 1.22+、GNU tar、curl、Python 3 和 `file`。

```bash
make test
make build-x86
make build-arm64
# 或
make build-all
```

输出：

```text
dist/Fn-Nginx-0.1.0-x86.fpk
dist/Fn-Nginx-0.1.0-arm64.fpk
```

构建脚本会下载固定的自编译静态 Nginx 核心并校验 SHA-256。二进制不直接提交到源码分支，避免仓库快速膨胀。也可以通过 `NGINX_BINARY=/path/to/nginx` 提供本地文件，但仍必须通过固定摘要校验。

## 重新编译 Nginx 核心

GitHub Actions 工作流 `.github/workflows/compile-nginx-static.yml` 会从官方源码同时生成 Linux x86_64 和 AArch64 静态二进制，并发布到固定 Release。

本地有 Docker Buildx 与 QEMU 时，也可以运行：

```bash
./scripts/build-nginx.sh x86
./scripts/build-nginx.sh arm64
```

## 测试

```bash
make integration
make release
```

`tests/integration.sh` 会启动临时管理服务、独立 Nginx、HTTP 上游和临时自签名证书，验证 HTTP、HTTPS、配置应用、历史版本及平滑重载。

## 当前限制

- 不支持 32 位 ARMv7。
- 不直接监听 80/443，不申请 root 或 `CAP_NET_BIND_SERVICE`。
- HTTPS 证书目前需要手动导入 PEM，尚未内置 ACME 自动申请和续签。
- 暂未提供 TCP/UDP Stream、复杂 location、正则 rewrite、缓存和任意原始 Nginx 指令编辑。
- 发布前仍需分别在实体 x86_64、ARM64 fnOS 设备上完成安装验收。

## 许可证

Fn-Nginx 源码使用 MIT License。Nginx Open Source 以及静态链接组件的许可证和来源说明见 `NGINX_LICENSE`、`NOTICE` 与 `THIRD_PARTY_LICENSES.md`。
