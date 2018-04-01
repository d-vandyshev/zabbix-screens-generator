class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include Turbolinks::Redirection

  include SessionsHelper

  def generator
    unless logged_in?
      redirect_to(root_path) and return
    end

    zabbix = Rails.cache.read(session[:uuid])
    @hostgroups_array = zabbix.hostgroups
  end

  def generator_post
    unless logged_in?
      redirect_to(root_path) and return
    end

    zabbix = Rails.cache.read(session[:uuid])
    @hostgroups_array = zabbix.hostgroups
    @hosts = zabbix.hosts_by_hostgroup_id(hostgroup_params.fetch('id'))

    render 'generator'
  end

  def screen
    ids = host_ids_from_params
    puts 'ids: '
    puts ids.inspect

    # TODO
    # call Zabbix Service for create screens for this host ids
    # And flash message for result

  end

  private

  def hostgroup_params
    params.require(:hostgroup).permit(:id)
  end

  def host_ids_from_params
    ids = []
    params.select do |k,v|
      if k !~ /\D/ # check for only digits in string
        ids << k
      end
    end
    ids
  end
end
