# Dockerfile для сборки ZMK прошивки
# Использует официальный образ zmkfirmware для сборки

FROM zmkfirmware/zmk-build-arm:stable

# Установка рабочей директории
WORKDIR /workspace

# Копирование конфигурации проекта
COPY config/west.yml config/west.yml
COPY config/ config/
COPY boards/ boards/
COPY build.yaml build.yaml

# Инициализация west и загрузка зависимостей
RUN west init -l config && \
    west update && \
    west zephyr-export

# Команда по умолчанию - сборка всех конфигураций из build.yaml
# Можно переопределить при запуске контейнера
CMD ["/bin/bash", "-c", "\
    # Сборка dongle с ZMK Studio \
    west build -s zmk/app -d build/charybdis_dongle -b nice_nano_v2 -- \
        -DZMK_CONFIG=/workspace/config \
        -DSHIELD=charybdis_dongle \
        -DZMK_EXTRA_MODULES='/workspace/boards' \
        -DCONFIG_ZMK_STUDIO=y \
        -Dstudio-rpc-usb-uart_SNIPPET=y && \
    cp build/charybdis_dongle/zephyr/zmk.uf2 /workspace/output/charybdis_dongle.uf2 && \
    echo 'Собрано: charybdis_dongle.uf2' && \
    \
    # Сборка settings_reset \
    west build -s zmk/app -d build/settings_reset -b nice_nano_v2 -- \
        -DZMK_CONFIG=/workspace/config \
        -DSHIELD=settings_reset && \
    cp build/settings_reset/zephyr/zmk.uf2 /workspace/output/settings_reset.uf2 && \
    echo 'Собрано: settings_reset.uf2' && \
    \
    # Сборка charybdis_left \
    west build -s zmk/app -d build/charybdis_left -b nice_nano_v2 -- \
        -DZMK_CONFIG=/workspace/config \
        -DSHIELD=charybdis_left \
        -DZMK_EXTRA_MODULES='/workspace/boards' && \
    cp build/charybdis_left/zephyr/zmk.uf2 /workspace/output/charybdis_left.uf2 && \
    echo 'Собрано: charybdis_left.uf2' && \
    \
    # Сборка charybdis_right \
    west build -s zmk/app -d build/charybdis_right -b nice_nano_v2 -- \
        -DZMK_CONFIG=/workspace/config \
        -DSHIELD=charybdis_right \
        -DZMK_EXTRA_MODULES='/workspace/boards' && \
    cp build/charybdis_right/zephyr/zmk.uf2 /workspace/output/charybdis_right.uf2 && \
    echo 'Собрано: charybdis_right.uf2' && \
    \
    echo '===================================' && \
    echo 'Сборка завершена!' && \
    echo 'Файлы прошивок в /workspace/output/' && \
    ls -lh /workspace/output/"]
