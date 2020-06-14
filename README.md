# ruby-docker-skeleton
This repo contains a skeleton for creating an app that can run in both Docker, Podman and in the shell.

The skeleton also pulls in a Prometheus that can be used to expose metrics for Kubernetes.
Note that the automatic exporter is disabled, because I think it adds to much rubble, feel free to enable it.

## Build
`docker build -t ruby-docker-skeleton .`

## Run
`docker run --rm --publish=8080:8080 ruby-docker-skeleton`
