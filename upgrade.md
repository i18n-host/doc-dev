# 自动更新系统设计

## 客户端

~/.config/xxx/update.yml

channel = xxx

更新频道

1. alpha
2. beta
3. stable


## 服务器

通过域名的 txt 记录分发的最新版本

域名前缀为 项目名 `-` 版本号。

比如 `i18-stable.u-01.eu.org` 的 TXT 记录，格式为

`版本号 网址1 网址2`

版本号编码： vbyte 编码后再用 base64url 编码。

网址只需要域名，会自动生成路径后缀:

`https://d.u-01.eu.org/i18/0.2.1/aarch64-apple-darwin.tar`

因为TXT记录字符数限制为255个，所以采用一些压缩的写法。

比如 `Gup51/v` ， 首个大写字母`G`表示这是`github release`，其路径为

`https://github.com/up51/v/releases/download/i18/0.2.1/aarch64-apple-darwin.tar`

有比如 `up[0-2].xxx.com` 表示 `up0.xxx.com` 、`up1.xxx.com`、`up2.xxx.com` 这几个域名都可以下载。

通过 `DOH` 解析域名的 `TXT` 记录 （类似下面）。

```
curl -s 'https://doh.360.cn/resolve?name=i18-stable.u-01.eu.org&type=TXT' | jq

curl -s 'https://doh.pub/resolve?name=i18-stable.u-01.eu.org&type=TXT' | jq

curl -s 'https://dns.google/resolve?name=i18-stable.u-01.eu.org&type=TXT' | jq

curl -s 'https://dns.alidns.com/resolve?name=i18-stable.u-01.eu.org&type=TXT' | jq

curl -H 'Accept: application/dns-json' -s 'https://cloudflare-dns.com/dns-query?name=i18-stable.u-01.eu.org&type=TXT' | jq

curl -H 'Accept: application/dns-json' -s 'https://doh.opendns.com/dns-query?name=i18-stable.u-01.eu.org&type=TXT' | jq

curl -H 'Accept: application/dns-json' -s 'https://doh.sb/dns-query?name=i18-stable.u-01.eu.org&type=TXT'  -L|jq
```

抽取返回响应`Answer`中`type`为`16`的值

`tar` 包中，`tar.zst` 为内容，`sign` 为签名。

`sign` 的签名算法为 `sha3-512` + `ed25519-ph` 。

## 版本发布逻辑

每个 `version` 都会发布到 `alpha` ，并记录在 `ver.yml`，格式为

```
0.1.3 日期 发布的版本
```

alpha 15天之后会自动变成 beta

beta 15天之后会自动变成 stable

如果出现问题，把出问题的版本注释掉，就会忽略

转变之前，会对比每个频道的最新版本号，如果小于这个最新版本号，就会忽略（比如`1.2.0`不会覆盖`2.0.0`）


## CDN

使用 wise 信用卡限额，避免费用超标

0. cloudflare
1. [aws cloudfront](https://aws.amazon.com/cn/campaigns/cloudfront/) 每月免费1T
2. [gcore cdn](https://gcore.com/cdn) 每月免费1T
3. [fastly](https://www.fastly.com/pricing) 每月额度50美元（约相当于 250 GB 的免费流量）
4. [阿里云国际版 边缘安全加速（原 DCDN）](https://www.alibabacloud.com/campaign/edge-security-acceleration-2025) 免费无限流量版

### cloudflare 配置

创建一个 R2 的存储，然后绑定域名

`sh/dist/dist.sh` 会安装 `@3-/updist` 会读取配置，自动上传并发布到 github release

### fastly 配置

1. 创建 CDN 服务

https://manage.fastly.com/configure

点击右侧 `Edit configuration`

修改 Origins -> Hosts -> 源站域名旁边的编辑图标，启用 IPV6，在 Settings 中启用 HTTP3

修改 Settings → Create a cache setting ，缓存都改为 99999999 秒（大约3年），Action 选 Do nothing now

然后点击右上角的激活，选择 Production

先添加 Show VCL ，然后上传 Custom VCL，然后激活

如果激活按钮不可以，刷新页面可以看到报错

注意，删除请求头需要点击域名上面的 `Service summary`，再点击右上角的`Purge`的图标中清理缓存之后才能看到生效。

2. 创建域名证书

https://manage.fastly.com/network/domains



