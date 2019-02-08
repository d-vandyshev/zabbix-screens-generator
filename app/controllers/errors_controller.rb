class ErrorsController < ApplicationController
  def not_found
    flash.now[:danger] = I18n.t 'errors.page_not_found'
    render status: :not_found
  end

  def internal_server_error
    flash.now[:danger] = I18n.t 'errors.internal_server_error'
    render status: :internal_server_error
  end
end
