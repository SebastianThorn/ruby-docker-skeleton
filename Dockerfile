FROM ruby:2.7-alpine

# Add user
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app
USER app

# Working directory
WORKDIR /usr/src/app

# Copy bundler Gemfile for rubygems
COPY --chown=app:app Gemfile Gemfile.lock ./

# Ruby-Gems
RUN bundle lock --update && \
    bundle install --jobs=4

# Copy source-files
COPY --chown=app:app config.ru webserver.rb model.rb ./

# Send "ctrl-c"-like signal when stopping
STOPSIGNAL SIGINT

# Expose port 8080
EXPOSE 8080

# Set environment-variables to read
ENV USERNAME="some_username"
ENV PASSWORD="some_password"

# Start the server
CMD ["rackup", "-p8080", "--host", "0.0.0.0", "-E", "production", "-s", "webrick"]
