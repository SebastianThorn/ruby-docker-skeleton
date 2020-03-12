FROM ruby:2.7-alpine

# Add user
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app
USER app

# Working directory
WORKDIR /usr/src/app

# Ruby-Gems
RUN bundle config --global frozen 1
COPY Gemfile Gemfile.lock ./
RUN bundle install -j4 --quiet

# Copy source-files
COPY config.ru webserver.rb model.rb ./

# Send "ctrl-c"-like signal when stopping
STOPSIGNAL SIGINT

EXPOSE 8080

ENV USERNAME="some_username"
ENV PASSWORD="some_password"

CMD ["rackup", "-p8080", "--host", "0.0.0.0", "-E", "production", "-s", "webrick"]
