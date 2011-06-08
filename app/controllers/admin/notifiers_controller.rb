class Admin::NotifiersController < AdminController
  respond_to :html, :json

  def index
    @notifiers = Notifier.scoped
    respond_with @notifiers
  end

  def show
    @notifier = Notifier.find(params[:id])
    respond_with @notifier
  end
end
