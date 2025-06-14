sub vcl_fetch {
  #FASTLY fetch;

  # 允许 Fastly 缓存非 200 的响应
  set beresp.cacheable = true;

  # 如果响应状态码是 200，缓存1年
  if (beresp.status == 200) {
    set beresp.ttl = 31536000s; 
  } else {
    # 其他所有状态码的响应，缓存5分钟
    set beresp.ttl = 300s; 
  }
  return(deliver);
}


