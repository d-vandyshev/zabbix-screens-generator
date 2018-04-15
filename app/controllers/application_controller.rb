class ApplicationController < ActionController::Base
  before_action :set_locale
  protect_from_forgery with: :exception
  include Turbolinks::Redirection
  include SessionsHelper

  def set_locale
    I18n.locale = session[:locale] || extract_locale_from_accept_language_header
    # For select locale in header
    @available_locales = I18n.available_locales.map { |l| [l.to_s.upcase, l] }
    @selected_locale = I18n.locale
  end

  def change_locale
    session[:locale] = I18n.locale = locale_param.fetch 'locale'
    redirect_back(fallback_location: root_path)
  end

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
    @hostgroup_id = hostgroup_params.fetch('id')

    render 'generator'
  end

  def screen
    zabbix = Rails.cache.read(session[:uuid])
    @results = zabbix.create_screens hosts_ids_from_params
  end

  private

  def hostgroup_params
    params.require(:hostgroup).permit(:id)
  end

  def hosts_ids_from_params
    ids = []
    params.select do |k,v|
      if k !~ /\D/ # check for only digits in string
        ids << k
      end
    end
    ids
  end

  private
  def locale_param
    params.require(:locale).permit(:locale)
    # TODO Check locale for string and match with available locales
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end
end
