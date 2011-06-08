class Admin::NotifiersController < AdminController
  respond_to :html, :json

  def index
    @notifiers = Notifier.scoped
    respond_with @notifiers do |format|
      format.json { render :json => @notifiers, :except => 'password' }
    end
  end

  def show
    @notifier = Notifier.find(params[:id])
    respond_with @notifier do |format|
      format.json { render :json => @notifier, :except => 'password' }
    end
  end
end
