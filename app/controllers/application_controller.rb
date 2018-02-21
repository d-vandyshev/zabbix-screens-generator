class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsHelper

  def generator
    unless logged_in?
      redirect_to(root_path) and return
    end

    zabbix = Rails.cache.read(session[:uuid])
    @hostgroups_array = zabbix.hostgroups
  end
end
