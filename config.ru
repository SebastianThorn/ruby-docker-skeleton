#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#
# Include prometheus-scraper
require "rack"
require "prometheus/middleware/collector"
require "prometheus/middleware/exporter"
use Rack::Deflater

#
# Cathing SIGTERM and replacing with SIGINT.
# Some Cloud-providers ignore STOPSIGLAN in the Dockerfile
# This problem is found in Google Cloud Run
trap "SIGTERM" do Process.kill("SIGINT", 0) end

#
# Handle metrics, these are available under /metrics
#use Prometheus::Middleware::Collector # This adds automatic metrics for endpoints
use Prometheus::Middleware::Exporter

#
# Load the webserver
require "./webserver.rb"

#
# Sync stdout immediately, this is needed when running in Docker
$stdout.sync = true

#
# Change Rack-logging to json
module Rack
  class CommonLogger
    def log(env, status, header, began_at)
      log_data = {
        type: "rack",
        remoteIP: env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
        remote_host: env["REMOTE_USER"] || "-",
        request: env[REQUEST_METHOD],
        query: env[PATH_INFO],
        method: env[QUERY_STRING].empty? ? "" : "?#{env[QUERY_STRING]}",
        status: status.to_s[0..3],
        version: env[HTTP_VERSION],
        userAgent: env["HTTP_USER_AGENT"],
        short_message: "#{env[REQUEST_METHOD]} #{env[PATH_INFO]}",
      }
      $logger.info(log_data)
    end
  end
end

#
# Changel WEBrick-logging to json
module WEBrick
  class Log < BasicLog
    def log(level, data)

      # Create translations for levels
      log_map = Hash.new("unknown")
      log_map[1] = "fatal"
      log_map[2] = "error"
      log_map[3] = "warn"
      log_map[4] = "info"
      log_map[5] = "debug"

      # Remove "INFO  " / "DEBUG " from data
      data[0..5] = ""

      # Log the data
      $logger.send(log_map[level], data)
    end
  end
end

#
# Start the webserver
run Webserver
