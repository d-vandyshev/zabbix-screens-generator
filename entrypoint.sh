#!/bin/sh

export SECRET_KEY_BASE=$(rails secret)

bundle exec rails server
