#!/bin/bash
# Скрипт для сборки прошивки ZMK в Docker

set -e

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Сборка прошивки ZMK в Docker ===${NC}"

# Создание директории для выходных файлов
mkdir -p output

# Сборка Docker образа
echo -e "${GREEN}Шаг 1: Сборка Docker образа...${NC}"
docker build -t zmk-charybdis-build .

# Запуск контейнера и сборка прошивки
echo -e "${GREEN}Шаг 2: Сборка прошивки...${NC}"
docker run --rm \
    -v "$(pwd)/output:/workspace/output" \
    zmk-charybdis-build

echo -e "${GREEN}=== Готово! ===${NC}"
echo -e "${BLUE}Прошивки находятся в директории: ${GREEN}./output/${NC}"
ls -lh output/*.uf2
