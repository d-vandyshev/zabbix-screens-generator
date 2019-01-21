class ErrorsController < ApplicationController
  def not_found
    flash.now[:danger] = I18n.t 'errors.page_not_found'
    render status: 404
  end

  def internal_server_error
    flash.now[:danger] = I18n.t 'errors.internal_server_error'
    render status: 500
  end
end
