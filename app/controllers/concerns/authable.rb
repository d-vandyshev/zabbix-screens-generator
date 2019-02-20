module Authable
  extend ActiveSupport::Concern

  private

  def require_login
    return if logged_in?

    flash[:danger] = I18n.t 'screens.must_be_logged_in'
    redirect_to root_path
  end
end
