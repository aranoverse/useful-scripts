arch:
	./scripts/arch.sh "TARGET_REPO"

.PHONY: remake
remake:
	git pull; \
	docker-compose -f "$(FILE)" build ;\
	docker-compose -f "$(FILE)" down ; \
	docker-compose -f "$(FILE)" up -d ;

.PHONY: remake-api
remake-api:
	make remake FILE="API_COMPOSE"

HOST:=YOUER_HOST

.PHONY: reapi
reapi:
	ssh "$(HOST)" "cd /home/ubuntu/TARGET_REPO && make remake-api"

