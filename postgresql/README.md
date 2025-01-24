# Setting up PostgreSQL Docker container

Create a shared directory on the local file system:

mkdir ~/cs143_home

Create a persistent volume for PostgreSQL data:

mkdir ~/pgdata

Execute the following command:

docker run -d   --name cs143-postgresql   -v pgdata:/var/lib/postgresql/16/main -v cs143_home:/home/cs143   -p 5432:5432   ryanrosario/postgresql:latest

This runs the container in the background. You can stop and delete the container and your data should remain intact.

If you exit the shell, you can enter it again with:

docker exec -it cs143-postgresql su - cs143

