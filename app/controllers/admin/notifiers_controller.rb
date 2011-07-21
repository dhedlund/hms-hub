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

  def new
    @notifier = Notifier.new
    respond_with @notifier do |format|
      format.json { render :json => @notifier, :except => 'password' }
    end
  end

  def edit
    @notifier = Notifier.find(params[:id])
    respond_with @notifier do |format|
      format.json { render :json => @notifier, :except => 'password' }
    end
  end

  def create
    @notifier = Notifier.new
    @notifier.attributes = params[:notifier]
    @notifier.save
    respond_with :admin, @notifier
  end

  def update
    n = params[:notifier]
    n.delete(:password) unless n[:password].present?

    @notifier = Notifier.find(params[:id])
    @notifier.update_attributes(n)
    respond_with :admin, @notifier
  end

end
