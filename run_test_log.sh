#!/bin/bash

echo "Cleaning previous run..."
docker-compose stop
docker-compose rm -f

#1. Деплоим приложения в докере
echo "Starting containers"
docker-compose up --build -d --remove-orphans

echo "Waiting start 60 sec"
  sleep 60
#2. Запускаем 50 запросов к приложению
echo "Running 100 requests  (10 sec)"
for i in {1..100}; do curl http://localhost:80 -m 1 --silent -I | grep HTTP >> curloutput.log; done

#3. Останавливаем один контейнер и еще 50 запросов
echo "Stopping nginx1 container"
docker stop $(docker ps --format '{{.Names}}' | grep nginx1)

echo "Running again 50 requests  (50 sec)"
for i in {1..50}; do curl http://localhost:80 -m 10 --silent -I | grep HTTP >> curloutput.log; done

#4. Запускаем ранее остановленный контейнер 50 запросов
echo "Starting container nginx1"
docker start $(docker ps -a --format '{{.Names}}' | grep nginx1)

echo "Running again 50 requests  (50 sec)"
for i in {1..50}; do curl http://localhost:80 -m 1 --silent -I | grep HTTP >> curloutput.log; done

#5. Останавливаем 2й контейнер, и 50 запросов 
echo "Stopping nginx2 container"
docker stop $(docker ps --format '{{.Names}}' | grep nginx2)

echo "Running again 50 requests  (50 sec)"
for i in {1..50}; do curl http://localhost:80 -m 10 --silent -I | grep HTTP >> curloutput.log; done
#6. Останавливаем оба контейнера и еще 20 запросов
echo "Stopping nginx1 container again ..."
docker stop $(docker ps --format '{{.Names}}' | grep nginx1)

echo "Running Random count (0-100) requests "

RND=$(( $RANDOM % 100 ))

echo $RND

for i in {1..100}
do
   curl http://localhost:80 -m 10 --silent -I | grep HTTP >> curloutput.log;
    if [ $i -eq $RND ]; then
     break;
    fi
done

#7. Запускаем оба контейнера и еще 30 запросов
echo "Starting both containers nginx1"

docker start $(docker ps -a --format '{{.Names}}' | grep nginx1)
docker start $(docker ps -a --format '{{.Names}}' | grep nginx2)


echo "And again Running  30 requests  (30 sec)"
sleep 1
for i in {1..30}; do curl http://localhost:80 -m 1 --silent -I | grep HTTP >> curloutput.log; done

#8. Собираем полученные логи в лог-файлы.
echo "Collectiong logs to tar.gz archive.."
mv logdir/app1/access.log logdir/app1_acc.log
mv logdir/app1/error.log logdir/app1_err.log
mv logdir/app2/access.log logdir/app2_acc.log
mv logdir/app2/error.log logdir/app2_err.log
mv logdir/LB/access.log logdir/lb_acc.log
mv logdir/LB/error.log logdir/lb_err.log

find logdir/ -name "*.log" | tar -cf logfiles.tar -T -
rm -f logdir/*.log

#8. подчищаем за собой
docker-compose rm -s -f

