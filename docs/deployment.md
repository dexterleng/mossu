# Deployment Guide

This documentation specifies how to deploy the latest code changes to the production server.

Mossu is hosted on a school Linux VM. The server and sidekiq processes are managed with PM2.

### 1. Connect to the school VPN

To access the server, you will need to be connected to the school VPN with GlobalProtect.

### 2. SSH into the Linux VM

```
ssh user@172.16.54.7
```

### 3. Pull in the latest code

```
cd mossu/

# make sure you are on master
git checkout master

git pull origin master
```

You may try out other branches in production before merging them:

```
git fetch origin <branch name>
git checkout <branch name>
```

### 4. Install new ruby packages

If the Gemfile has changed since the last deployment, the new packages can be installed with:

```
bundle install
```

### 5. Apply database migrations

If new database migrations have been added since the last deployment, they can be applied on the production database with:

```
RAILS_ENV=production rails db:migrate
```

### 6. Restart puma and sidekiq

```
pm2 restart ecosystem.config.js
```

### 7. Monitor the process logs for errors

```
pm2 logs
```

### Dependencies

Mossu depends on Redis and Postgres. The production server relies on the `docker-compose.yml` file in the root directory.

```
# start dependencies detached
docker-compose up -d

docker-compose down
docker-compose restart

# show all containers
docker ps -a

# show logs for a container
docker logs <container id>
```

### Helpful PM2 commands

Overview of process statuses

```
pm2 status
```

Kill all PM2 processes

```
pm2 kill
```
