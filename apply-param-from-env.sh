# put the following into makefile 

ifneq (,$(wildcard .env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif
