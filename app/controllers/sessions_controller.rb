class SessionsController < ApplicationController
  def new
    redirect_to(screens_new_path) if logged_in?

    @credentials = Credentials.new
  end

  def create
    @credentials = Credentials.new(params_zabbix_creds)
    if @credentials.invalid?
      render 'new'
      return
    end

    begin
      zabbix = ZabbixService.new(@credentials)
    rescue => e
      flash.now[:danger] = if e.message.include?('Login name or password is incorrect')
                             I18n.t 'login.flash_invalid_login'
                           else
                             "Error! #{e.class}: #{e.message}"
                           end
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
