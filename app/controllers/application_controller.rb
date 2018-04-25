class ApplicationController < ActionController::Base
  before_action :set_locale
  protect_from_forgery with: :exception
  include Turbolinks::Redirection
  include SessionsHelper

  def set_locale
    I18n.locale = session[:locale] || locale_from_accept_lang_header
    # For select locale in header
    @available_locales = I18n.available_locales.map { |l| [l.to_s.upcase, l] }
    @selected_locale = I18n.locale
  end

  def change_locale
    session[:locale] = I18n.locale = locale_param
    redirect_back(fallback_location: root_path)
  end

  private

  def locale_param
    locale = params.require(:locale).permit(:locale).fetch('locale').to_sym
    locale = I18n.default_locale unless I18n.available_locales.include? locale
    locale
  end

  def locale_from_accept_lang_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end
end
