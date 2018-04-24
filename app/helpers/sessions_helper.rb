module SessionsHelper
  require 'securerandom'

  def set_session(username, zabbix)
    session[:uuid] = SecureRandom.uuid
    session[:username] = username
    Rails.cache.write(session[:uuid], {zabbix: zabbix, hostgroups: zabbix.hostgroups})
  end

  def destroy_session
    Rails.cache.delete(session[:uuid])
    reset_session
  end

  def logged_in?
    !session[:uuid].nil? and !Rails.cache.read(session[:uuid]).nil?
  end
end
