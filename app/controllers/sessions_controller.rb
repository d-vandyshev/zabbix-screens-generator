class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to screens_new_path
    end
    @credentials = Credentials.new
  end

  def create
    @credentials = Credentials.new(params_zabbix_creds)
    if @credentials.valid?
      username = params_zabbix_creds.fetch(:username)
      zabbix = ZabbixService.new(@credentials)
      set_session(username, zabbix)
      redirect_to screens_new_path
    else
      render 'new'
    end
  rescue
    flash.now[:danger] = I18n.t 'login.flash_invalid_login'
    render 'new'
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
