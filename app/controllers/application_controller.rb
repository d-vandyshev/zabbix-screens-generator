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
    puts @hosts.inspect

    # puts hostgroup_param['id']
    # @hosts = [
    #     {name: 'firstname', ip: hostgroup_params},
    #     {name: 'secondname', ip: '1.1.2.2'}
    # ]
    render 'generator'
  end

  private

  def hostgroup_params
    params.require(:hostgroup).permit(:id)
  end
end
