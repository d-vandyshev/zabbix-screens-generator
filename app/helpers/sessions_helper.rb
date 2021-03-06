module SessionsHelper
  require 'securerandom'

  def set_session(username, zabbix)
    session[:uuid] = SecureRandom.uuid
    session[:username] = username
    Rails.cache.write(session[:uuid], zabbix)
  end

  def destroy_session
    Rails.cache.delete(session[:uuid])
    reset_session
  end

  def logged_in?
    !session[:uuid].nil? && !Rails.cache.read(session[:uuid]).nil?
  end
end
