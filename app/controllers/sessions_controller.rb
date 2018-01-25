class SessionsController < ApplicationController
  def new
  end

  def create
    if check_login
      log_in params
      redirect_to generator_url
    else
      flash[:danger] = I18n.t 'login.flash_invalid_login'
      render 'new'
    end
  end

  def destroy
  end

  def check_login
    true
  end
end
