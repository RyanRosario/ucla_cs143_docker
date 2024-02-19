# ucla_cs143_docker

Docker images for CS143 at UCLA taught by Prof. Ryan Rosario.

This repo contains Dockerfiles for a series of images including (Docker Hub repo in parentheses):

1. PostgreSQL
2. Spark (ryanrosario/spark)
3. MongoDB (ryanrosario/nosql)

Eventually, all software will be combined into one image, or using Docker Compose.

## Building

To build an image:

cd to the proper directory and run

docker build -t your_repo_name/image_name .

To make sure the image works with common student systems (amd64 and arm64):

sudo apt install docker-buildx

docker buildx create --name a_name_for_the_builder --use --bootstrap
docker login (use your Docker Hub username and password)
docker buildx build --push --platform linux/amd64,linux/arm64 --tag your_repo_name/image_name:latest .
