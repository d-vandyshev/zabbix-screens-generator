module Zabbixable
  extend ActiveSupport::Concern

  private

  def zabbix_from_cache
    Rails.cache.read(session[:uuid])
  end
end
