#! /usr/bin/env bash

docker-compose \
	-f "./watchtower/docker-compose.yml" \
	-f "./docker/docker-compose.yml" \
	-f "./cloudflare/docker-compose.yml" \
 	-f "./traefik/docker-compose.yml" \
 	-f "./miniflux/docker-compose.yml" \
 	-f "./bitwarden/docker-compose.yml" \
 	-f "./hello/docker-compose.yml" \
 	-f "./languagetool/docker-compose.yml" \
 	-f "./dave/docker-compose.yml" \
 	-f "./paperless/docker-compose.yml" \
  	--project-directory "$PWD" "$@"