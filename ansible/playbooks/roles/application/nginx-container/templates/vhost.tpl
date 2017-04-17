server {
    listen 0.0.0.0:80 default;

    server_name _;


    location / {
        resolver 127.0.0.11 ipv6=off valid=5s;
        set $upstream_app {{ application_container_name }};
        proxy_pass http://$upstream_app:8000;
    }
}
