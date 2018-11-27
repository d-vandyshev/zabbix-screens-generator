FROM ruby:2.5.3-alpine3.8

RUN apk add --no-cache --update build-base linux-headers nodejs tzdata

ADD . /app

WORKDIR /app
RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

EXPOSE 3000
ENTRYPOINT ["rails", "server"]
