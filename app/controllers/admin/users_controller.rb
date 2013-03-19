class Admin::UsersController < AdminController
  respond_to :html, :json

  before_filter :set_available_locales, :set_available_roles

  def index
    authorize! :index, User
    @users = User.accessible_by(current_ability)

    respond_with @users do |format|
      format.json { render :json => @users, :except => 'password' }
    end
  end

  def show
    @user = User.find(params[:id])
    authorize! :show, @user

    respond_with @user do |format|
      format.json { render :json => @user, :except => 'password' }
    end
  end

  def new
    authorize! :create, User
    @user = User.new

    respond_with @user do |format|
      format.json { render :json => @user, :except => 'password' }
      format.html { prepare_form; render }
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize! :update, @user

    respond_with @user do |format|
      format.json { render :json => @user, :except => 'password' }
      format.html { prepare_form; render }
    end
  end

  def create
    authorize! :create, User

    @user = User.new
    @user.attributes = params[:user]

    # prevent user from getting a more powerful role than current_user

    authorize! :create, @user

    unless @user.save
      prepare_form
    end

    respond_with :admin, @user
  end

  def update
    @user = User.find(params[:id])
    authorize! :update, User

    # a blank password indicates no change, don't set to blank
    params[:user].delete(:password) if params[:user][:password].blank?

    # prevent user from getting a more powerful role than current_user
    if @user.role_changed? && !@available_roles.include?(@user.role)
      @user.role = @user.role_was # role escalation, reset to original
    end

    @user.attributes = params[:user]
    authorize! :update, @user

    unless @user.save
      prepare_form
    end

    respond_with :admin, @user
  end


  private

  def prepare_form
    # instance variables needed for html form
    @notifiers = Notifier.order(:name)
  end

  def set_available_locales
    @available_locales = I18n.available_locales.select do |locale|
      I18n.t('admin', :locale => locale, :default => {}).any?
    end
  end

  def set_available_roles
    @available_roles = Ability.subroles_for(current_ability)
  end

end
