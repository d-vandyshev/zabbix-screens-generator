class HostsController < ApplicationController
  include Zabbixable
  include Authable
  before_action :require_login

  def index
    @hosts = zabbix_from_cache.hosts_by_hostgroup(params_hostgroup_id)
    if @hosts.empty?
      render partial: 'empty'
      return
    end
    render partial: 'index'
  end

  private

  def params_hostgroup_id
    params[:hostgroup_id].tr('^0-9', '') # check for only digits in string
  end
end
