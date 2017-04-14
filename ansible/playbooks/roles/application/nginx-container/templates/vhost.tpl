upstream application {
    server application;
}

server {
    listen 0.0.0.0:80 default;

    server_name _;


    location / {
        proxy_pass http://application;
    }
}
