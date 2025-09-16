--- Управление Ace Stream Engine -----

docker start acestream-server # Запустить (если контейнер существует, но остановлен)
docker stop acestream-server # Остановить
docker restart acestream-server # Перезапустить
docker rm acestream-server # Удалить контейнер
docker logs -f acestream-server # Просмотреть логи
docker ps -f name=acestream-server  # Проверить статус



-----🌐 Управление AceProxy -----

docker start aceproxy   # Запустить
docker stop aceproxy    # Остановить
docker restart aceproxy # Перезапустить
docker rm aceproxy  # Удалить контейнер
docker logs -f aceproxy # Просмотреть логи
docker ps -f name=aceproxy  # Проверить статус
