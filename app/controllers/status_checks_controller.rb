class StatusChecksController < ActionController::Base
  respond_to :html

  def dbcheck
    @users = User.all
  end

end
