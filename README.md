# ruby-docker-skeleton
This repo contains a skeleton for creating an app that can run in both Docker, Podman and in the shell.

The skeleton also pulls in a Prometheus that can be used to expose metrics for Kubernetes.
Note that the automatic exporter is disabled, because I think it adds to much rubble, feel free to enable it.

# Docker
## Build
`docker build -t ruby-docker-skeleton .`

## Run
`docker run --rm --publish=8080:8080 ruby-docker-skeleton`

# Podman
Podman works almsot just like Docker, but you can run it in userspace!

## Build
`podman build -t ruby-docker-skeleton .`

## Run
`podman run --rm --publish=8080:8080 ruby-docker-skeleton`

# Signals
In the `Dockerfile` there is one line that changes what signal the app respons to.
``` YAML
# Send "ctrl-c"-like signal when stopping
STOPSIGNAL SIGINT
```
This is also handled in `config.ru`
``` ruby
trap "SIGTERM" do Process.kill("SIGINT", 0) end
```
This is because some Cloud-provides ignore the `STOPSIGNAL` in the `Dockerfile`

# Metrics
Metrics is collected with [Prometheus::Middleware](https://github.com/prometheus/client_ruby). This gem can automatically collect data, but this it turned off by in this application.
``` ruby
#use Prometheus::Middleware::Collector # This adds automatic metrics for endpoints
```

You can still push your own metrics when you feel like it.
``` ruby
@@requests_total.increment(labels: { endpoint: "/ping" })
```
