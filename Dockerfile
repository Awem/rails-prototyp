FROM ruby:latest
ENV RAILS_ENV production
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN mkdir /myapp
WORKDIR /myapp
ADD . /myapp
RUN bundle config without test development
RUN bundle install
# remove Gemfile.lock
# cleanup Gemfile
# update config/database.yml
# remove /config/initializers/leaflet.rb
