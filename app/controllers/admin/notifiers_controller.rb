class Admin::NotifiersController < AdminController
  respond_to :html, :json

  def index
    authorize! :index, Notifier
    @notifiers = Notifier.accessible_by(current_ability).order(:username)

    respond_with @notifiers do |format|
      format.json { render :json => @notifiers, :except => 'password' }
    end
  end

  def show
    @notifier = Notifier.find(params[:id])
    authorize! :show, @notifier

    respond_with @notifier do |format|
      format.json { render :json => @notifier, :except => 'password' }
    end
  end

  def new
    authorize! :create, Notifier

    @notifier = Notifier.new

    respond_with @notifier do |format|
      format.json { render :json => @notifier, :except => 'password' }
    end
  end

  def edit
    @notifier = Notifier.find(params[:id])
    authorize! :update, @notifier

    respond_with @notifier do |format|
      format.json { render :json => @notifier, :except => 'password' }
    end
  end

  def create
    authorize! :create, Notifier

    @notifier = Notifier.new
    @notifier.attributes = params[:notifier]
    authorize! :create, @notifier

    @notifier.save

    respond_with :admin, @notifier
  end

  def update
    @notifier = Notifier.find(params[:id])
    authorize! :update, @notifier

    # a blank password indicates no change, don't set to blank
    params[:notifier].delete(:password) if params[:notifier][:password].blank?

    @notifier.attributes = params[:notifier]
    authorize! :update, @notifier

    @notifier.save

    respond_with :admin, @notifier
  end

end
