CREATE ROLE cs143 WITH LOGIN PASSWORD 'cs143';
ALTER ROLE cs143 WITH SUPERUSER;
CREATE DATABASE cs143 OWNER cs143;
