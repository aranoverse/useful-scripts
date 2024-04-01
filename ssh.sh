# remote:8080 -> localhost:22 proxy for local
ssh -v -N -R  8080:localhost:22 user@remote
# local:6666 -> remote:8080 proxy for remote
ssh -v -N -L  6666:localhost:8080 user@remote

#  proxy_port:[target_host:port]
