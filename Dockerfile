FROM ruby:2.5.3-alpine3.8

RUN apk add --no-cache --update build-base linux-headers nodejs tzdata yarn

ADD . /app
WORKDIR /app
RUN bundle install --without development test --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

ENV RAILS_ENV production
RUN echo > ./app/javascript/packs/application.js
RUN bundle exec rails webpacker:install:stimulus
RUN bundle exec rails assets:precompile

EXPOSE 3000
ENTRYPOINT ["/app/entrypoint.sh"]
