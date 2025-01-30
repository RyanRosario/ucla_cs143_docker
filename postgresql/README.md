# Setting up PostgreSQL Docker container

Create a shared directory on the local file system:

mkdir ~/cs143_home

Create a persistent volume for PostgreSQL data:

mkdir ~/pgdata

Execute the following command:

docker run -d \
  --name postgres_container \
  -v /home/ec2-user/pgdata:/var/lib/postgresql/data \
  -p 5432:5432 \
  ryanrosario/postgresql:latest

This runs the container in the background. You can stop and delete the container and your data should remain intact.

If you exit the shell, you can enter it again with:

docker exec -it cs143-postgresql su - cs143

