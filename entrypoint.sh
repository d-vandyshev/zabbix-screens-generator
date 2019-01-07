#!/bin/sh

rm -f /app/tmp/pids/server.pid
export SECRET_KEY_BASE=$(rails secret)

bundle exec rails server
