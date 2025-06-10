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

比如 `i18-nightly.u-01.eu.org` 的 TXT 记录，格式为

`版本号 网址1 网址2`

版本号编码： vbyte 编码后再用 base64url 编码。

网址只需要域名，会自动生成路径后缀:

`https://d.u-01.eu.org/i18/0.2.1/aarch64-apple-darwin.tar`

因为TXT记录字符数限制为255个，所以采用一些压缩的写法。

比如 `Gup51/v` ， 首个大写字母`G`表示这是`github release`，其路径为

`https://github.com/up51/v/releases/download/i18/0.2.1/aarch64-apple-darwin.tar`

有比如 `d|f.u-01.eu.org` 表示 `d.u-01.eu.org` 和 `f.u-01.eu.org` 这两个域名都可以下载。

通过 `DOH` 解析域名的 `TXT` 记录 （类似下面）。

```
curl -s 'https://doh.360.cn/resolve?name=i18-nightly.u-01.eu.org&type=TXT' | jq

curl -s 'https://doh.pub/resolve?name=i18-nightly.u-01.eu.org&type=TXT' | jq

curl -s 'https://dns.google/resolve?name=i18-nightly.u-01.eu.org&type=TXT' | jq

curl -s 'https://dns.alidns.com/resolve?name=i18-nightly.u-01.eu.org&type=TXT' | jq

curl -H 'Accept: application/dns-json' -s 'https://cloudflare-dns.com/dns-query?name=i18-nightly.u-01.eu.org&type=TXT' | jq

curl -H 'Accept: application/dns-json' -s 'https://doh.opendns.com/dns-query?name=i18-nightly.u-01.eu.org&type=TXT' | jq

curl -H 'Accept: application/dns-json' -s 'https://doh.sb/dns-query?name=i18-nightly.u-01.eu.org&type=TXT'  -L|jq
```

抽取返回响应`Answer`中`type`为`16`的值

`tar` 包中，`tar.zst` 为内容，`sign` 为签名。

`sign` 的签名算法为 `sha3-512` + `ed25519-ph` 。


