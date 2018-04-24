class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to screens_new_path
    end
  end

  def create
    creds = zabbix_creds_params
    zabbix = ZabbixService.new(creds)
    if zabbix.auth_is_ok?
      set_session(creds[:username], zabbix)
      redirect_to screens_new_path
    else
      flash.now[:danger] = I18n.t 'login.flash_invalid_login'
      destroy_session
      render 'new'
    end
  end

  def destroy
    destroy_session
    flash[:info] = I18n.t 'login.flash_success_logout'
    redirect_to root_url
  end

  private

  def zabbix_creds_params
    params.require(:session).permit(:server, :username, :password)
  end
end
