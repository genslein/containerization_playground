# Properly building and tagging

```bash

# Examples of build naming and tagging based on file target too
sudo docker build -t postgresondocker:9.3 .
sudo docker build -t postgresondocker:9.3 -f <your_docker_file_name>

```

##### Targeting on docker network

```
sudo docker network create --driver bridge postgres-network
```

##### Create container from image
```
sudo docker run --name postgresondocker --network postgres-network -d postgresondocker:9.3
```