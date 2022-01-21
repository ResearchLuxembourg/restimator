#!/bin/bash
docker-compose up --no-recreate

# In case you wanted to run step by step:
# docker-compose run check --no-recreate --abort-on-container-exit
# docker-compose run reff --no-recreate --abort-on-container-exit
# docker-compose run rt --no-recreate --abort-on-container-exit