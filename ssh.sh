# remote:8080 -> localhost:22 proxy for local
ssh -v -N -R  8080:localhost:22 user@remote
# local:22 -> remote:8080 proxy for remote
ssh -v -N -L  remote:8080:22 user@remote
