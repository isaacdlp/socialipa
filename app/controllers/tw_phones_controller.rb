class TwPhonesController < ApplicationController
  before_action :set_tw_phone, only: [:show, :edit, :update, :destroy]

  # GET /tw_phones
  # GET /tw_phones.json
  def index
    @tw_phones = TwPhone.order('nickname ASC')
  end

  # GET /tw_phones/1
  # GET /tw_phones/1.json
  def show
  end

  # GET /tw_phones/new
  def new
    @tw_phone = TwPhone.new
  end

  # GET /tw_phones/1/edit
  def edit
  end

  # POST /tw_phones
  # POST /tw_phones.json
  def create
    @tw_phone = TwPhone.new(tw_phone_params)

    respond_to do |format|
      if @tw_phone.save
        format.html { redirect_to @tw_phone, notice: 'Tw phone was successfully created.' }
        format.json { render :show, status: :created, location: @tw_phone }
      else
        format.html { render :new }
        format.json { render json: @tw_phone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tw_phones/1
  # PATCH/PUT /tw_phones/1.json
  def update
    respond_to do |format|
      if @tw_phone.update(tw_phone_params)
        format.html { redirect_to @tw_phone, notice: 'Tw phone was successfully updated.' }
        format.json { render :show, status: :ok, location: @tw_phone }
      else
        format.html { render :edit }
        format.json { render json: @tw_phone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tw_phones/1
  # DELETE /tw_phones/1.json
  def destroy
    @tw_phone.destroy
    respond_to do |format|
      format.html { redirect_to tw_phones_url, notice: 'Tw phone was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tw_phone
      @tw_phone = TwPhone.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tw_phone_params
      params.require(:tw_phone).permit(:nickname, :code, :number)
    end
end
