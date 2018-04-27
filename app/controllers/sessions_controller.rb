class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to screens_new_path
    end
  end

  def create
    zabbix = ZabbixService.new(params_zabbix_creds)
    set_session(params_zabbix_creds.fetch(:username), zabbix)
    redirect_to screens_new_path
  rescue
    flash.now[:danger] = I18n.t 'login.flash_invalid_login'
    render 'new'
    destroy_session
  end

  def destroy
    destroy_session
    flash[:info] = I18n.t 'login.flash_success_logout'
    redirect_to root_url
  end

  private

  def params_zabbix_creds
    params.require(:session).permit(:server, :username, :password)
    [params[:server],
     params[:username],
     params[:password]].map!{|e| e.chars.first(64).join}
    params
  end
end
