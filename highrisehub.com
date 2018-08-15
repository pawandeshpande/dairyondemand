# Here we define a cluster of hunchentoot servers
# this can later be extend for load-balancing
# if we had more instances of hunchentoot. In this
# case i only have one instance running.
upstream hunchentoot {
    server 127.0.0.1:4244;
}

server {
    listen 80;
    server_name *.amazonaws.com www.highrisehub.com; 

    rewrite ^(.*)/$ $1/index.html;

    # General request handling this will match all locations
    location / {

        root /data/www/highrisehub.com/public;

        # Define custom HTTP Headers to be used when proxying
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;


        # if the requested file does not exist then
        # rewrite to the correct hunchentoot path
        # so that the proxy_pass can catch and pass on
        # to hunchentoot correctly - proxy_pass
        # cannot have anything but the servername/ip in it
        # else nginx complains so we have to rewrite and then
        # catch in another location later

        if (!-f $request_filename) {
                rewrite ^/(.*)$ /highrisehub/$1 last;
                break;
        }

    }

    location /hhub/ {
        # proxy to the hunchentoot server cluster
	      proxy_pass http://hunchentoot;
	      proxy_http_version 1.1;
	      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_set_header Host $http_host;
	      proxy_set_header X-Real-IP $remote_addr;
     }

}

