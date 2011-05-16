class ApiController < ApplicationController
  respond_to :json

  # GET /api/test/ping
  def ping
    render :text => 'pong'
  end

end
