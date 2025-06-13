sub vcl_deliver {
  unset resp.http.x-served-by;
  unset resp.http.server;
  unset resp.http.via;
  unset resp.http.cf-cache-status;
  unset resp.http.cf-ray;
  unset resp.http.server-timing;
  return(deliver);
}
