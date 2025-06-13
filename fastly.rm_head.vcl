sub vcl_deliver {
  #FASTLY deliver
  unset resp.http.x-served-by;
  unset resp.http.server;
  unset resp.http.via;
  unset resp.http.cf-cache-status;
  unset resp.http.cf-ray;
  unset resp.http.server-timing;
  unset resp.http.fastly-debug-path;
  unset resp.http.x-varnish;
  unset resp.http.x-timer;
  unset resp.http.x-cache-hits;
  unset resp.http.x-cache;
  return(deliver);
}
