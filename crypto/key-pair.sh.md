
```shell
openssl genpkey -algorithm RSA -out private.pem -noout -aes256 -pass pass:password
openssl rsa -pubout -in private.pem -out public.pem -passin pass:password
```

```shell
openssl genpkey -algorithm RSA -out private.pem -aes256
openssl rsa -pubout -in private.pem -out public.pem
```

```shell
openssl rsa -in private.pem -text -noout -passin pass:password
openssl rsa -pubin -in public.pem -text -noout
```


