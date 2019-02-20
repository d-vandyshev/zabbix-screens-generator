class ScreensController < ApplicationController
  include Zabbixable
  include Authable
  before_action :require_login

  def new
    @hostgroups = zabbix_from_cache.hostgroups
  end

  def create
    @results = zabbix_from_cache.create_screens(*params_host_ids)
  end

  private

  def params_hostgroup_id
    params.require(:hostgroup).permit(:id).fetch('id')
  end

  def params_host_ids
    ids = params[:host_ids].select { |id| /\d/.match(id.to_s) } # check for only digits in string
    with_replace = params[:with_replace] ? true : false
    [ids, with_replace]
  end
end
