package main

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
)

func main() {
	user := "user"
	password := "pwd"

	saltData := make([]byte, 16)
	rand.Read(saltData)

	salt := hex.EncodeToString(saltData)

	hash := hmac.New(sha256.New, []byte(salt))
	hash.Write([]byte(password))

	fmt.Printf("%s\n", salt)

	rpcauth := fmt.Sprintf("%s:%s$%x", user, salt, hash.Sum(nil))
	fmt.Println(rpcauth)
}
