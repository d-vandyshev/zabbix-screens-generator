class SessionsController < ApplicationController
  def new
  end

  def create
    set_session params
    zabbix = ZabbixService.new({zabbix_server: session[:zabbix_server],
                                username: session[:username],
                                password: session[:password]})
    if zabbix.auth_is_ok?
      redirect_to generator_url
    else
      flash.now[:danger] = I18n.t 'login.flash_invalid_login'
      destroy_session
      render 'new'
    end
  end

  def destroy
  end

  def check_login
    true
  end
end
