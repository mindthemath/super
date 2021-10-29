run: build
	docker run --rm -tid --name animate-api -p 8080:8080 animate-api

build:
	docker build -t animate-api .

kill:
	docker rm -f animate-api
