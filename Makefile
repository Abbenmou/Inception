all: build

build:
	@mkdir -p /home/abbenmou/data/mariadb
	@mkdir -p /home/abbenmou/data/wordpress
	docker compose -f ./srcs/docker-compose.yml up --build -d

stop:
	docker compose -f ./srcs/docker-compose.yml stop

start:
	docker compose -f ./srcs/docker-compose.yml start

down:
	docker compose -f ./srcs/docker-compose.yml down

clean:
	docker compose -f ./srcs/docker-compose.yml down --rmi all --volumes

fclean:
	sudo rm -rf /home/abbenmou/data

re: fclean all

.PHONY: all build re start stop clean fclean