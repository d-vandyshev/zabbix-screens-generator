class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to screens_new_path
    end
    @credentials = Credentials.new
  end

  def create
    @credentials = Credentials.new(params_zabbix_creds)
    unless @credentials.valid?
      render 'new' and return
    end

    zabbix = ZabbixService.new(@credentials)
    unless zabbix.connected?
      flash.now[:danger] = I18n.t 'login.flash_invalid_login'
      render 'new' and return
    end

    username = params_zabbix_creds.fetch(:username)
    set_session(username, zabbix)
    redirect_to screens_new_path
  end

  def destroy
    destroy_session
    flash[:info] = I18n.t 'login.flash_success_logout'
    redirect_to root_url
  end

  private

  def params_zabbix_creds
    params.require(:credentials).permit(:server, :username, :password)
  end
end
