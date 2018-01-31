class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsHelper

  def generator
    unless session[:zabbix_server] && session[:username] && session[:password]
      redirect_to root_path
    end
    zabbix = ZabbixService.new({zabbix_server: session[:zabbix_server],
                                username: session[:username],
                                password: session[:password]})
    @hostgroups_array = zabbix.hostgroups
  end
end
