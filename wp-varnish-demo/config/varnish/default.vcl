vcl 4.1;

import std;

# Define backend servers
backend wordpress {
    .host = "wordpress";
    .port = "80";
    .connect_timeout = 5s;
    .first_byte_timeout = 90s;
    .between_bytes_timeout = 2s;
}

# Define ACL for purge requests
acl purge {
    "localhost";
    "127.0.0.1";
    "::1";
    "wordpress";
}

# Define ACL for admin IPs (optional)
acl admin {
    "localhost";
    "127.0.0.1";
    "::1";
}

sub vcl_recv {
    # Handle purge requests
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
            return(synth(405, "Not allowed."));
        }
        return (purge);
    }

    # Handle ban requests
    if (req.method == "BAN") {
        if (!client.ip ~ purge) {
            return(synth(405, "Not allowed."));
        }
        ban("req.url ~ " + req.url);
        return(synth(200, "Ban added"));
    }

    # Normalize host header
    set req.http.Host = regsub(req.http.Host, ":[0-9]+", "");

    # Remove port from Host header
    if (req.http.host ~ ":") {
        set req.http.Host = regsub(req.http.Host, ":[0-9]+", "");
    }

    # Check for WordPress cookies that indicate logged-in users
    if (req.http.Cookie ~ "wordpress_logged_in_" || 
        req.http.Cookie ~ "comment_author_" ||
        req.http.Cookie ~ "wp-postpass_" ||
        req.http.Cookie ~ "wordpress_test_cookie" ||
        req.http.Cookie ~ "woocommerce_cart_hash" ||
        req.http.Cookie ~ "woocommerce_items_in_cart") {
        return (pass);
    }

    # Don't cache POST requests
    if (req.method == "POST") {
        return (pass);
    }

    # Don't cache admin area
    if (req.url ~ "^/wp-admin" || req.url ~ "^/wp-login.php") {
        return (pass);
    }

    # Don't cache AJAX requests
    if (req.http.X-Requested-With == "XMLHttpRequest") {
        return (pass);
    }

    # Don't cache WooCommerce cart/checkout
    if (req.url ~ "/cart" || req.url ~ "/checkout" || req.url ~ "/my-account") {
        return (pass);
    }

    # Don't cache search results
    if (req.url ~ "\?s=") {
        return (pass);
    }

    # Remove cookies for static assets
    if (req.url ~ "\.(css|js|png|gif|jp(e)?g|swf|ico|woff|woff2|ttf|eot|svg)$") {
        unset req.http.Cookie;
        return (hash);
    }

    # Remove cookies for feeds
    if (req.url ~ "\.(rss|atom)$") {
        unset req.http.Cookie;
        return (hash);
    }

    # Remove cookies for sitemap
    if (req.url ~ "sitemap") {
        unset req.http.Cookie;
        return (hash);
    }

    # Remove cookies for robots.txt
    if (req.url ~ "robots\.txt$") {
        unset req.http.Cookie;
        return (hash);
    }

    # Remove cookies for non-logged-in users
    if (!req.http.Cookie ~ "wordpress_logged_in_") {
        unset req.http.Cookie;
    }

    # Add X-Forwarded-For header
    if (req.http.X-Forwarded-For) {
        set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
    } else {
        set req.http.X-Forwarded-For = client.ip;
    }

    # Add X-Real-IP header
    set req.http.X-Real-IP = client.ip;

    return (hash);
}

sub vcl_hash {
    hash_data(req.url);
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }
    return (lookup);
}

sub vcl_hit {
    if (obj.ttl >= 0s) {
        return (deliver);
    }
    if (obj.ttl + obj.grace > 0s) {
        return (deliver);
    }
    return (fetch);
}

sub vcl_miss {
    return (fetch);
}

sub vcl_backend_response {
    # Set grace period
    set beresp.grace = 1h;

    # Don't cache 404s
    if (beresp.status == 404) {
        set beresp.ttl = 0s;
        set beresp.uncacheable = true;
        return (deliver);
    }

    # Don't cache 5xx errors
    if (beresp.status >= 500) {
        set beresp.ttl = 0s;
        set beresp.uncacheable = true;
        return (deliver);
    }

    # Cache static assets for longer
    if (bereq.url ~ "\.(css|js|png|gif|jp(e)?g|swf|ico|woff|woff2|ttf|eot|svg)$") {
        set beresp.ttl = 1d;
        set beresp.grace = 6h;
    }

    # Cache feeds for shorter time
    if (bereq.url ~ "\.(rss|atom)$") {
        set beresp.ttl = 1h;
        set beresp.grace = 1h;
    }

    # Default cache time for pages
    if (beresp.ttl <= 0s) {
        set beresp.ttl = 1h;
        set beresp.grace = 1h;
    }

    # Add cache headers
    set beresp.http.X-Cacheable = "YES";
    set beresp.http.X-Cache-TTL = beresp.ttl;
    set beresp.http.X-Cache-Grace = beresp.grace;

    return (deliver);
}

sub vcl_deliver {
    # Add cache hit/miss headers
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
        set resp.http.X-Cache-Hits = obj.hits;
    } else {
        set resp.http.X-Cache = "MISS";
    }

    # Add Varnish version
    set resp.http.X-Varnish = req.xid;

    # Remove server signature
    unset resp.http.Server;
    unset resp.http.X-Powered-By;

    return (deliver);
}

sub vcl_pass {
    return (fetch);
}

sub vcl_pipe {
    return (pipe);
}

sub vcl_purge {
    return (synth(200, "Purged"));
}

sub vcl_synth {
    set resp.http.Content-Type = "text/html; charset=utf-8";
    set resp.http.Retry-After = "5";
    synthetic( {"<!DOCTYPE html>
<html>
  <head>
    <title>"} + resp.status + " " + resp.reason + {"</title>
  </head>
  <body>
    <h1>Error "} + resp.status + " " + resp.reason + {"</h1>
    <p>"} + resp.reason + {"</p>
    <h3>Guru Meditation:</h3>
    <p>XID: "} + req.xid + {"</p>
    <hr>
    <p>Varnish cache server</p>
  </body>
</html>
"} );
    return (deliver);
}
