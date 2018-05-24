class ScreensController < ApplicationController
  before_action :require_login

  def new
    @hostgroups = zabbix_from_cache.hostgroups

    if request.post?
      @hostgroup_is_selected = true
      @hosts = zabbix_from_cache.hosts_by_hostgroup_id(params_hostgroup_id)
      @hostgroup_with_hosts = !@hosts.empty?
      @hostgroup_id = params_hostgroup_id # for selected
    else
      @hostgroup_is_selected = false
    end
  end

  def create
    @results = zabbix_from_cache.create_screens(*params_host_ids)
  end

  private

  def require_login
    unless logged_in?
      flash[:danger] = I18n.t 'screens.must_be_logged_in'
      redirect_to root_path
    end
  end

  def params_hostgroup_id
    params.require(:hostgroup).permit(:id).fetch('id')
  end

  def params_host_ids
    ids = params[:host_ids].select {|id| id !~ /\D/} # check for only digits in string
    with_replace = params[:with_replace] ? true : false
    [ids, with_replace]
  end

  def zabbix_from_cache
    Rails.cache.read(session[:uuid])
  end
end
