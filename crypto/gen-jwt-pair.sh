#!/bin/bash

PRIVATE_KEY="app.key"
PUBLIC_KEY="app.pub"

openssl genpkey -algorithm RSA -out $PRIVATE_KEY -pkeyopt rsa_keygen_bits:2048

openssl rsa -pubout -in $PRIVATE_KEY -out $PUBLIC_KEY

echo "private: $PRIVATE_KEY"
echo "public: $PUBLIC_KEY"
