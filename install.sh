cp Account/.env.example Account/.env
cp Main/.env.example Main/.env
cp Product/.env.example Product/.env
cp CartAndOrder/.env.example CartAndOrder/.env

sudo docker-compose exec Account bash -c "chmod -R 777 bootstrap && chmod -R 777 storage && composer install"
sudo docker-compose exec Main bash -c "chmod -R 777 bootstrap && chmod -R 777 storage && composer install"
sudo docker-compose exec Product bash -c "chmod -R 777 bootstrap && chmod -R 777 storage && composer install"
sudo docker-compose exec CartAndOrder bash -c "chmod -R 777 bootstrap && chmod -R 777 storage && composer install"

