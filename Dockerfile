FROM ruby:2.5.3-alpine3.8

RUN apk add --no-cache build-base tzdata nodejs

ADD . /app
WORKDIR /app
RUN bundle install --without development test --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3
RUN chmod +x /app/entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/app/entrypoint.sh"]
