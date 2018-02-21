class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to generator_url
    end
  end

  def create
    creds = zabbix_creds_params
    zabbix = ZabbixService.new(creds)
    if zabbix.auth_is_ok?
      set_session(creds[:username], zabbix)
      redirect_to generator_url
    else
      flash.now[:danger] = I18n.t 'login.flash_invalid_login'
      destroy_session
      render 'new'
    end
  end

  def destroy
    destroy_session
    flash.now[:info] = I18n.t 'login.flash_success_logout'
    render 'new'
  end

  private

  def zabbix_creds_params
    params.require(:session).permit(:server, :username, :password)
  end
end
