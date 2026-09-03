NAME		= inception
COMPOSE		= docker compose -f ./srcs/docker-compose.yml
DATA_DIR	= /home/abbenmou/data

all: build

build:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	$(COMPOSE) up --build -d

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

down:
	$(COMPOSE) down

clean: down
	$(COMPOSE) down --rmi all --volumes

fclean: clean
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all build re start stop down clean fclean