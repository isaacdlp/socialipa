class TwProxiesController < ApplicationController
  before_action :set_tw_proxy, only: [:show, :edit, :update, :destroy]

  # GET /tw_proxies
  # GET /tw_proxies.json
  def index
    @tw_proxies = TwProxy..order('nickname ASC')
  end

  # GET /tw_proxies/1
  # GET /tw_proxies/1.json
  def show
  end

  # GET /tw_proxies/new
  def new
    @tw_proxy = TwProxy.new
  end

  # GET /tw_proxies/1/edit
  def edit
  end

  # POST /tw_proxies
  # POST /tw_proxies.json
  def create
    @tw_proxy = TwProxy.new(tw_proxy_params)

    respond_to do |format|
      if @tw_proxy.save
        format.html { redirect_to @tw_proxy, notice: 'Tw proxy was successfully created.' }
        format.json { render :show, status: :created, location: @tw_proxy }
      else
        format.html { render :new }
        format.json { render json: @tw_proxy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tw_proxies/1
  # PATCH/PUT /tw_proxies/1.json
  def update
    respond_to do |format|
      if @tw_proxy.update(tw_proxy_params)
        format.html { redirect_to @tw_proxy, notice: 'Tw proxy was successfully updated.' }
        format.json { render :show, status: :ok, location: @tw_proxy }
      else
        format.html { render :edit }
        format.json { render json: @tw_proxy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tw_proxies/1
  # DELETE /tw_proxies/1.json
  def destroy
    @tw_proxy.destroy
    respond_to do |format|
      format.html { redirect_to tw_proxies_url, notice: 'Tw proxy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tw_proxy
      @tw_proxy = TwProxy.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tw_proxy_params
      params.require(:tw_proxy).permit(:nickname, :host, :port, :username, :password)
    end
end
