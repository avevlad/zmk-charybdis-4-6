# Инструкция по сборке прошивки

Этот проект поддерживает два способа сборки прошивки ZMK:
1. Автоматическая сборка через GitHub Actions (при push в репозиторий)
2. Локальная сборка в Docker

## Способ 1: GitHub Actions (автоматически)

При каждом push в репозиторий GitHub автоматически собирает прошивку:
- Результаты сборки доступны во вкладке **Actions**
- Готовые `.uf2` файлы можно скачать из артефактов workflow

## Способ 2: Локальная сборка в Docker

### Требования
- Docker установлен и запущен
- ~5 GB свободного места для образов и зависимостей

### Вариант A: Использование скрипта (рекомендуется)

```bash
# Сделать скрипт исполняемым
chmod +x build-docker.sh

# Запустить сборку
./build-docker.sh
```

После завершения прошивки будут в директории `output/`:
- `charybdis_dongle.uf2` - прошивка для dongle (с ZMK Studio)
- `charybdis_left.uf2` - прошивка для левой половины
- `charybdis_right.uf2` - прошивка для правой половины
- `settings_reset.uf2` - прошивка для сброса настроек

### Вариант B: Использование docker-compose

```bash
# Сборка и запуск
docker-compose up

# Или в фоновом режиме
docker-compose up -d
```

### Вариант C: Прямые команды Docker

```bash
# Создание директории для выходных файлов
mkdir -p output

# Сборка образа
docker build -t zmk-charybdis-build .

# Запуск сборки
docker run --rm -v "$(pwd)/output:/workspace/output" zmk-charybdis-build
```

### Сборка отдельной конфигурации

Если нужно собрать только одну конфигурацию (например, только dongle):

```bash
docker run --rm -v "$(pwd)/output:/workspace/output" zmk-charybdis-build \
  /bin/bash -c "
    west build -s zmk/app -d build/charybdis_dongle -b nice_nano_v2 -- \
      -DZMK_CONFIG=/workspace/config \
      -DSHIELD=charybdis_dongle \
      -DZMK_EXTRA_MODULES='/workspace/boards' \
      -DCONFIG_ZMK_STUDIO=y \
      -Dstudio-rpc-usb-uart_SNIPPET=y && \
    cp build/charybdis_dongle/zephyr/zmk.uf2 /workspace/output/charybdis_dongle.uf2
  "
```

### Очистка

```bash
# Удалить собранные файлы
rm -rf output/*

# Удалить Docker образ
docker rmi zmk-charybdis-build

# Удалить кеш volumes (если использовали docker-compose)
docker-compose down -v
```

## Прошивка клавиатуры

1. Подключите клавиатуру к компьютеру
2. Переведите её в режим bootloader (обычно двойное нажатие кнопки RESET)
3. Появится USB накопитель (обычно называется `NICENANO`)
4. Скопируйте соответствующий `.uf2` файл на этот накопитель
5. Клавиатура автоматически перезагрузится с новой прошивкой

## Troubleshooting

### Docker не может скачать базовый образ
Проблема с интернет-соединением или Docker Hub. Попробуйте:
```bash
docker pull zmkfirmware/zmk-build-arm:stable
```

### Ошибка "permission denied" при запуске скрипта
```bash
chmod +x build-docker.sh
```

### Сборка занимает слишком много времени
Первая сборка загружает все зависимости (~2-3 GB) и может занять 10-30 минут в зависимости от интернета.
Последующие сборки будут быстрее благодаря кешированию.

### Нет свободного места
```bash
# Очистить неиспользуемые Docker данные
docker system prune -a
```
