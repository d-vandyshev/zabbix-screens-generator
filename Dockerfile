FROM ruby:2.6.6-alpine3.11

RUN apk add --no-cache build-base tzdata nodejs
ADD . /app
WORKDIR /app

RUN gem install bundler:$(awk '/BUNDLED WITH/{getline; {$1=$1}; print}' Gemfile.lock)
RUN bundle config set without 'development test' && \
    bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3
RUN chmod +x /app/entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/app/entrypoint.sh"]
