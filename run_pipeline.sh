#!/bin/bash

. /etc/bashrc
docker-compose down
docker-compose up --no-recreate