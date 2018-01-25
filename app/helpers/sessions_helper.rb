module SessionsHelper

  def log_in(params)
    session[:zabbix_host] = params[:session][:zabbix_host]
    session[:username]    = params[:session][:username]
    session[:password]    = params[:session][:password]
  end
end
