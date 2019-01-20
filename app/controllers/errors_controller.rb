class ErrorsController < ApplicationController
  def not_found
    flash.now[:danger] = 'Page not found (400)'
    render status: 404
  end

  def internal_server_error
    flash.now[:danger] = 'An Internal Server Error occured (500)'
    render status: 500
  end
end
