class TwUsersController < ApplicationController
  before_action :set_tw_user, only: [:show, :edit, :update, :destroy]

  # GET /tw_users
  # GET /tw_users.json
  def index
    @tw_users = TwUser.paginate(page: params[:page], per_page: 100)
  end

  # GET /tw_users/1
  # GET /tw_users/1.json
  def show
  end

  # GET /tw_users/new
  def new
    @tw_user = TwUser.new
  end

  # GET /tw_users/1/edit
  def edit
  end

  # POST /tw_users
  # POST /tw_users.json
  def create
    @tw_user = TwUser.new(tw_user_params)

    respond_to do |format|
      if @tw_user.save
        format.html { redirect_to @tw_user, notice: 'The User was successfully created.' }
        format.json { render :show, status: :created, location: @tw_user }
      else
        format.html { render :new }
        format.json { render json: @tw_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tw_users/1
  # PATCH/PUT /tw_users/1.json
  def update
    respond_to do |format|
      if @tw_user.update(tw_user_params)
        format.html { redirect_to @tw_user, notice: 'The User was successfully updated.' }
        format.json { render :show, status: :ok, location: @tw_user }
      else
        format.html { render :edit }
        format.json { render json: @tw_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tw_users/1
  # DELETE /tw_users/1.json
  def destroy
    @tw_user.destroy
    respond_to do |format|
      format.html { redirect_to tw_users_url, notice: 'The User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tw_user
      @tw_user = TwUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tw_user_params
      params.require(:tw_user).permit(:userid, :username, :name, :image_url, :description)
    end
end
