# ELK_log_generator


Требования:

linux
bash (GNU bash, version 4.4.20(1)-release (x86_64-pc-linux-gnu))
docker  (Docker version 18.09.7, build 2d0083d)
docker-compose  (docker-compose version 1.17.1, build unknown)
curl (curl 7.58.0 (x86_64-pc-linux-gnu))
tar (tar (GNU tar) 1.29)


Работа скрипта:
используя прилагающийся yaml 
docker запускает три контейнера с преднастроенными nginx, один из которых работает в качестве LB
Далее по скрипту к балансеру отправляются запросы, периодически отключая контейнеры nginx с приложениями
Логи с контейнеров сохраняются в архив
контейнереры тушатся


