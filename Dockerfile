FROM ruby:3.0
WORKDIR /app
RUN apt-get update && apt-get install redis -y
RUN bundle config set --global force_ruby_platform true
RUN gem i bundler
COPY . .
