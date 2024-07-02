#!/usr/bin/env bash

openssl pkcs8 -topk8 -inform PEM -outform PEM -in github-app.pem -out github-app.key -nocrypt