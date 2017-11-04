class TwAccountsController < ApplicationController
  before_action :set_tw_account, only: [:show, :edit, :update, :destroy]

  # GET /tw_accounts
  # GET /tw_accounts.json
  def index
    @tw_accounts = TwAccount.paginate(page: params[:page], per_page: 100)
  end

  # GET /tw_accounts/1
  # GET /tw_accounts/1.json
  def show
  end

  # GET /tw_accounts/new
  def new
    @tw_account = TwAccount.new
  end

  # GET /tw_accounts/1/edit
  def edit
  end

  # POST /tw_accounts
  # POST /tw_accounts.json
  def create
    @tw_account = TwAccount.new(tw_account_params)

    respond_to do |format|
      if @tw_account.save
        format.html { redirect_to @tw_account, notice: 'The Account was successfully created.' }
        format.json { render :show, status: :created, location: @tw_account }
      else
        format.html { render :new }
        format.json { render json: @tw_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tw_accounts/1
  # PATCH/PUT /tw_accounts/1.json
  def update
    respond_to do |format|
      if @tw_account.update(tw_account_params)
        format.html { redirect_to @tw_account, notice: 'The Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @tw_account }
      else
        format.html { render :edit }
        format.json { render json: @tw_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tw_accounts/1
  # DELETE /tw_accounts/1.json
  def destroy
    @tw_account.destroy
    respond_to do |format|
      format.html { redirect_to tw_accounts_url, notice: 'The Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tw_account
      @tw_account = TwAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tw_account_params
      params.require(:tw_account).permit(:username, :email, :password, :agent, :proxy, :phone, :description)
    end
end
