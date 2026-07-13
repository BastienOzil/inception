.SILENT:
NAME		= inception
LOGIN		= bozil
DATA_PATH	= /home/$(LOGIN)/data
COMPOSE		= docker compose -f srcs/docker-compose.yml

all: up

up: data-dirs
	$(COMPOSE) up -d --build

data-dirs:
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart: down up

clean: down
	docker system prune -af

fclean: clean
	sudo rm -rf $(DATA_PATH)
	docker volume rm db_data wp_data 2>/dev/null || true

re: fclean all

status:
	docker ps -a
	docker volume ls
	docker network ls | grep inception

logs:
	$(COMPOSE) logs -f

.PHONY: all up down stop start restart clean fclean re status logs data-dirs