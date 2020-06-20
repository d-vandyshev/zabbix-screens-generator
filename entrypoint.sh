#!/bin/sh
set -e
rm -f /app/tmp/pids/server.pid
export SECRET_KEY_BASE=$(rails secret)
export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=yes
export RAILS_LOG_TO_STDOUT=yes
bundle exec rails server
