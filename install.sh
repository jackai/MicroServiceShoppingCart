apt-get install git -y

cp -r deployKey/* ~/.ssh
cp -r deployKey/* /root/.ssh
chmod -R 400 ~/.ssh/*
chmod -R 400 /root/.ssh/*
chown -R jacklai:jacklai ~/.ssh/

# 初始化 submodule
git submodule init
git submodule update
chown -R jacklai:jacklai *

sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce -y

sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo docker-compose up -d

cp Account/.env.example Account/.env
cp Main/.env.example Main/.env
cp Product/.env.example Product/.env
cp CartAndOrder/.env.example CartAndOrder/.env

sudo docker-compose exec Account bash -c "chmod -R 777 bootstrap && chmod -R 777 storage && composer install && php artisan key:generate && php artisan migrate"
sudo docker-compose exec Main bash -c "chmod -R 777 bootstrap && chmod -R 777 storage && composer install && php artisan key:generate"
sudo docker-compose exec Product bash -c "chmod -R 777 bootstrap && chmod -R 777 storage && composer install && php artisan key:generate && php artisan migrate:refresh --seed"
sudo docker-compose exec CartAndOrder bash -c "chmod -R 777 bootstrap && chmod -R 777 storage && composer install && php artisan key:generate"

