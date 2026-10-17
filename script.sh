#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Начинаем настройку сервера Minecraft...${NC}"

# Обновление системы
echo -e "${YELLOW}Обновляем систему...${NC}"
sudo apt update &> /dev/null
sudo apt upgrade &> /dev/null

if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка при обновлении системы!${NC}"
    exit 1
fi

# Ввод имени пользователя
read -p "Имя пользователя для сервера: " name_polzavatel

# Создание пользователя
echo -e "${YELLOW}Создаём пользователя $name_polzavatel...${NC}"
useradd "$name_polzavatel" -m -s /bin/bash

if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка при создании пользователя!${NC}"
    exit 1
fi

sleep 3

echo -e "${YELLOW}Устанавливаем пароль для $name_polzavatel:${NC}"
passwd "$name_polzavatel"

if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка при установке пароля!${NC}"
    exit 1
fi

# Переходим в домашнюю директорию пользователя
su "$name_polzavatel" 
cd /home/"$name_polzavatel"

# Ввод названия папки
read -p "Введите название папки: " name_osnova_path

# Создаём папку
echo -e "${YELLOW}Создаём папку $name_osnova_path...${NC}"
mkdir "/home/$name_polzavatel/$name_osnova_path"

if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка при создании папки!${NC}"
    exit 1
fi

cd /home/"$name_polzavatel"/"$name_osnova_path"

# Выбор версии Minecraft
echo -e "${YELLOW}Какая версия Minecraft нужна?${NC}"
select choice in "1.12.2" "1.21.8"; do
    case $choice in
        "1.12.2")
            echo -e "${GREEN}Начинаем установку версии 1.12.2...${NC}"
            
            # Установка Java
            echo -e "${YELLOW}Устанавливаем OpenJDK 8...${NC}"
            sudo apt install openjdk-8-jdk-headless -y &> /dev/null
            
            if [ $? -ne 0 ]; then
                echo -e "${RED}Ошибка при установке Java!${NC}"
                exit 1
            fi
            
            # Загрузка сервера
            echo -e "${YELLOW}Загружаем сервер...${NC}"
            wget -P "/home/$name_polzavatel" "https://fill-data.papermc.io/v1/objects/3a2041807f492dcdc34ebb324a287414946e3e05ec3df6fd03f5b5f7d9afc210/paper-1.12.2-1620.jar"            
            # Создаём скрипт запуска
            echo 'java -Xms2048M -Xmx2048M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=2000 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -jar server.jar --nogui' > start.sh
            ./start.sh
            echo "Принимаем EULA?"
            select choice1 in "Да" "Нет"; do
                case $choice1 in 
                    "Да")
                        sed -i '3s/eula=false/eula=true/g' eula.txt
                        echo "Что дальше?"
                         select choice2 in "Запустить сервер" "Выйти"; do
                            case $choice2 in 
                                "Запустить сервер")
                                    ./start.sh
                                "Выйти"
                                    break
                                    esac
                                    done
                                    ;; 
                    "Нет")
                        break
                        esac
                        done
                        ;;
        "1.21.8")
            echo "Какое ядро нужно?"
            select choice3 in "paper" "Не поддерживается"; do
                case $choice3 in
                    "paper")
                        echo "Начинаем установку"
                        sudo apt install openjdk-25-jdk-headless -y &> /dev/null
                        wget -P "/home/$name_polzavatel/$name_osnova_path" https://fill-data.papermc.io/v1/objects/8de7c52c3b02403503d16fac58003f1efef7dd7a0256786843927fa92ee57f1e/paper-1.21.8-60.jar
                                    
                        # Сохраняем оригинальный формат скрипта запуска
                        echo '#!/bin/bash

java -Xms2G -Xmx$2G --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -jar paper-1.21.8-60 --nogui' > start.sh
                                    
                                    chmod u+x "/home/$name_polzavatel/$name_osnova_path/start.sh"
                                    ./start.sh
                                    echo "Принимаем EULA"
                                    break
                                    ;;
                            esac
                        done
                        ;;
                    "Не поддерживается")
                        echo "Выбор отменен"
                        break
                        ;;
                esac
            done

# Обработка EULA
select choice4 in "Да" "Нет"; do
    case $choice4 in
        "Да")
            sed -i '3s/eula=false/eula=true/g' eula.txt
            echo "EULA принят"
            break
            ;;
    esac
done

# Финальное действие
select choice5 in "Запустить сервер" "Выйти"; do
    case $choice5 in
        "Запустить сервер")
            ./start.sh
            break
            ;;
        "Выйти")
            break
            ;;
    esac
done

echo -e "${GREEN}Настройка завершена!${NC}"
