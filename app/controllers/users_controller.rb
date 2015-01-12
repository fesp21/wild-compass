class UsersController < ApplicationController

  before_action :filter_password
  
  expose(:user, params: :user_params) { id_param.nil? ? User.new : User.find(id_param) }
  expose(:users) { User.all }

  def index; authorize! :index, users; end
  def show; authorize! :show, user; end
  def edit; authorize! :edit, user; end
  def new; authorize! :new, user; end

  def create
    self.user = User.new(user_params)
    authorize! :create, user

    respond_to do |format|
      if user.save
        format.html { redirect_to user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: user }
      else
        format.html { render :new }
        format.json { render json: user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :update, user

    respond_to do |format|
      if user.update(user_params)
        format.html { redirect_to user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: user }
      else
        format.html { render :edit }
        format.json { render json: user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :destroy, user

    user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def filter_password
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :user_role_id, :user_group_id)
    end

    def id_param
      params[:id]
    end

end
