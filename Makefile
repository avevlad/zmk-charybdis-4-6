# Makefile для удобной сборки прошивки ZMK

.PHONY: help build clean build-image docker-compose-up docker-compose-down

# По умолчанию показать помощь
help:
	@echo "Доступные команды:"
	@echo "  make build              - Собрать прошивку в Docker (рекомендуется)"
	@echo "  make build-image        - Собрать только Docker образ"
	@echo "  make docker-compose-up  - Собрать через docker-compose"
	@echo "  make clean              - Удалить выходные файлы"
	@echo "  make clean-all          - Удалить выходные файлы и Docker образ"
	@echo ""
	@echo "Прошивки будут в директории: ./output/"

# Основная сборка
build:
	@./build-docker.sh

# Сборка только образа
build-image:
	@echo "Сборка Docker образа..."
	@docker build -t zmk-charybdis-build .

# Сборка через docker-compose
docker-compose-up:
	@docker-compose up

docker-compose-down:
	@docker-compose down

# Очистка выходных файлов
clean:
	@echo "Удаление выходных файлов..."
	@rm -rf output/*
	@echo "Готово!"

# Полная очистка
clean-all: clean
	@echo "Удаление Docker образа..."
	@docker rmi zmk-charybdis-build || true
	@docker-compose down -v || true
	@echo "Готово!"
