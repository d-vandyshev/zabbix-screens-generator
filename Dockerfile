FROM ruby:2.5.3-alpine3.8

RUN apk add --no-cache --update build-base linux-headers nodejs tzdata yarn

ADD . /app
WORKDIR /app
ENV RAILS_ENV production

RUN bundle install --without development test --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3 \
&& echo > ./app/javascript/packs/application.js \
&& bundle exec rails webpacker:install:stimulus \
&& bundle exec rails assets:precompile \
&& chmod +x /app/entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/app/entrypoint.sh"]
