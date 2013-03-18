class Admin::UsersController < AdminController
  respond_to :html, :json

  before_filter :set_available_locales

  def index
    @users = User.scoped
    respond_with @users do |format|
      format.json { render :json => @users, :except => 'password' }
    end
  end

  def show
    @user = User.find(params[:id])
    respond_with @user do |format|
      format.json { render :json => @user, :except => 'password' }
    end
  end

  def new
    @user = User.new
    @notifiers = Notifier.order(:name)
    respond_with @user do |format|
      format.json { render :json => @user, :except => 'password' }
    end
  end

  def edit
    @user = User.find(params[:id])
    @notifiers = Notifier.order(:name)
    respond_with @user do |format|
      format.json { render :json => @user, :except => 'password' }
    end
  end

  def create
    @user = User.new
    @notifiers = Notifier.order(:name)
    @user.attributes = params[:user]
    @user.save
    respond_with :admin, @user
  end

  def update
    u = params[:user]
    u.delete(:password) unless u[:password].present?

    @notifiers = Notifier.order(:name)

    @user = User.find(params[:id])
    @user.update_attributes(u)
    respond_with :admin, @user
  end


  private

  def set_available_locales
    @available_locales = I18n.available_locales.select do |locale|
      I18n.t('admin', :locale => locale, :default => {}).any?
    end
  end

end
