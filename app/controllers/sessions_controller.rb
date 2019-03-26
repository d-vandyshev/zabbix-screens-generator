class SessionsController < ApplicationController
  def new
    redirect_to(screens_new_path) if logged_in?

    @credentials = Credentials.new
  end

  def create
    @credentials = Credentials.new(params_zabbix_creds)
    if @credentials.invalid?
      redirect_to root_path
      return
    end

    zabbix = connect_to_zabbix
    if zabbix.nil?
      redirect_to root_path
      return
    end

    set_session(params_zabbix_creds.fetch(:username), zabbix)
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

  def connect_to_zabbix
    ZabbixService.new(@credentials)
  rescue StandardError => e
    flash[:danger] = if e.message.include?('Login name or password is incorrect')
                           I18n.t 'login.flash_invalid_login'
                         else
                           "Error! #{e.class}: #{e.message}"
                         end
    nil
  end
end
